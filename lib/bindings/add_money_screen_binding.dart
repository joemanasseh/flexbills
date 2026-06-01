import 'package:get/get.dart';

import '../controller/dashboard/my_wallets/add_money_controller.dart';

class AddMoneyBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AddMoneyController());
  }
}
