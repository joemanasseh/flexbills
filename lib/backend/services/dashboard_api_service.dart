import '../backend_utils/api_method.dart';
import '../backend_utils/custom_snackbar.dart';
import '../backend_utils/logger.dart';
import '../models/dashboard/notification_model.dart';
import 'api_endpoint.dart';

final log = logger(DashboardApiService);

mixin DashboardApiService {
  Future<NotificationModel?> notificationAPi() async {
    Map<String, dynamic>? mapResponse;
    try {
      mapResponse = await ApiMethod(isBasic: false).get(
        ApiEndpoint.notificationURL ,
        code: 200,
      );
      if (mapResponse != null) {
        NotificationModel modelData = NotificationModel.fromJson(mapResponse);

        return modelData;
      }
    } catch (e) {
      log.e('🐞🐞🐞 err from Notification Model api service ==> $e 🐞🐞🐞');
      CustomSnackBar.error('Something went Wrong!');
      return null;
    }
    return null;
  }

}
