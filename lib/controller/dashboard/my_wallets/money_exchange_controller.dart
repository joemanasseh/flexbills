import 'package:adescrow_app/utils/basic_screen_imports.dart';

import '../../../backend/backend_utils/custom_snackbar.dart';
import '../../../backend/backend_utils/logger.dart';
import '../../../backend/models/common/common_success_model.dart';
import '../../../backend/models/exchange_rate_model.dart';
import '../../../backend/models/money_exchange/money_exchange_index_model.dart';
import '../../../backend/services/exchange_api_service.dart';
import '../../../backend/services/money_exchange_api_service.dart';
import '../../../routes/routes.dart';
import '../../../views/confirm_screen.dart';

final log = logger(MoneyExchangeController);

class MoneyExchangeController extends GetxController with MoneyExchangeApiService {

  final fromAmountController = TextEditingController();
  final toAmountController   = TextEditingController();

  // ─── Observable TO display (TextEditingController.text is not reactive) ───
  final toAmountDisplay = ''.obs;

  // ─── Selected currencies ──────────────────────────────────────────────────
  final fromSelectedCurrency     = ''.obs;
  final fromSelectedCurrencyType = ''.obs;
  final fromSelectedCurrencyRate = 0.0.obs;

  final toSelectedCurrency     = '--'.obs;
  final toSelectedCurrencyType = ''.obs;
  final toSelectedCurrencyRate = 0.0.obs;

  // ─── Derived rate & limits ────────────────────────────────────────────────
  final exchangeRate = 0.0.obs;
  final min = 0.0.obs;
  final max = 0.0.obs;

  // Kept for preview screen — never shown on the entry screen.
  final pCharge = 0.0.obs;
  final fCharge = 0.0.obs;
  final tCharge = 0.0.obs;

  // ─── Live rate (background freshness layer) ───────────────────────────────
  final _liveRate = Rx<ExchangeRateModel?>(null);
  final _isRateFetching = false.obs;
  bool get isRateFetching => _isRateFetching.value;

  // ─── Gate ─────────────────────────────────────────────────────────────────
  bool get canExchange =>
      exchangeRate.value > 0 &&
      (_liveRate.value == null || !_liveRate.value!.isExpired);

  // ─── Page load state ──────────────────────────────────────────────────────
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  MoneyExchangeIndexModel? _moneyExchangeModel;
  MoneyExchangeIndexModel get moneyExchangeModel => _moneyExchangeModel!;
  bool get hasModel => _moneyExchangeModel != null;

  static const _sendCurrencies = ['USD', 'EUR', 'GBP', 'CHF'];

  List<UserWallet> get fromWallets => _moneyExchangeModel?.data.userWallet
          .where((w) => _sendCurrencies.contains(w.currencyCode))
          .toList() ??
      [];

  List<UserWallet> get toWallets => _moneyExchangeModel?.data.userWallet
          .where((w) => !_sendCurrencies.contains(w.currencyCode))
          .toList() ??
      [];

  // ─── Not-late nullable — avoids LateInitializationError on submit failure ─
  CommonSuccessModel? _successModel;
  CommonSuccessModel? get successModel => _successModel;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    moneyExchangeFetch();
  }

  @override
  void dispose() {
    fromAmountController.dispose();
    toAmountController.dispose();
    super.dispose();
  }

  // ─── Rate calculation ─────────────────────────────────────────────────────

  void calculateExchangeRate() {
    if (!hasModel) return;

    final fromRate = double.parse(fromSelectedCurrencyRate.value.toString());
    final toRate   = double.parse(toSelectedCurrencyRate.value.toString());

    // Prefer live rate if fresh; otherwise cross-rate from wallet data.
    if (_liveRate.value != null && !_liveRate.value!.isExpired) {
      exchangeRate.value =
          double.parse(_liveRate.value!.allInclusiveRate.toString());
    } else if (fromRate > 0) {
      exchangeRate.value = toRate / fromRate;
    } else {
      exchangeRate.value = 0.0;
    }

    final charges = _moneyExchangeModel!.data.charges;
    min.value = double.parse(charges.minLimit.toString()) * fromRate;
    max.value = double.parse(charges.maxLimit.toString()) * fromRate;
    fCharge.value =
        double.parse(charges.fixedCharge.toString()) * fromRate;

    if (fromAmountController.text.isNotEmpty) {
      final amount = double.tryParse(fromAmountController.text) ?? 0.0;
      final converted = amount * exchangeRate.value;
      final decimals = toSelectedCurrencyType.value == 'FIAT' ? 2 : 6;
      final formatted = converted.toStringAsFixed(decimals);

      // Sync both the TextEditingController (used by preview) and the
      // observable (used by the reactive TO display widget on this screen).
      toAmountController.text = formatted;
      toAmountDisplay.value   = formatted;

      pCharge.value =
          (amount / 100) * double.parse(charges.percentCharge.toString());
      tCharge.value = pCharge.value + fCharge.value;
    } else {
      tCharge.value = fCharge.value;
      toAmountController.clear();
      toAmountDisplay.value = '';
    }

    update();
  }

  /// Instant recalc from wallet rates + background live-rate fetch.
  Future<void> onCurrencyChanged() async {
    calculateExchangeRate();

    if (fromSelectedCurrency.value.isEmpty ||
        toSelectedCurrency.value == '--') return;

    _isRateFetching.value = true;
    update();

    try {
      final fresh = await ExchangeApiService.fetchLiveRate(
        fromSelectedCurrency.value,
        toSelectedCurrency.value,
      );
      if (fresh != null) {
        _liveRate.value = fresh;
        calculateExchangeRate();
      }
    } catch (_) {}

    _isRateFetching.value = false;
    update();
  }

  // ─── Initial fetch ────────────────────────────────────────────────────────

  Future<void> moneyExchangeFetch() async {
    _isLoading.value = true;
    update();

    try {
      final value = await moneyExchangeInfoAPi();
      if (value == null) return;
      _moneyExchangeModel = value;

      final from = fromWallets.isNotEmpty
          ? fromWallets.first
          : _moneyExchangeModel!.data.userWallet.first;
      final to = toWallets.isNotEmpty
          ? toWallets.first
          : _moneyExchangeModel!.data.userWallet.last;

      fromSelectedCurrency.value     = from.currencyCode;
      fromSelectedCurrencyType.value = from.currencyType;
      fromSelectedCurrencyRate.value =
          double.parse(from.rate.toString());

      toSelectedCurrency.value     = to.currencyCode;
      toSelectedCurrencyType.value = to.currencyType;
      toSelectedCurrencyRate.value =
          double.parse(to.rate.toString());

      await onCurrencyChanged();
    } catch (e) {
      log.e('moneyExchangeFetch: $e');
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void onExchangeBTNProcess(BuildContext context) {
    if (!canExchange) {
      CustomSnackBar.error('Exchange rate unavailable. Please wait…');
      return;
    }
    if (fromAmountController.text.isEmpty) {
      CustomSnackBar.error(Strings.enterAmount);
      return;
    }
    if (fromSelectedCurrency.value == toSelectedCurrency.value) {
      CustomSnackBar.error(Strings.exchangeMSG);
      return;
    }
    final amount = double.tryParse(fromAmountController.text) ?? 0.0;
    if (max.value > 0 && (amount < min.value || amount > max.value)) {
      CustomSnackBar.error(Strings.limitMSG);
      return;
    }
    Get.toNamed(Routes.moneyExchangeScreenPreview);
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> onConfirmProcess(BuildContext context) async {
    await submitProcess().then((value) {
      if (value != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConfirmScreen(
              message: Strings.exchangeConfirmationMSG,
              onApproval: true,
              onOkayTap: () => Get.offAllNamed(Routes.dashboardScreen),
            ),
          ),
        );
      }
    });
  }

  Future<CommonSuccessModel?> submitProcess() async {
    _isLoading.value = true;
    update();

    try {
      _successModel = await moneyExchangeSubmitApi(body: {
        'exchange_from_amount'  : fromAmountController.text,
        'exchange_from_currency': fromSelectedCurrency.value,
        'exchange_to_currency'  : toSelectedCurrency.value,
      });
    } catch (e) {
      log.e('submitProcess: $e');
    } finally {
      _isLoading.value = false;
      update();
    }
    return _successModel;
  }
}
