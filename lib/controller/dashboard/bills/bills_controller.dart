import 'dart:async';

import 'package:adescrow_app/backend/backend_utils/custom_snackbar.dart';
import 'package:adescrow_app/backend/models/bills/bill_categories_model.dart';
import 'package:adescrow_app/backend/models/bills/bill_payment_model.dart';
import 'package:adescrow_app/backend/models/bills/bill_status_model.dart';
import 'package:adescrow_app/backend/services/bills_api_service.dart';
import 'package:adescrow_app/routes/routes.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';

class BillsController extends GetxController {
  // ─────────────────────── Search ───────────────────────────────────────────
  final searchController = TextEditingController();
  final searchQuery = ''.obs;

  void onSearchChanged(String v) => searchQuery.value = v;

  // ─────────────────────── Selected category ────────────────────────────────
  final selectedCategoryType = ''.obs;
  final selectedCategoryName = ''.obs;

  // ─────────────────────── Billers list (per category) ──────────────────────
  final _isLoadingBillers = false.obs;
  bool get isLoadingBillers => _isLoadingBillers.value;

  final billers = <BillCategoryData>[].obs;
  final selectedBiller = Rx<BillCategoryData?>(null);

  Future<void> fetchBillers(String categoryType) async {
    _isLoadingBillers.value = true;
    billers.clear();
    selectedBiller.value = null;
    resetForm();
    final result =
        await BillsApiService.fetchCategories(category: categoryType);
    if (result != null && result.status == 'success') {
      billers.assignAll(result.data);
    }
    _isLoadingBillers.value = false;
  }

  void selectBiller(BillCategoryData biller) {
    selectedBiller.value = biller;
    resetValidation();
    amountController.text =
        biller.isVariableAmount ? '' : biller.amount.toStringAsFixed(2);
  }

  // ─────────────────────── Form fields ──────────────────────────────────────
  final customerController = TextEditingController();
  final amountController = TextEditingController();
  final phoneController = TextEditingController();

  void resetForm() {
    customerController.clear();
    amountController.clear();
    phoneController.clear();
    resetValidation();
  }

  // ─────────────────────── Validation ───────────────────────────────────────
  final _isValidating = false.obs;
  bool get isValidating => _isValidating.value;

  final _isValidated = false.obs;
  bool get isValidated => _isValidated.value;

  final validatedName = ''.obs;
  final validatedAddress = ''.obs;

  void resetValidation() {
    _isValidated.value = false;
    validatedName.value = '';
    validatedAddress.value = '';
  }

  Future<void> validateCustomer() async {
    final biller = selectedBiller.value;
    if (biller == null) return;
    final customer = customerController.text.trim();
    if (customer.isEmpty) {
      CustomSnackBar.error('Please enter ${biller.labelName}');
      return;
    }
    _isValidating.value = true;
    resetValidation();

    final result = await BillsApiService.validateCustomer(
      billerCode: biller.billerCode,
      itemCode: biller.itemCode,
      customer: customer,
    );

    if (result != null && result.isSuccess && result.data != null) {
      _isValidated.value = true;
      validatedName.value = result.data!.name;
      validatedAddress.value = result.data!.address;
      CustomSnackBar.success('Customer verified: ${result.data!.name}');
    } else {
      CustomSnackBar.error(
          result?.message ?? 'Invalid customer ID. Please check and retry.');
    }
    _isValidating.value = false;
  }

  // ─────────────────────── Payment ──────────────────────────────────────────
  final _isPaying = false.obs;
  bool get isPaying => _isPaying.value;

  final paymentReference = ''.obs;
  BillPaymentData? lastPaymentData;
  final _lastStatusData = Rx<BillStatusData?>(null);
  BillStatusData? get lastStatusData => _lastStatusData.value;

  Future<void> initiatePayment() async {
    final biller = selectedBiller.value;
    if (biller == null) return;

    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      CustomSnackBar.error('Please enter a valid amount.');
      return;
    }

    _isPaying.value = true;
    final ref = 'FLX-${DateTime.now().millisecondsSinceEpoch}';

    final result = await BillsApiService.payBill(body: {
      'country': 'NG',
      'customer': customerController.text.trim(),
      'amount': amount,
      'biller_code': biller.billerCode,
      'item_code': biller.itemCode,
      'reference': ref,
      'phone': phoneController.text.trim(),
    });

    _isPaying.value = false;

    if (result != null && result.isSuccess && result.data != null) {
      lastPaymentData = result.data;
      paymentReference.value = result.data!.reference.isNotEmpty
          ? result.data!.reference
          : ref;
      Get.toNamed(Routes.billStatusScreen);
      startPolling();
    }
  }

  // ─────────────────────── Status polling ───────────────────────────────────
  static const int _maxPolls = 24; // 2 min at 5s each
  static const Duration _pollInterval = Duration(seconds: 5);

  int _pollCount = 0;
  Timer? _pollingTimer;

  final paymentStatus = 'pending'.obs; // 'pending' | 'successful' | 'failed'

  void startPolling() {
    _pollCount = 0;
    paymentStatus.value = 'pending';
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _poll());
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _poll() async {
    final ref = paymentReference.value;
    if (ref.isEmpty) {
      stopPolling();
      return;
    }
    _pollCount++;

    final result = await BillsApiService.checkStatus(reference: ref);
    if (result?.data != null) {
      if (result!.data!.isSuccessful) {
        _lastStatusData.value = result.data;
        paymentStatus.value = 'successful';
        stopPolling();
        return;
      } else if (result.data!.isFailed) {
        paymentStatus.value = 'failed';
        stopPolling();
        return;
      }
    }

    if (_pollCount >= _maxPolls) {
      paymentStatus.value = 'failed';
      stopPolling();
    }
  }

  // ─────────────────────── Navigation helpers ───────────────────────────────
  void openCategory(String type, String name) {
    selectedCategoryType.value = type;
    selectedCategoryName.value = name;
    fetchBillers(type);
    Get.toNamed(Routes.billBillerScreen);
  }

  void openBillerForm(BillCategoryData biller) {
    selectBiller(biller);
    Get.toNamed(Routes.billFormScreen);
  }

  void goToPreview() {
    Get.toNamed(Routes.billPreviewScreen);
  }

  void resetAndGoHome() {
    stopPolling();
    resetForm();
    selectedBiller.value = null;
    selectedCategoryType.value = '';
    paymentStatus.value = 'pending';
    paymentReference.value = '';
    _lastStatusData.value = null;
    Get.until((r) => r.settings.name == Routes.dashboardScreen);
  }

  @override
  void onClose() {
    stopPolling();
    searchController.dispose();
    customerController.dispose();
    amountController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
