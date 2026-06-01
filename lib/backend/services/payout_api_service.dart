import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../language/language_controller.dart';
import '../backend_utils/api_method.dart'; // bearerHeaderInfo()
import '../backend_utils/logger.dart';
import '../models/common/common_success_model.dart';
import '../models/common/error_message_model.dart';
import 'api_endpoint.dart';

final _log = logger(PayoutApiService);

// ─── Discriminated result type ────────────────────────────────────────────────

/// Describes why a payout submission ended.
///
/// [success]    – HTTP 200; server confirmed the ledger entry.
/// [ambiguous]  – Timeout, socket drop, ClientException, or 5xx. The server
///                state is UNKNOWN. The client MUST surface a "pending" screen
///                and must NOT allow re-submission with the same reference.
/// [definitive] – Clean 4xx rejection. The transaction was NOT processed and
///                it is safe to let the user correct input and retry.
enum PayoutOutcome { success, ambiguous, definitive }

class PayoutResult {
  final PayoutOutcome outcome;
  final CommonSuccessModel? data;
  final String message;

  const PayoutResult._({
    required this.outcome,
    this.data,
    this.message = '',
  });

  factory PayoutResult.success(CommonSuccessModel data) => PayoutResult._(
        outcome: PayoutOutcome.success,
        data: data,
      );

  factory PayoutResult.ambiguous(String message) => PayoutResult._(
        outcome: PayoutOutcome.ambiguous,
        message: message,
      );

  factory PayoutResult.definitive(String message) => PayoutResult._(
        outcome: PayoutOutcome.definitive,
        message: message,
      );

  bool get isSuccess    => outcome == PayoutOutcome.success;
  bool get isAmbiguous  => outcome == PayoutOutcome.ambiguous;
  bool get isDefinitive => outcome == PayoutOutcome.definitive;
}

// ─── Service ──────────────────────────────────────────────────────────────────

class PayoutApiService {
  static const int _timeoutSeconds = 30;

  /// Posts a payout to the backend.
  ///
  /// Bypasses [ApiMethod] deliberately so that 5xx responses and network-layer
  /// exceptions can be classified as [PayoutOutcome.ambiguous] instead of
  /// silently returning null — which would be indistinguishable from a clean
  /// 4xx rejection at the controller level.
  ///
  /// [bearerHeaderInfo] (from api_method.dart) is still reused for the auth
  /// header so token handling stays in one place.
  static Future<PayoutResult> submitPayout(
      Map<String, dynamic> body) async {
    try {
      final headers = await bearerHeaderInfo();
      if (headers.isEmpty) {
        // bearerHeaderInfo already forced logout + navigation to login.
        return PayoutResult.definitive('Session expired. Please log in again.');
      }

      if (kDebugMode) {
        _log.i('POST payout → ${ApiEndpoint.moneyOutSubmitURL}');
        _log.i('Payload keys: ${body.keys.join(', ')}');
      }

      final response = await http
          .post(
            Uri.parse(
              '${ApiEndpoint.moneyOutSubmitURL}'
              '?lang=${languageSettingsController.selectedLanguage.value}',
            ),
            body: jsonEncode(body),
            headers: headers,
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (kDebugMode) _log.i('Payout response: ${response.statusCode}');

      // ── Confirmed success ──────────────────────────────────────────────
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return PayoutResult.success(CommonSuccessModel.fromJson(decoded));
      }

      // ── Ambiguous: server accepted the TCP connection but errored while
      //    writing to the ledger. We cannot confirm the transaction failed. ──
      if (response.statusCode >= 500) {
        _log.e('5xx payout response: ${response.statusCode}');
        return PayoutResult.ambiguous(
          'The payment server returned an error (${response.statusCode}). '
          'Your transfer may still be queued on our ledger.',
        );
      }

      // ── Auth error: session expired mid-flow ───────────────────────────
      if (response.statusCode == 401 || response.statusCode == 403) {
        return PayoutResult.definitive(
          'Your session expired. Please log in and try again.',
        );
      }

      // ── Definitive 4xx rejection: transaction was NOT written ──────────
      String errorMessage =
          'Transfer was declined. Please check your details and try again.';
      try {
        if (response.body.isNotEmpty) {
          final err = ErrorResponse.fromJson(
              jsonDecode(response.body) as Map<String, dynamic>);
          final first = err.message?.error?.first;
          if (first != null && first.isNotEmpty) errorMessage = first;
        }
      } catch (_) {}
      return PayoutResult.definitive(errorMessage);

    } on SocketException catch (e) {
      _log.e('SocketException on payout submit: $e');
      return PayoutResult.ambiguous(
        'Network connection dropped mid-request. '
        'Your transfer may still be processing on our servers.',
      );
    } on TimeoutException catch (e) {
      _log.e('TimeoutException on payout submit (${_timeoutSeconds}s): $e');
      return PayoutResult.ambiguous(
        'Request timed out after ${_timeoutSeconds}s. '
        'Your transfer may still be processing.',
      );
    } on http.ClientException catch (e) {
      _log.e('ClientException on payout submit: $e');
      return PayoutResult.ambiguous(
        'Connection was interrupted. '
        'Your transfer may still be processing.',
      );
    } catch (e) {
      _log.e('Unexpected error on payout submit: $e');
      // Unknown failures are treated as ambiguous — safer for the user than
      // telling them it failed when the server may have written the entry.
      return PayoutResult.ambiguous(
        'An unexpected error occurred. '
        'Your transfer may still be processing.',
      );
    }
  }
}
