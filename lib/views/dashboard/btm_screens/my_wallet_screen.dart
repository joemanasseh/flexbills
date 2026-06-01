import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/currency_flag_util.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../backend/models/dashboard/home_model.dart';
import '../../../bindings/on_refresh.dart';
import '../../../controller/dashboard/btm_navs_controller/my_wallet_controller.dart';
import '../../../widgets/others/custom_loading_widget.dart';

class MyWalletScreen extends GetView<MyWalletController> {
  const MyWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveLayout(
      mobileScaffold: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Obx(() => controller.walletsController.isLoading
            ? const CustomLoadingWidget()
            : RefreshIndicator(
                backgroundColor: Theme.of(context).primaryColor,
                color: CustomColor.whiteColor,
                onRefresh: onRefresh,
                child: _buildBody(context, isDark),
              )),
      ),
    );
  }

  static const _displayCurrencies = ['USD', 'EUR', 'GBP', 'CHF'];

  Widget _buildBody(BuildContext context, bool isDark) {
    final wallets = (controller.walletsController.homeModel?.data.userWallet ?? [])
        .where((w) => _displayCurrencies.contains(w.currencyCode))
        .toList();
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(context, isDark, textColor, wallets.length),
        ),
        SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeHorizontal,
          ).copyWith(bottom: Dimensions.paddingSizeVertical * 2),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildWalletCard(
                  context, wallets[index], isDark, textColor, index),
              childCount: wallets.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color textColor,
      int walletCount) {
    return Container(
      padding: EdgeInsets.only(
        top: Dimensions.paddingSizeVertical * 0.75,
        left: Dimensions.paddingSizeHorizontal,
        right: Dimensions.paddingSizeHorizontal,
        bottom: Dimensions.paddingSizeVertical * 1.5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  CustomColor.primaryDarkColor.withOpacity(0.15),
                  CustomColor.secondaryDarkColor,
                ]
              : [
                  CustomColor.primaryLightColor.withOpacity(0.08),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(Dimensions.radius * 3),
          bottomRight: Radius.circular(Dimensions.radius * 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Wallets',
            style: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize1,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: Dimensions.marginSizeVertical * 0.25),
          Text(
            '$walletCount ${walletCount == 1 ? 'wallet' : 'wallets'} available',
            style: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize5,
              color: textColor.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWalletCard(BuildContext context, UserWallet data, bool isDark,
      Color textColor, int index) {
    final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.grey.withOpacity(0.13);

    return Animate(
      effects: [
        FadeEffect(delay: (index * 60).ms),
        SlideEffect(
            begin: const Offset(0, 0.08),
            end: Offset.zero,
            delay: (index * 60).ms),
      ],
      child: InkWell(
        onTap: () => controller.routeCurrentBalanceScreen(data),
        borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
        child: Container(
          margin:
              EdgeInsets.only(bottom: Dimensions.marginSizeVertical * 0.6),
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeHorizontal * 0.75,
            vertical: Dimensions.paddingSizeVertical * 0.65,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius:
                BorderRadius.circular(Dimensions.radius * 1.5),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            children: [
              _buildFlag(data, isDark),
              SizedBox(width: Dimensions.marginSizeHorizontal * 0.6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: GoogleFonts.inter(
                        fontSize: Dimensions.headingTextSize5,
                        color: textColor.withOpacity(0.55),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          data.currencyCode,
                          style: GoogleFonts.inter(
                            fontSize: Dimensions.headingTextSize4,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            data.currencyType,
                            style: GoogleFonts.inter(
                              fontSize: Dimensions.headingTextSize6,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    makeBalance(
                      data.balance.toString(),
                      data.currencyType == 'FIAT' ? 2 : 6,
                    ),
                    style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize3,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tap to manage',
                    style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize6,
                      color: textColor.withOpacity(0.35),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right_rounded,
                color: textColor.withOpacity(0.3),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlag(UserWallet data, bool isDark) {
    final url = flagUrl(data.currencyCode);
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: 48,
        height: 32,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.12),
            child: Icon(
              Icons.flag_rounded,
              size: 18,
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.4),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.withOpacity(0.12),
            child: Center(
              child: Text(
                data.currencyCode.isNotEmpty
                    ? data.currencyCode.substring(0, 1)
                    : '?',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
