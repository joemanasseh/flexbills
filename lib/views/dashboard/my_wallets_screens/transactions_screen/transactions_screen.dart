import 'package:adescrow_app/backend/backend_utils/no_data_widget.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';

import '../../../../controller/dashboard/btm_navs_controller/home_controller.dart';
import '../../../../controller/dashboard/my_wallets/transactions_controller.dart';
import '../../../../widgets/list_tile/transaction_tile_widget.dart';


class TransactionsScreen extends GetView<TransactionsController> {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ResponsiveLayout(
        mobileScaffold: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: const PrimaryAppBar(
            title: Strings.transactions,
          ),
          body: Get.find<HomeController>().homeModel.data.transactions.isEmpty ? const Column(children: [NoDataWidget()]): ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.only(
                right: Dimensions.paddingSizeHorizontal * .85,
                left: Dimensions.paddingSizeHorizontal * .85,
                bottom: Dimensions.paddingSizeVertical* .85,
              ),
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Obx(() => TransactionTileWidget(
                  onTap: () {
                    if (Get.find<HomeController>().openTileIndex.value != index) {
                      Get.find<HomeController>().openTileIndex.value = index;
                    } else {
                      Get.find<HomeController>().openTileIndex.value = -1;
                    }
                  },
                  expansion: Get.find<HomeController>().openTileIndex.value == index,
                  inDashboard: false,
                  transaction: Get.find<HomeController>().homeModel.data.transactions[index],
                ));
              },
              separatorBuilder: (context, i) =>
                  verticalSpace(Dimensions.marginSizeVertical * .3),
              itemCount: Get.find<HomeController>().homeModel.data.transactions.length),
        ),
      ),
    );
  }

}
