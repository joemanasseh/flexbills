import 'package:adescrow_app/utils/basic_screen_imports.dart';

import '../backend/backend_utils/custom_snackbar.dart';
import '../backend/backend_utils/logger.dart';
import '../backend/models/dashboard/home_model.dart' as home;
import '../backend/models/money_out/money_out_index_model.dart';
import '../backend/services/money_out_api_service.dart';
import '../backend/services/payout_api_service.dart';
import '../routes/routes.dart';
import '../utils/currency_flag_util.dart';

final log = logger(PayoutController);

class PayoutController extends GetxController with MoneyOutApiService {

  // ─── Arguments ────────────────────────────────────────────────────────────
  // The originating wallet is passed as a route argument from the wallet list.
  final home.UserWallet wallet = Get.arguments;

  // ─── Form controllers ─────────────────────────────────────────────────────
  final amountController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // ─── Selected wallet state ────────────────────────────────────────────────
  late RxString selectedCurrency;
  late RxString selectedCurrencyType;
  late RxDouble selectedCurrencyRate;
  late RxString selectedCurrencyImage;

  // ─── Selected gateway / payout method state ───────────────────────────────
  late RxString selectedMethodID;
  late RxString selectedMethodAlias;
  late RxString selectedMethodType;
  late RxString selectedMethodCurrencyCode;
  late RxDouble selectedMethodMax;
  late RxDouble selectedMethodMin;
  late RxDouble selectedMethodPCharge;
  late RxDouble selectedMethodFCharge;
  late RxDouble selectedMethodRate;

  // ─── Derived exchange values ───────────────────────────────────────────────
  final exchangeRate = 0.0.obs;
  final min = 0.0.obs;
  final max = 0.0.obs;

  // ─── Page-load state ──────────────────────────────────────────────────────
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  late MoneyOutIndexModel _indexModel;
  MoneyOutIndexModel get indexModel => _indexModel;

  // ─── Pending-First transfer state ─────────────────────────────────────────

  /// True while a submission is in flight OR after an ambiguous failure.
  /// The UI binds to this to lock every interactive element on the confirm
  /// screen, preventing double-tap re-submissions.
  final isSubmitting = false.obs;

  /// The client-generated idempotency key attached to the current submission
  /// attempt. Exposed so the pending screen can display it to the user and
  /// support can trace it server-side.
  final _pendingRef = ''.obs;
  String get pendingRef => _pendingRef.value;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _fetchIndex();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  // ─── Index / setup ────────────────────────────────────────────────────────

  Future<void> _fetchIndex() async {
    _isLoading.value = true;
    update();
    try {
      final value = await moneyOutIndexAPi();
      if (value == null) return;
      _indexModel = value;
      _seedSelectionFromWallet();
      _recalcLimits();
      update();
    } catch (e) {
      log.e('_fetchIndex error: $e');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  void _seedSelectionFromWallet() {
    selectedCurrency      = wallet.currencyCode.obs;
    selectedCurrencyType  = wallet.currencyType.obs;
    selectedCurrencyRate  = wallet.rate.obs;
    selectedCurrencyImage = flagUrl(wallet.currencyCode).obs;

    final gw = _indexModel.data.gatewayCurrencies.first;
    selectedMethodID           = gw.paymentGatewayId.toString().obs;
    selectedMethodAlias        = gw.alias.obs;
    selectedMethodType         = gw.mType.obs;
    selectedMethodCurrencyCode = gw.mCurrencyCode.obs;
    selectedMethodMax          = gw.maxLimit.obs;
    selectedMethodMin          = gw.minLimit.obs;
    selectedMethodPCharge      = gw.percentCharge.obs;
    selectedMethodFCharge      = gw.fixedCharge.obs;
    selectedMethodRate         = gw.mRate.obs;
  }

  void _recalcLimits() {
    exchangeRate.value =
        (1 / selectedCurrencyRate.value) * selectedMethodRate.value;
    min.value = selectedMethodMin.value / exchangeRate.value;
    max.value = selectedMethodMax.value / exchangeRate.value;
  }

  // ─── Reference generation ─────────────────────────────────────────────────

  /// Builds a device-local idempotency key for a single submission attempt.
  ///
  /// Format: `FLX-MO-MOBI-{millisecondsSinceEpoch}`
  ///
  /// The millisecond epoch gives a monotonically increasing, collision-resistant
  /// string without any dependency on UUIDs or external packages. It is sent
  /// in the payload so the backend can deduplicate retries and support can
  /// look up the original attempt if the user calls in with a pending transfer.
  static String _buildLocalRef() =>
      'FLX-MO-MOBI-${DateTime.now().millisecondsSinceEpoch}';

  // ─── Pending-First Transfer Pipeline ─────────────────────────────────────

  /// Entry point wired to the final "Confirm Transfer" button.
  ///
  /// Pipeline:
  ///  1. Re-entrancy guard — silently drops concurrent taps.
  ///  2. Generate and store a local reference for this attempt.
  ///  3. Lock the UI (`isSubmitting = true`) before the network hop.
  ///  4. Build the payload with all values serialised as strings
  ///     (no third-party serialisers; mirrors the hand-written fromJson
  ///     convention used across the project).
  ///  5. Dispatch via [PayoutApiService.submitPayout] which distinguishes
  ///     ambiguous from definitive failures at the HTTP layer.
  ///  6a. Success   → clear lock, navigate to dashboard with confirmation.
  ///  6b. Ambiguous → keep lock, offload to pending screen with ref + context.
  ///  6c. Definitive → clear lock, surface inline error, keep form intact.
  Future<void> confirmTransfer() async {
    // ── 1. Re-entrancy guard ───────────────────────────────────────────────
    if (isSubmitting.value) return;

    // ── 2. Generate reference ─────────────────────────────────────────────
    _pendingRef.value = _buildLocalRef();

    // ── 3. Lock UI ────────────────────────────────────────────────────────
    isSubmitting.value = true;
    update();

    // ── 4. Build payload (all values are strings; no type coercion needed
    //       because TextEditingController.text and .obs strings are already
    //       String — matches how the existing money_out services serialize) ──
    final Map<String, dynamic> payload = {
      'amount'          : amountController.text,
      'sender_currency' : selectedCurrency.value,
      'gateway_currency': selectedMethodAlias.value,
      'client_ref'      : _pendingRef.value,
    };

    log.i('confirmTransfer → ref: ${_pendingRef.value}  payload: $payload');

    // ── 5. Network hop ────────────────────────────────────────────────────
    final result = await PayoutApiService.submitPayout(payload);

    // ── 6a. Success ───────────────────────────────────────────────────────
    if (result.isSuccess) {
      isSubmitting.value = false;
      update();

      final serverMessage = result.data?.message?.success?.firstOrNull
          ?? 'Transfer submitted successfully.';
      CustomSnackBar.success(serverMessage);

      Get.offAllNamed(Routes.dashboardScreen);
      return;
    }

    // ── 6b. Ambiguous: network dropped / timeout / 5xx ───────────────────
    // The transaction state on the server is UNKNOWN.
    // Rules:
    //   • DO NOT clear amountController or any form state.
    //   • DO NOT reset isSubmitting — the form stays locked to prevent
    //     the user re-submitting the same amount with a new reference.
    //   • Navigate away via offAllNamed so back-navigation cannot reach
    //     the confirm screen.
    if (result.isAmbiguous) {
      log.w('Ambiguous result for ref ${_pendingRef.value}: ${result.message}');

      Get.offAllNamed(
        Routes.payoutPendingScreen,
        arguments: {
          'ref'      : _pendingRef.value,
          'amount'   : amountController.text,
          'currency' : selectedCurrency.value,
          'message'  : result.message,
        },
      );
      return;
    }

    // ── 6c. Definitive rejection ──────────────────────────────────────────
    // The server cleanly rejected the request (4xx). The transaction was
    // NOT written. Unlock the UI so the user can correct and retry.
    log.e('Definitive rejection for ref ${_pendingRef.value}: ${result.message}');

    isSubmitting.value = false;
    update();
    CustomSnackBar.error(result.message);
  }

  // ─── Amount validation ────────────────────────────────────────────────────

  /// True when the entered amount is within the gateway's computed limits.
  bool get isAmountValid {
    final parsed = double.tryParse(amountController.text);
    if (parsed == null || parsed <= 0) return false;
    return parsed >= min.value && parsed <= max.value;
  }
}
