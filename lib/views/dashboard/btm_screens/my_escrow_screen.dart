import 'package:adescrow_app/backend/backend_utils/no_data_widget.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:adescrow_app/widgets/others/custom_loading_widget.dart';

import '../../../bindings/on_refresh.dart';
import '../../../controller/dashboard/btm_navs_controller/my_escrow_controller.dart';
import '../../../routes/routes.dart';
import '../../../widgets/list_tile/ecrow_tile_widget.dart';

class MyEscrowScreen extends GetView<MyEscrowController> {
  const MyEscrowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return ResponsiveLayout(
      mobileScaffold: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Obx(() => controller.isLoading
              ? const CustomLoadingWidget()
              : RefreshIndicator(
                  backgroundColor: Theme.of(context).primaryColor,
                  color: CustomColor.whiteColor,
                  onRefresh: onRefresh,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(
                          height: height * .85,
                          width: width,
                          child: _bodyWidget()),
                    ],
                  ),
                ))),
    );
  }

  _bodyWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: Dimensions.paddingSizeVertical * .8,
      ),
      decoration: BoxDecoration(
          color: CustomColor.whiteColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Dimensions.radius * 3),
            topRight: Radius.circular(Dimensions.radius * 3),
          )),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleHeading2Widget(
            text: Strings.escrowLog,
            fontWeight: FontWeight.w600,
            fontSize: Dimensions.headingTextSize2 * .85,
            padding: EdgeInsets.only(
              left: Dimensions.paddingSizeHorizontal * .8,
              right: Dimensions.paddingSizeHorizontal * .8,
            ),
          ),
          verticalSpace(Dimensions.marginSizeVertical * .5),
          Expanded(
            child: controller.escrowIndexModel.data.escrowData.isEmpty
                ? const NoDataWidget()
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(
                      bottom: Dimensions.paddingSizeVertical * .85,
                    ),
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Obx(() => EscrowTileWidget(
                        onTap: () {
                          if (controller.openTileIndex.value != index) {
                            controller.openTileIndex.value = index;
                          } else {
                            controller.openTileIndex.value = -1;
                          }
                        },
                        expansion: controller.openTileIndex.value == index,
                        havePayment: controller.escrowIndexModel.data
                                    .escrowData[index].status ==
                                3 &&
                            controller.escrowIndexModel.data.escrowData[index]
                                    .role ==
                                "buyer",
                        data:
                            controller.escrowIndexModel.data.escrowData[index],
                        onSelected: (value) {
                          controller.escrowData = controller
                              .escrowIndexModel.data.escrowData[index];
                          if (value == "message") {
                            Get.toNamed(Routes.conversationScreen);
                          } else {
                            Get.toNamed(Routes.buyerPaymentScreen);
                          }
                        },
                      ));
                    },
                    separatorBuilder: (context, i) =>
                        verticalSpace(Dimensions.marginSizeVertical * .3),
                    itemCount:
                        controller.escrowIndexModel.data.escrowData.length),
          ),
        ],
      ),
    );
  }
}
