import 'package:adescrow_app/utils/basic_screen_imports.dart';

import '../../../backend/backend_utils/logger.dart';
import '../../../backend/models/common/common_success_model.dart';
import '../../../backend/models/dashboard/two_fa_info_model.dart';
import '../../../backend/services/two_fa_api_service.dart';

final log = logger(FASecurityController);

class FASecurityController extends GetxController with TwoFaApiService {
  @override
  void onInit() {
    twoFAFetch();
    super.onInit();
  }

  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  TwoFaInfoModel? _twoFaInfoModel;
  TwoFaInfoModel? get twoFaInfoModel => _twoFaInfoModel;

  Future<void> twoFAFetch() async {
    _isLoading.value = true;
    update();
    try {
      final value = await twoFaInfoAPi();
      if (value != null) _twoFaInfoModel = value;
    } catch (e) {
      log.e(e);
    }
    _isLoading.value = false;
    update();
  }

  CommonSuccessModel? _successModel;
  CommonSuccessModel? get successModel => _successModel;

  Future<void> onFASubmitProcess() async {
    if (_twoFaInfoModel == null) return;
    Get.close(1);
    _isLoading.value = true;
    update();
    try {
      final Map<String, dynamic> inputBody = {
        'status': _twoFaInfoModel!.data.qrStatus == 1 ? 0 : 1,
      };
      final value = await twoFaStatusUpdateApi(body: inputBody);
      if (value != null) {
        _successModel = value;
        await twoFAFetch();
      }
    } catch (e) {
      log.e(e);
    }
    update();
  }
}
