import 'package:get/get.dart';

import '../controller/dashboard/my_wallets/money_out_controller.dart';

class MoneyOutBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MoneyOutController());
  }
}
