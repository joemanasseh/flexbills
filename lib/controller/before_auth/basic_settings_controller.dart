import 'package:adescrow_app/backend/services/api_endpoint.dart';
import 'package:get/get.dart';

import '../../backend/backend_utils/logger.dart';
import '../../backend/models/basic_settings_model.dart';
import '../../backend/services/api_services.dart';

final log = logger(BasicSettingsController);

class BasicSettingsController extends GetxController {
  late String splashBGLink;
  late String appIconLink;
  RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    _initializeFallbackLinks();
    basicSettingsFetch();
    super.onInit();
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  BasicSettingModel? _basicSettingModel;
  BasicSettingModel? get basicSettingModel => _basicSettingModel;

  void _initializeFallbackLinks() {
    splashBGLink = "${ApiEndpoint.mainDomain}/assets/splash.png";
    appIconLink = "${ApiEndpoint.mainDomain}/assets/logo.png";
  }

  Future<BasicSettingModel?> basicSettingsFetch() async {
    _isLoading.value = true;
    update();

    try {
      final value = await ApiServices.basicSettingApi();
      if (value != null) {
        _basicSettingModel = value;

        splashBGLink =
            "${ApiEndpoint.mainDomain}/${_basicSettingModel!.data.imagePath}/${_basicSettingModel!.data.splashScreen.splashScreenImage}";
        // onboardBGLink = "${ApiEndpoint.mainDomain}/${_basicSettingModel.data.imagePath}/${_basicSettingModel.data.onboardScreen.first.image}";
        appIconLink =
            "${ApiEndpoint.mainDomain}/${_basicSettingModel!.data.logoImagePath}/${_basicSettingModel!.data.allLogo.siteLogo}";

        update();
      } else {
        log.e('🐞🐞🐞 API returned null 🐞🐞🐞');
        _initializeFallbackLinks();
      }
    } catch (e) {
      log.e('🐞🐞🐞 Error fetching basic settings: $e 🐞🐞🐞');
      _initializeFallbackLinks();
    }
    _isLoading.value = false;
    update();

    return _basicSettingModel;
  }
}
//basicSettingApi

configDriveLink(String link) {
  return 'https://drive.google.com/uc?export=view&id=${link.substring(link.indexOf('/d/') + 3, link.indexOf('/view'))}';
}
