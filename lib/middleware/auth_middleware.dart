import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../backend/local_storage/local_storage.dart';
import '../routes/routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  int? get priority => 1;

  @override
  RouteSettings? redirect(String? route) {
    if (!LocalStorage.isLoggedIn() || LocalStorage.getToken() == null) {
      LocalStorage.logout();
      return const RouteSettings(name: Routes.loginScreen);
    }
    return null;
  }
}
