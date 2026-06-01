
import 'package:adescrow_app/backend/local_storage/local_storage.dart';

import '../../backend/backend_utils/logger.dart';
import '../../backend/models/auth/forgot_send_otp_model.dart';
import '../../backend/models/auth/login_model.dart';
import '../../backend/services/api_services.dart';
import '../../routes/routes.dart';
import '../../utils/basic_widget_imports.dart';


final log = logger(LoginController);

class LoginController extends GetxController{
  final formKey = GlobalKey<FormState>();
  final forgotPassFormKey = GlobalKey<FormState>();


  final forgotEmailController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotEmailController.dispose();
    super.dispose();
  }





  onLoginProcess() async{
    if(formKey.currentState!.validate()){
      await signInProcess();
    }
  }

  /*--------------------------- Api function start ----------------------------------*/
  // Sign in process function
  final _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  Future<void> signInProcess() async {
    _isLoading.value = true;
    update();

    final Map<String, dynamic> inputBody = {
      'email': emailController.text.trim(),
      'password': passwordController.text,
    };

    try {
      final value = await ApiServices.signInApi(body: inputBody);
      if (value == null) {
        _isLoading.value = false;
        update();
        return;
      }

      final int kycVerified = value.data.user.kycVerified;
      final int twoFaStatus = value.data.user.twoFactorStatus;
      final int twoFaVerified = value.data.user.twoFactorVerified;

      await LocalStorage.saveToken(token: value.data.token);

      if (value.data.user.emailVerified == 0) {
        Get.toNamed(Routes.registerOTPScreen);
      } else if (kycVerified == 0) {
        Get.toNamed(Routes.kycFormScreen);
      } else if (twoFaStatus == 1 && twoFaVerified == 0) {
        Get.toNamed(Routes.faVerifyScreen);
      } else {
        await _goToSavedUser(value);
      }
    } catch (e) {
      log.e(e);
    }

    _isLoading.value = false;
    update();
  }

  Future<void> _goToSavedUser(LoginModel signInModel) async {
    await LocalStorage.isLoginSuccess(isLoggedIn: true);
    await LocalStorage.saveEmail(email: emailController.text.trim());
    Get.offAllNamed(Routes.dashboardScreen);
  }


  void onForgotPassProcess() async{
    if(forgotPassFormKey.currentState!.validate()) {
      await sendOTPProcess().then((value) {
        if(value != null) {
        }
      });
    }
  }

  final _isForgotLoading = false.obs;
  bool get isForgotLoading => _isForgotLoading.value;

  late ForgetSendOtpModel? _forgotModel;
  ForgetSendOtpModel? get forgotModel => _forgotModel;

  late RxString token;

  Future<ForgetSendOtpModel?> sendOTPProcess() async {
    _isForgotLoading.value = true;
    update();

    Map<String, dynamic> inputBody = {
      'credentials': forgotEmailController.text,
    };

    await ApiServices.forgotPasswordSendOTPApi(body: inputBody).then((value) {
      _forgotModel = value!;
      token = _forgotModel!.data.user.token.obs;
      Get.toNamed(Routes.forgotOTPScreen);
      update();
    }).catchError((onError) {
      log.e(onError);
    });

    _isForgotLoading.value = false;
    update();
    return _forgotModel;
  }


  goToRegisterScreen() {
    Get.toNamed(Routes.registerScreen);
  }
}