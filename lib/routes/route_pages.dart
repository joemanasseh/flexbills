import 'package:adescrow_app/routes/routes.dart';
import 'package:adescrow_app/views/auth/fa_verify_screen/fa_verify_screen.dart';
import 'package:get/get.dart';

import '../middleware/auth_middleware.dart';

import '../backend/backend_utils/network_check/no_internet_screen.dart';
import '../bindings/add_money_screen_binding.dart';
import '../bindings/current_balance_screen_binding.dart';
import '../bindings/dashboard_screen_binding.dart';
import '../bindings/email_verify_screen_binding.dart';
import '../bindings/forgot_otp_screen_binding.dart';
import '../bindings/login_screen_binding.dart';
import '../bindings/money_exchange_screen_binding.dart';
import '../bindings/money_out_screen_binding.dart';
import '../bindings/onboard_screen_binding.dart';
import '../bindings/register_screen_binding.dart';
import '../bindings/splash_screen_binding.dart';
import '../bindings/welcome_screen_binding.dart';
import '../views/auth/forgot_password_otp_screen/forgot_password_otp_screen.dart';
import '../views/auth/kyc_form_screen/kyc_form_screen.dart';
import '../views/auth/login_screen/login_screen.dart';
import '../views/auth/register_otp_screen/register_otp_screen.dart';
import '../views/auth/register_screen/register_screen.dart';
import '../views/auth/reset_pass_screen/reset_pass_screen.dart';
import '../views/before_auth/onboard_screen/onboard_screen.dart';
import '../views/before_auth/splash_screen/splash_screen.dart';
import '../views/before_auth/welcome_screen/welcome_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/dashboard/my_wallets_screens/add_money_screen/add_money_manual_screen.dart';
import '../views/dashboard/my_wallets_screens/add_money_screen/add_money_preview_screen.dart';
import '../views/dashboard/my_wallets_screens/add_money_screen/add_money_screen.dart';
import '../views/dashboard/my_wallets_screens/current_balance_screen/current_balance_screen.dart';
import '../views/dashboard/my_wallets_screens/money_exchange_screen/money_exchange_preview_screen.dart';
import '../views/dashboard/my_wallets_screens/money_exchange_screen/money_exchange_screen.dart';
import '../views/dashboard/my_wallets_screens/money_out_screen/money_out_manual_screen.dart';
import '../views/dashboard/my_wallets_screens/money_out_screen/money_out_preview_screen.dart';
import '../views/dashboard/my_wallets_screens/money_out_screen/money_out_screen.dart';
import '../views/dashboard/my_wallets_screens/money_out_screen/payout_pending_screen.dart';
import '../views/dashboard/my_wallets_screens/transactions_screen/transactions_screen.dart';
import '../views/dashboard/btm_screens/bills_screen.dart';
import '../views/dashboard/bills_screens/bill_biller_screen.dart';
import '../views/dashboard/bills_screens/bill_form_screen.dart';
import '../views/dashboard/bills_screens/bill_preview_screen.dart';
import '../views/dashboard/bills_screens/bill_status_screen.dart';
import '../bindings/bills_screen_binding.dart';
import '../views/dashboard/notification_screen/notification_screen.dart';
import '../views/dashboard/profiles_screens/change_pass_screen/change_pass_screen.dart';
import '../views/dashboard/profiles_screens/fa_security_screen/fa_security_screen.dart';
import '../views/dashboard/profiles_screens/update_profile_screen/update_profile_screen.dart';

class RoutePageList {
  static var list = [
    GetPage(
      name: Routes.noInternetScreen,
      page: () => const NoInternetScreen(),
    ),

    GetPage(
      name: Routes.splashScreen,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),

    GetPage(
      name: Routes.onboardScreen,
      page: () => const OnboardScreen(),
      binding: OnboardBinding(),
    ),

    GetPage(
      name: Routes.welcomeScreen,
      page: () => WelcomeScreen(),
      binding: WelcomeBinding(),
    ),

    GetPage(
      name: Routes.loginScreen,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.faVerifyScreen,
      page: () => const FAVerifyScreen(),
    ),
    GetPage(
        name: Routes.forgotOTPScreen,
        page: () => const ForgotPasswordOTPScreen(),
        binding: ForgotOTPBinding()),
    GetPage(
      name: Routes.resetPassScreen,
      page: () => const ResetPassScreen(),
    ),

    GetPage(
      name: Routes.registerScreen,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
        name: Routes.registerOTPScreen,
        page: () => const RegisterOTPScreen(),
        binding: EmailVerifyBinding()),
    GetPage(
      name: Routes.kycFormScreen,
      page: () => KYCFormScreen(),
    ),

    GetPage(
      name: Routes.dashboardScreen,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.notificationScreen,
      page: () => const NotificationScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.billsScreen,
      page: () => const BillsScreen(),
      binding: BillsBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.billBillerScreen,
      page: () => const BillBillerScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.billFormScreen,
      page: () => const BillFormScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.billPreviewScreen,
      page: () => const BillPreviewScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.billStatusScreen,
      page: () => const BillStatusScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.currentBalanceScreen,
      page: () => CurrentBalanceScreen(),
      binding: CurrentBalanceBinding(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.addMoneyScreen,
      page: () => const AddMoneyScreen(),
      binding: AddMoneyBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.addMoneyManualScreen,
      page: () => AddMoneyManualScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.addMoneyScreenPreview,
      page: () => const AddMoneyPreviewScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.moneyOutScreen,
      page: () => const MoneyOutScreen(),
      binding: MoneyOutBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.moneyOutScreenPreview,
      page: () => const MoneyOutPreviewScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.moneyOutManualScreen,
      page: () => MoneyOutManualScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.payoutPendingScreen,
      page: () => const PayoutPendingScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.moneyExchangeScreen,
      page: () => const MoneyExchangeScreen(),
      binding: MoneyExchangeBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.moneyExchangeScreenPreview,
      page: () => const MoneyExchangePreviewScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.transactionsScreen,
      page: () => const TransactionsScreen(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
      name: Routes.updateProfileScreen,
      page: () => const UpdateProfileScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.changePasswordScreen,
      page: () => const ChangePassScreen(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: Routes.faSecurityScreen,
      page: () => const FASecurityScreen(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
