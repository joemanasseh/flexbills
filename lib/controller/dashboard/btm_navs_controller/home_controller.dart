import 'package:adescrow_app/utils/basic_screen_imports.dart';

import '../../../backend/backend_utils/logger.dart';
import '../../../backend/models/dashboard/home_model.dart';
import '../../../backend/services/api_services.dart';
import '../../../backend/services/profile_api_services.dart';

final log = logger(HomeController);

class HomeController extends GetxController with ProfileApiService {
  RxInt openTileIndex = (-1).obs;
  final firstname = ''.obs;

  @override
  void onInit() {
    homeDataFetch();
    _fetchFirstname();
    super.onInit();
  }

  Future<void> _fetchFirstname() async {
    try {
      final profile = await profileApi();
      if (profile != null) {
        firstname.value = profile.data.user.firstname;
      }
    } catch (_) {}
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final _hasError = false.obs;
  bool get hasError => _hasError.value;

  HomeModel? _homeModel;
  HomeModel? get homeModel => _homeModel;

  Future<void> homeDataFetch() async {
    _isLoading.value = true;
    _hasError.value = false;
    update();

    try {
      final result = await ApiServices.dashboardAPi();
      if (result != null) {
        _homeModel = result;
      } else {
        _hasError.value = true;
      }
    } catch (e) {
      log.e(e);
      _hasError.value = true;
    }

    _isLoading.value = false;
    update();
  }
}