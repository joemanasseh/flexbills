import 'package:adescrow_app/extensions/custom_extensions.dart';

class ApiEndpoint {
  static const String mainDomain = "https://flexbills.com.ng";
  static const String baseUrl = "$mainDomain/api/v1";
  static String appSettingsURL = '/app-settings'.addBaseURl();
  static String languageURL = '/app-settings/languages'.addBaseURl();

  static String loginURL = '/user/login'.addBaseURl();
  static String forgotSendOTPURL =
      '/user/forgot/password/send/otp'.addBaseURl();
  static String forgotVerifyOTPURL =
      '/user/forgot/password/verify'.addBaseURl();
  static String resetPasswordURL = '/user/forgot/password/reset'.addBaseURl();

  /*signup section*/
  static String registrationURL = '/user/register'.addBaseURl();
  static String emailVerificationURL = '/user/email/otp/verify'.addBaseURl();
  static String signUpResendOtpURL = '/user/email/resend/code'.addBaseURl();
  static String kycFieldsURL = '/user/kyc/input-fields'.addBaseURl();
  static String kycSubmitURL = '/user/kyc/submit'.addBaseURl();

  // dashboard
  static String logOutURL = '/user/logout'.addBaseURl();
  static String deleteURL = '/user/profile/delete/account'.addBaseURl();

  static String dashboardURL = '/user/dashboard'.addBaseURl();
  static String notificationURL = '/user/user-notification'.addBaseURl();
  static String profileURL = '/user/profile'.addBaseURl();
  static String profileUpdateURL = '/user/profile/update'.addBaseURl();
  static String profileTypeUpdateURL = '/user/profile/type/update'.addBaseURl();
  static String changePasswordURL =
      '/user/profile/password/update'.addBaseURl();

  static String faFetchURL = '/user/profile/google-2fa'.addBaseURl();
  static String faStatusUpdateURL =
      '/user/profile/google-2fa/status/update'.addBaseURl();
  static String faVerifyURL = '/user/verify/google-2fa'.addBaseURl();

  static String addMoneyIndexURL = '/user/add-money/index'.addBaseURl();
  static String addMoneySubmitURL = '/user/add-money/submit'.addBaseURl();
  static String addMoneyManualConfirmURL =
      '/user/add-money/manual/payment/confirmed'.addBaseURl();

  static String moneyOutIndexURL = '/user/money-out/index'.addBaseURl();
  static String moneyOutSubmitURL = '/user/money-out/submit'.addBaseURl();
  static String moneyOutConfirmURL =
      '/user/money-out/manual/confirmed'.addBaseURl();

  static String moneyExchangeURL = '/user/money-exchange'.addBaseURl();
  static String moneyExchangeSubmitURL =
      '/user/money-exchange/submit'.addBaseURl();
  static String exchangeRateURL = '/user/exchange/live-rate'.addBaseURl();

  // Bills (Flutterwave via backend proxy)
  static String billsBillersURL = '/bills/NG/billers'.addBaseURl();
  static String billsValidateURL = '/user/bills/validate'.addBaseURl();
  static String billsPayURL = '/user/bills/pay'.addBaseURl();
  static String billsStatusURL = '/user/bills/status'.addBaseURl();

}
