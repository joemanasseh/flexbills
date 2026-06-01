import '../backend_utils/api_method.dart';
import '../backend_utils/custom_snackbar.dart';
import '../backend_utils/logger.dart';
import '../models/exchange_rate_model.dart';
import 'api_endpoint.dart';

final _log = logger(ExchangeApiService);

class ExchangeApiService {
  /// Fetches the all-inclusive live rate for [from] → [to].
  /// Returns null on any network or parsing failure (error already surfaced
  /// to the user by ApiMethod / the catch block below).
  static Future<ExchangeRateModel?> fetchLiveRate(
      String from, String to) async {
    Map<String, dynamic>? mapResponse;
    try {
      mapResponse = await ApiMethod(isBasic: false).get(
        '${ApiEndpoint.exchangeRateURL}?from=$from&to=$to',
        code: 200,
        showResult: false,
      );
      if (mapResponse != null) {
        return ExchangeRateModel.fromJson(mapResponse);
      }
    } catch (e) {
      _log.e('🐞🐞🐞 err from ExchangeApiService.fetchLiveRate ==> $e 🐞🐞🐞');
      CustomSnackBar.error('Could not fetch exchange rate. Please try again.');
      return null;
    }
    return null;
  }
}
