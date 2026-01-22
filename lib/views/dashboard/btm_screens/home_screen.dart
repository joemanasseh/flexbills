import 'package:adescrow_app/extensions/custom_extensions.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:adescrow_app/widgets/others/custom_loading_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../backend/backend_utils/no_data_widget.dart';
import '../../../backend/services/api_endpoint.dart';
import '../../../bindings/on_refresh.dart';
import '../../../controller/dashboard/btm_navs_controller/home_controller.dart';
import '../../../language/language_controller.dart';
import '../../../routes/routes.dart';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Current Balance Section - AT TOP
          _currentBalanceWidget(),

          verticalSpace(Dimensions.marginSizeVertical * .85),

          // Action buttons - BELOW BALANCE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionButtonWidget(
                icon: Icons.add,
                label: "Add",
                onTap: () {
                  // Pass any available wallet (not just filtered ones)
                  if (controller.homeModel.data.userWallet.isNotEmpty) {
                    Get.toNamed(Routes.addMoneyScreen,
                        arguments: controller.homeModel.data.userWallet.first);
                  } else {
                    Get.snackbar(
                      'No Wallet',
                      'Please create a wallet first',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              _actionButtonWidget(
                icon: Icons.send,
                label: "Send",
                onTap: () {
                  // Pass any available wallet (not just filtered ones)
                  if (controller.homeModel.data.userWallet.isNotEmpty) {
                    Get.toNamed(Routes.moneyOutScreen,
                        arguments: controller.homeModel.data.userWallet.first);
                  } else {
                    Get.snackbar(
                      'No Wallet',
                      'Please create a wallet first',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
              ),
              _actionButtonWidget(
                icon: Icons.swap_horiz,
                label: "Convert",
                onTap: () => Get.toNamed(Routes.moneyExchangeScreen),
              ),
              _actionButtonWidget(
                icon: Icons.receipt,
                label: "Bills",
                onTap: () => Get.toNamed(Routes.billsScreen),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Helper function to create action buttons with proper colors, fonts, and navigation
  Widget _actionButtonWidget({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CustomColor.primaryLightColor.withOpacity(0.1),
            ),
            padding: const EdgeInsets.all(15),
            child: Icon(
              icon,
              size: 24,
              color: CustomColor.primaryLightColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: Dimensions.headingTextSize4 * 0.9,
              fontWeight: FontWeight.w500,
              color: CustomColor.primaryLightTextColor,
            ),
          ),
        ],
      ),
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
            left: Dimensions.paddingSizeHorizontal *
                (Get.find<LanguageSettingController>()
                        .selectedLanguage
                        .value
                        .contains("ar")
                    ? 0
                    : .85),
            right: Dimensions.paddingSizeHorizontal *
                (Get.find<LanguageSettingController>()
                        .selectedLanguage
                        .value
                        .contains("ar")
                    ? 0.85
                    : 0),
          ),
          physics: const BouncingScrollPhysics(),
          children: [_transactionLogsWidget()],
        ),
      ),
    );
  }

  Widget _currentBalanceWidget() {
    // Filter for specific currencies: USD, EUR, GBP, SWISS CFA (XAF)
    final allowedCurrencies = ['USD', 'EUR', 'GBP', 'XAF'];
    final filteredWallets = controller.homeModel.data.userWallet
        .where((wallet) => allowedCurrencies.contains(wallet.currencyCode))
        .toList();

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
          child: filteredWallets.isEmpty
              ? Center(
                  child: Text(
                    'No wallets available',
                    style: GoogleFonts.poppins(
                      fontSize: Dimensions.headingTextSize4,
                      color: CustomColor.primaryLightTextColor.withOpacity(0.5),
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    var data = filteredWallets[index];
                    return Container(
                      height: Dimensions.buttonHeight * 1.2,
                      padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.paddingSizeHorizontal * .8,
                          vertical: Dimensions.paddingSizeVertical * .6),
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius)),
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
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius * 1),
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
                                Text(
                                  "${data.currencySymbol} ${makeBalance(data.balance.toString(), data.currencyType == "FIAT" ? 2 : 6)}",
                                  style: GoogleFonts.poppins(
                                    fontSize: Dimensions.headingTextSize2 * .85,
                                    fontWeight: FontWeight.w600,
                                    color: CustomColor.primaryLightTextColor,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${data.name} - ${data.currencyCode}",
                                      style: GoogleFonts.poppins(
                                        fontSize:
                                            Dimensions.headingTextSize4 * .85,
                                        fontWeight: FontWeight.w300,
                                        color: CustomColor.primaryLightTextColor
                                            .withOpacity(.4),
                                      ),
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
                  itemCount: filteredWallets.length),
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
                  right: Dimensions.paddingSizeHorizontal *
                      (Get.find<LanguageSettingController>()
                              .selectedLanguage
                              .value
                              .contains("ar")
                          ? 0
                          : .85),
                  left: Dimensions.paddingSizeHorizontal *
                      (Get.find<LanguageSettingController>()
                              .selectedLanguage
                              .value
                              .contains("ar")
                          ? 0.85
                          : 0),
                ),
                child: const NoDataWidget(
                  isScaffold: true,
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.only(
                  right: Dimensions.paddingSizeHorizontal *
                      (Get.find<LanguageSettingController>()
                              .selectedLanguage
                              .value
                              .contains("ar")
                          ? 0
                          : .85),
                  left: Dimensions.paddingSizeHorizontal *
                      (Get.find<LanguageSettingController>()
                              .selectedLanguage
                              .value
                              .contains("ar")
                          ? 0.85
                          : 0),
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
                      expansion: controller.openTileIndex.value == index));
                },
                separatorBuilder: (context, i) =>
                    verticalSpace(Dimensions.marginSizeVertical * .3),
                itemCount: controller.homeModel.data.transactions.length),
      ],
    );
  }
}
