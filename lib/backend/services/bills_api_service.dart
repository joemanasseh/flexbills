import '../backend_utils/api_method.dart';
import '../backend_utils/custom_snackbar.dart';
import '../backend_utils/logger.dart';
import '../models/bills/bill_categories_model.dart';
import '../models/bills/bill_payment_model.dart';
import '../models/bills/bill_status_model.dart';
import '../models/bills/bill_validate_model.dart';
import 'api_endpoint.dart';

final _log = logger(BillsApiService);

class BillsApiService {
  /// Fetch bill categories from backend (Flutterwave proxy).
  /// Pass [category] to filter by type (e.g., 'AIRTIME', 'DATA').
  static Future<BillCategoriesModel?> fetchCategories({
    String? category,
  }) async {
    try {
      final url = category != null
          ? '${ApiEndpoint.billsBillersURL}/$category'
          : ApiEndpoint.billsBillersURL;
      final response = await ApiMethod(isBasic: false).get(
        url,
        code: 200,
        showResult: false,
      );
      if (response != null) {
        return BillCategoriesModel.fromJson(response);
      }
    } catch (e) {
      _log.e('fetchCategories error: $e');
      CustomSnackBar.error('Failed to load billers. Please try again.');
    }
    return null;
  }

  /// Validate a customer ID (meter number, smartcard, phone, etc.)
  static Future<BillValidateModel?> validateCustomer({
    required String billerCode,
    required String itemCode,
    required String customer,
  }) async {
    try {
      final response = await ApiMethod(isBasic: false).post(
        ApiEndpoint.billsValidateURL,
        {
          'biller_code': billerCode,
          'item_code': itemCode,
          'customer': customer,
        },
        code: 200,
        showResult: false,
      );
      if (response != null) {
        return BillValidateModel.fromJson(response);
      }
    } catch (e) {
      _log.e('validateCustomer error: $e');
      CustomSnackBar.error('Validation failed. Check the ID and try again.');
    }
    return null;
  }

  /// Submit a bill payment.
  /// [body] must include: country, customer, amount, biller_code, item_code, reference, phone
  static Future<BillPaymentModel?> payBill({
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await ApiMethod(isBasic: false).post(
        ApiEndpoint.billsPayURL,
        body,
        code: 200,
        showResult: true,
      );
      if (response != null) {
        return BillPaymentModel.fromJson(response);
      }
    } catch (e) {
      _log.e('payBill error: $e');
      CustomSnackBar.error('Payment failed. Please try again.');
    }
    return null;
  }

  /// Poll for transaction status by [reference].
  static Future<BillStatusModel?> checkStatus({
    required String reference,
  }) async {
    try {
      final response = await ApiMethod(isBasic: false).get(
        '${ApiEndpoint.billsStatusURL}/$reference',
        code: 200,
        showResult: false,
      );
      if (response != null) {
        return BillStatusModel.fromJson(response);
      }
    } catch (e) {
      _log.e('checkStatus error: $e');
    }
    return null;
  }
}
