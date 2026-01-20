import 'package:adescrow_app/extensions/custom_extensions.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:adescrow_app/widgets/others/custom_loading_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../backend/backend_utils/no_data_widget.dart';
import '../../../backend/services/api_endpoint.dart';
import '../../../bindings/on_refresh.dart';
import '../../../controller/dashboard/btm_navs_controller/home_controller.dart';
import '../../../language/language_controller.dart';
import '../../../widgets/list_tile/transaction_tile_widget.dart';
import '../../../widgets/text_labels/title_heading5_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

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
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(
                        width: width,
                        height: height * .85,
                        child: Column(
                          children: [
                            _topWidget(context, height, width),
                            verticalSpace(
                                Dimensions.marginBetweenInputBox * .5),
                            _bottomBodyWidget(context, height, width),
                          ],
                        ),
                      ),
                    ],
                  ),
                ))),
    );
  }

  Widget _topWidget(BuildContext context, double height, double width) {
    return Container(
      width: width,
      margin: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * .8),
      padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal,
          vertical: Dimensions.paddingSizeVertical),
      decoration: BoxDecoration(
        color: CustomColor.whiteColor,
        borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionButtonWidget(Icons.add, "Add"),
              _actionButtonWidget(Icons.send, "Send"),
              _actionButtonWidget(Icons.swap_horiz, "Convert"),
              _actionButtonWidget(Icons.receipt, "Bills"),
            ],
          )
        ],
      ),
    );
  }

  // Helper function to create action buttons
  Widget _actionButtonWidget(IconData icon, String label) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
          ),
          padding: const EdgeInsets.all(15),
          child: Icon(
            icon,
            size: 20,
            color: const Color.fromARGB(255, 13, 140, 79),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.headingTextSize2 * .8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _bottomBodyWidget(BuildContext context, double height, double width) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: CustomColor.whiteColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radius * 3),
              topRight: Radius.circular(Dimensions.radius * 3),
            )),
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(
            top: Dimensions.paddingSizeVertical * .85,
            left: Dimensions.paddingSizeHorizontal * (Get.find<LanguageSettingController>().selectedLanguage.value.contains("ar") ? 0 : .85),
            right: Dimensions.paddingSizeHorizontal * (Get.find<LanguageSettingController>().selectedLanguage.value.contains("ar") ? 0.85 : 0),
          ),
          physics: const BouncingScrollPhysics(),
          children: [
            _currentBalanceWidget(),
            verticalSpace(Dimensions.marginSizeVertical * .85),
            _transactionLogsWidget()
          ],
        ),
      ),
    );
  }

  Widget _currentBalanceWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeading2Widget(
          text: Strings.currentBalance,
          fontWeight: FontWeight.w600,
          fontSize: Dimensions.headingTextSize2 * .85,
        ),
        verticalSpace(Dimensions.marginSizeVertical * .5),
        SizedBox(
          height: Dimensions.buttonHeight * 1.4,
          child: ListView.separated(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                var data = controller.homeModel.data.userWallet[index];
                return Container(
                  height: Dimensions.buttonHeight * 1.2,
                  padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeHorizontal * .8,
                      vertical: Dimensions.paddingSizeVertical * .6),
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(Dimensions.radius)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Animate(
                        effects: const [FadeEffect(), ScaleEffect()],
                        child: Container(
                          height: double.infinity,
                          width: Dimensions.widthSize * 6,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(Dimensions.radius * 1),
                              image: DecorationImage(
                                  image: NetworkImage(
                                    "${ApiEndpoint.mainDomain}/${data.imagePath}/${data.flag}",
                                  ),
                                  fit: BoxFit.fill)),
                        ),
                      ),
                      horizontalSpace(Dimensions.marginSizeHorizontal * .5),
                      FittedBox(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TitleHeading2Widget(
                              text:
                                  "${data.currencySymbol} ${makeBalance(data.balance.toString(), data.currencyType == "FIAT" ? 2 : 6)}",
                              fontSize: Dimensions.headingTextSize2 * .85,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TitleHeading4Widget(
                                  text: "${data.name} - ${data.currencyCode}",
                                  fontSize: Dimensions.headingTextSize4 * .85,
                                  opacity: .4,
                                )
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
              separatorBuilder: (context, i) =>
                  horizontalSpace(Dimensions.marginSizeHorizontal * .3),
              itemCount: controller.homeModel.data.userWallet.length),
        ),
      ],
    );
  }

  Widget _transactionLogsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleHeading2Widget(
          text: Strings.transactionsLog,
          fontWeight: FontWeight.w600,
          fontSize: Dimensions.headingTextSize2 * .85,
        ),
        verticalSpace(Dimensions.marginSizeVertical * .5),
        controller.homeModel.data.transactions.isEmpty
            ? Padding(
                padding: EdgeInsets.only(
                  right: Dimensions.paddingSizeHorizontal * (Get.find<LanguageSettingController>().selectedLanguage.value.contains("ar") ? 0 : .85),
                  left: Dimensions.paddingSizeHorizontal * (Get.find<LanguageSettingController>().selectedLanguage.value.contains("ar") ? 0.85 : 0),
                ),
                child: const NoDataWidget(
                  isScaffold: true,
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  right: Dimensions.paddingSizeHorizontal * (Get.find<LanguageSettingController>().selectedLanguage.value.contains("ar") ? 0 : .85),
                  left: Dimensions.paddingSizeHorizontal * (Get.find<LanguageSettingController>().selectedLanguage.value.contains("ar") ? 0.85 : 0),
                  bottom: Dimensions.paddingSizeVertical * .85,
                ),
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  var data = controller.homeModel.data.transactions[index];
                  return Obx(() => TransactionTileWidget(
                    transaction: data,
                    onTap: () {
                      if (controller.openTileIndex.value != index) {
                        controller.openTileIndex.value = index;
                      } else {
                        controller.openTileIndex.value = -1;
                      }
                    },
                    expansion: controller.openTileIndex.value == index
                  ));
                },
                separatorBuilder: (context, i) =>
                    verticalSpace(Dimensions.marginSizeVertical * .3),
                itemCount: controller.homeModel.data.transactions.length),
      ],
    );
  }

  Widget _miniEscrowWidget(String title, String value) {
    return Column(
      children: [
        TitleHeading2Widget(
          text: value,
          opacity: .7,
          fontSize: Dimensions.headingTextSize2 * .9,
          fontWeight: FontWeight.w600,
        ),
        TitleHeading5Widget(
          text: title,
          opacity: .5,
          fontSize: Dimensions.headingTextSize4,
        ),
      ],
    );
  }
}
