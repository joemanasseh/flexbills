import 'package:adescrow_app/controller/dashboard/bills/bills_controller.dart';
import 'package:get/get.dart';

class BillsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BillsController>(() => BillsController());
  }
}
