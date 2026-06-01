import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:adescrow_app/widgets/others/custom_loading_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../backend/models/money_exchange/money_exchange_index_model.dart';
import '../../../../controller/dashboard/my_wallets/money_exchange_controller.dart';
import '../../../../utils/svg_assets.dart';
import '../../../../widgets/custom_dropdown_widget/custom_dropdown_widget.dart';

class MoneyExchangeScreen extends GetView<MoneyExchangeController> {
  const MoneyExchangeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark
        ? CustomColor.primaryDarkScaffoldBackgroundColor
        : CustomColor.primaryLightScaffoldBackgroundColor;

    return ResponsiveLayout(
      mobileScaffold: Scaffold(
        backgroundColor: scaffoldBg,
        appBar: const PrimaryAppBar(
          title: Strings.exchange,
          breadcrumbs: ['Home', 'Wallet', 'Exchange'],
        ),
        body: Obx(() {
          if (controller.isLoading) return const CustomLoadingWidget();
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeHorizontal,
              vertical: Dimensions.paddingSizeVertical,
            ),
            children: [
              _rateHeroCard(context, isDark),
              SizedBox(height: Dimensions.marginSizeVertical * 1.2),
              _currencyCard(context: context, isDark: isDark, isSource: true),
              _swapSeparator(context, isDark),
              _currencyCard(context: context, isDark: isDark, isSource: false),
              SizedBox(height: Dimensions.marginSizeVertical * 1.8),
              _exchangeButton(context, isDark),
              SizedBox(height: Dimensions.paddingSizeVertical * 2),
            ],
          );
        }),
      ),
    );
  }

  // ─── Rate Hero Card ──────────────────────────────────────────────────────

  Widget _rateHeroCard(BuildContext context, bool isDark) {
    final accent = isDark
        ? CustomColor.primaryDarkColor
        : CustomColor.primaryLightColor;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Animate(
      effects: [
        FadeEffect(duration: 320.ms),
        SlideEffect(begin: const Offset(0, -0.04), end: Offset.zero, duration: 320.ms),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    CustomColor.primaryDarkColor.withOpacity(0.18),
                    CustomColor.thirdColor.withOpacity(0.12),
                  ]
                : [
                    CustomColor.primaryLightColor.withOpacity(0.1),
                    CustomColor.thirdColor.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(Dimensions.radius * 2),
          border: Border.all(
            color: accent.withOpacity(0.22),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            // ── "Live Rate" pill + spinner ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded, size: 11, color: accent),
                      const SizedBox(width: 4),
                      Text(
                        'Live Rate',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => controller.isRateFetching
                    ? SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      )
                    : const SizedBox.shrink()),
              ],
            ),

            const SizedBox(height: 12),

            // ── Rate display line ───────────────────────────────────────────
            Obx(() => FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '1 ',
                        style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize1 * 1.1,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        controller.fromSelectedCurrency.value,
                        style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize1 * 1.1,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '=',
                          style: GoogleFonts.inter(
                            fontSize: Dimensions.headingTextSize2,
                            fontWeight: FontWeight.w300,
                            color: textColor.withOpacity(0.4),
                          ),
                        ),
                      ),
                      Text(
                        controller.exchangeRate.value.toFormattedCurrency(
                            controller.toSelectedCurrencyType.value == 'FIAT'
                                ? 2
                                : 6),
                        style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize1 * 1.1,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        ' ${controller.toSelectedCurrency.value}',
                        style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize1 * 1.1,
                          fontWeight: FontWeight.w800,
                          color: accent,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  // ─── Currency Card ───────────────────────────────────────────────────────

  Widget _currencyCard({
    required BuildContext context,
    required bool isDark,
    required bool isSource,
  }) {
    final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
    final border = isDark
        ? Colors.white.withOpacity(0.06)
        : Colors.grey.withOpacity(0.13);
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    final label = isSource ? 'You Send' : 'You Receive';

    return Animate(
      effects: [
        FadeEffect(duration: 320.ms, delay: isSource ? 60.ms : 110.ms),
        SlideEffect(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
          duration: 320.ms,
          delay: isSource ? 60.ms : 110.ms,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(Dimensions.radius * 2),
          border: Border.all(color: border),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize5,
                    fontWeight: FontWeight.w600,
                    color: textColor.withOpacity(0.5),
                  ),
                ),
                // Balance hint on the source card
                if (isSource)
                  Obx(() {
                    if (!controller.hasModel) return const SizedBox.shrink();
                    try {
                      final w = controller.moneyExchangeModel.data.userWallet
                          .firstWhere((w) =>
                              w.currencyCode ==
                              controller.fromSelectedCurrency.value);
                      return Text(
                        'Bal: ${w.balance.toFiatString()} ${w.currencyCode}',
                        style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize6,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor.withOpacity(0.85),
                        ),
                      );
                    } catch (_) {
                      return const SizedBox.shrink();
                    }
                  }),
              ],
            ),

            const SizedBox(height: 12),

            // ── Currency selector ──────────────────────────────────────────
            // Uses a solid primaryColor background so the white dropdown text
            // (isCurrencyDropDown: true forces white) is always legible.
            ClipRRect(
              borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
              child: Container(
                color: Theme.of(context).primaryColor,
                child: isSource
                    ? _fromDropdown(context, isDark)
                    : _toDropdown(context, isDark),
              ),
            ),

            const SizedBox(height: 12),

            // ── Amount input ───────────────────────────────────────────────
            Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
                border: Border.all(color: border),
              ),
              alignment: Alignment.centerLeft,
              child: isSource
                  ? TextField(
                      controller: controller.fromAmountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: GoogleFonts.inter(
                        fontSize: Dimensions.headingTextSize2,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: -0.5,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize2,
                          fontWeight: FontWeight.w700,
                          color: textColor.withOpacity(0.2),
                          letterSpacing: -0.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (_) => controller.calculateExchangeRate(),
                    )
                  // TO field: reads the observable, never steals focus
                  : Obx(() {
                      final val = controller.toAmountDisplay.value;
                      return Text(
                        val.isEmpty ? '0.00' : val,
                        style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize2,
                          fontWeight: FontWeight.w700,
                          color: val.isEmpty
                              ? textColor.withOpacity(0.2)
                              : textColor,
                          letterSpacing: -0.5,
                        ),
                      );
                    }),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Swap Separator ──────────────────────────────────────────────────────

  Widget _swapSeparator(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Dimensions.marginSizeVertical * 0.55),
      child: Center(
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [CustomColor.primaryDarkColor, CustomColor.thirdColor]
                  : [CustomColor.primaryLightColor, CustomColor.thirdColor],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.32),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Animate(
              effects: const [FadeEffect(), ScaleEffect()],
              child: SvgPicture.string(
                SVGAssets.exchangeWhiteIcon,
                height: 20,
                width: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Exchange Button ─────────────────────────────────────────────────────
  // Uses Material + InkWell so gradient shows through without being covered
  // by ElevatedButton's own Material surface layer.

  Widget _exchangeButton(BuildContext context, bool isDark) {
    return Obx(() {
      final enabled = controller.canExchange;
      return Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: Container(
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: enabled
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: isDark
                        ? [
                            CustomColor.primaryDarkColor,
                            CustomColor.thirdColor,
                          ]
                        : [
                            CustomColor.primaryLightColor,
                            CustomColor.thirdColor,
                          ],
                  )
                : null,
            color: enabled
                ? null
                : (isDark ? Colors.grey[800] : Colors.grey[300]),
            borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled
                  ? () => controller.onExchangeBTNProcess(context)
                  : null,
              borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
              splashColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Center(
                child: Text(
                  'Exchange Now',
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize4,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: enabled
                        ? Colors.white
                        : (isDark
                            ? Colors.white.withOpacity(0.35)
                            : Colors.black.withOpacity(0.3)),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  // ─── Dropdowns ───────────────────────────────────────────────────────────

  Widget _fromDropdown(BuildContext context, bool isDark) {
    return Obx(() => CustomDropDown<UserWallet>(
          isCurrencyDropDown: true,
          items: controller.fromWallets,
          hint: controller.fromSelectedCurrency.value.isEmpty
              ? 'Select'
              : controller.fromSelectedCurrency.value,
          onChanged: (value) {
            if (value == null) return;
            controller.fromSelectedCurrency.value     = value.currencyCode;
            controller.fromSelectedCurrencyType.value = value.type;
            controller.fromSelectedCurrencyRate.value =
                double.parse(value.rate.toString());
            controller.onCurrencyChanged();
          },
          padding: EdgeInsets.zero,
          titleTextColor: CustomColor.whiteColor,
          // dropDownColor controls the open menu background
          dropDownColor: isDark ? const Color(0xFF1E2435) : Colors.white,
          borderEnable: false,
          dropDownFieldColor: Colors.transparent,
          dropDownIconColor: CustomColor.whiteColor,
        ));
  }

  Widget _toDropdown(BuildContext context, bool isDark) {
    return Obx(() => CustomDropDown<UserWallet>(
          isCurrencyDropDown: true,
          items: controller.toWallets,
          hint: controller.toSelectedCurrency.value == '--'
              ? 'Select'
              : controller.toSelectedCurrency.value,
          onChanged: (value) {
            if (value == null) return;
            controller.toSelectedCurrency.value     = value.currencyCode;
            controller.toSelectedCurrencyRate.value =
                double.parse(value.rate.toString());
            controller.toSelectedCurrencyType.value = value.type;
            controller.onCurrencyChanged();
          },
          padding: EdgeInsets.zero,
          titleTextColor: CustomColor.whiteColor,
          dropDownColor: isDark ? const Color(0xFF1E2435) : Colors.white,
          borderEnable: false,
          dropDownFieldColor: Colors.transparent,
          dropDownIconColor: CustomColor.whiteColor,
        ));
  }
}
