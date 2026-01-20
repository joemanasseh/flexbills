import 'package:adescrow_app/utils/basic_screen_imports.dart';

import '../../../backend/backend_utils/logger.dart';
import '../../../backend/models/dashboard/home_model.dart';
import '../../../backend/services/api_services.dart';

final log = logger(HomeController);

class HomeController extends GetxController{
RxInt openTileIndex = (-1).obs;

  @override
  void onInit() {
    homeDataFetch();
    super.onInit();
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  late HomeModel _homeModel;
  HomeModel get homeModel => _homeModel;

  Future<HomeModel> homeDataFetch() async{
    _isLoading.value = true;
    update();

    await ApiServices.dashboardAPi().then((value) {
      _homeModel = value!;
      update();
    }).catchError((onError) {
      log.e(onError);
    });
    _isLoading.value = false;
    update();

    return _homeModel;
  }
}