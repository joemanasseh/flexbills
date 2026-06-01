import 'package:get/get.dart';

import '../backend/backend_utils/logger.dart';
import '../backend/models/exchange_rate_model.dart';
import '../backend/services/exchange_api_service.dart';

final _log = logger(ExchangeController);

class ExchangeController extends GetxController {
  // ─── Reactive state ────────────────────────────────────────────────────────

  final sourceAmount = 0.0.obs;
  final targetAmount = 0.0.obs;

  /// Full rate object — exposes baseCurrency, targetCurrency, rateExpiresAt
  /// in addition to the rate itself. Null until the first successful fetch.
  final currentRate = Rx<ExchangeRateModel?>(null);

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  // ─── Convenience getters ───────────────────────────────────────────────────

  /// The all-inclusive rate embedded in the quote. Falls back to 1.0 so the
  /// UI never receives NaN or ±Infinity before the first fetch completes.
  double get allInclusiveRate => currentRate.value?.allInclusiveRate ?? 1.0;

  /// True when the server's rate window has elapsed and a re-fetch is needed.
  bool get rateExpired => currentRate.value?.isExpired ?? true;

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Fetches the live all-inclusive rate for [from] → [to] and stores it.
  /// Re-applies the conversion to any amounts already entered.
  Future<void> loadRate(String from, String to) async {
    _isLoading.value = true;
    update();

    final rate = await ExchangeApiService.fetchLiveRate(from, to);

    if (rate != null) {
      currentRate.value = rate;
      // Re-derive target from whatever source amount is already on screen.
      if (sourceAmount.value > 0) {
        targetAmount.value = _round(sourceAmount.value * rate.allInclusiveRate);
      }
    }

    _isLoading.value = false;
    update();
  }

  /// Bidirectional conversion driven by user input.
  ///
  /// [value]    — raw string from the text field (may be empty or invalid).
  /// [isSource] — true when the user typed in the source field;
  ///              false when the user typed in the target field.
  ///
  /// The all_inclusive_rate already bundles every fee the backend charges, so
  /// no separate fee line items are calculated or exposed here.
  void updateAmounts(String value, bool isSource) {
    final parsed = double.tryParse(value);

    if (parsed == null || parsed < 0) {
      sourceAmount.value = 0.0;
      targetAmount.value = 0.0;
      return;
    }

    if (isSource) {
      sourceAmount.value = parsed;
      targetAmount.value = _round(parsed * allInclusiveRate);
    } else {
      targetAmount.value = parsed;
      // Guard against a zero/unset rate to avoid ±Infinity.
      sourceAmount.value = allInclusiveRate > 0
          ? _round(parsed / allInclusiveRate)
          : 0.0;
    }

    _log.i(
      'updateAmounts: source=${sourceAmount.value}  '
      'target=${targetAmount.value}  rate=$allInclusiveRate',
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Standard Western rounding to exactly 2 decimal places.
  /// Dart's toStringAsFixed uses round-half-away-from-zero for positive values,
  /// which matches the financial convention used throughout the project.
  double _round(double value) => double.parse(value.toStringAsFixed(2));
}
