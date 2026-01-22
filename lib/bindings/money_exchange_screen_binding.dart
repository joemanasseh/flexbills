import 'package:get/get.dart';

import '../controller/dashboard/my_wallets/money_exchange_controller.dart';

class MoneyExchangeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MoneyExchangeController());
  }
}
