import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:adescrow_app/widgets/others/custom_loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../backend/backend_utils/custom_snackbar.dart';
import '../../../../controller/dashboard/my_wallets/money_out_controller.dart';

class MoneyOutScreen extends GetView<MoneyOutController> {
  const MoneyOutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: ResponsiveLayout(
        mobileScaffold: Scaffold(
          backgroundColor: isDark
              ? CustomColor.primaryDarkScaffoldBackgroundColor
              : CustomColor.primaryLightScaffoldBackgroundColor,
          appBar: _appBar(context, isDark),
          body: Obx(() => controller.isLoading
              ? const CustomLoadingWidget()
              : _body(context, isDark)),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context, bool isDark) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Send Money',
        style: GoogleFonts.inter(
          fontSize: Dimensions.headingTextSize3,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      centerTitle: false,
      bottom: const BreadcrumbBar(crumbs: ['Home', 'Wallet', 'Send Money']),
    );
  }

  Widget _body(BuildContext context, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeHorizontal,
              vertical: Dimensions.paddingSizeVertical * 0.5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _balanceChip(context, isDark),
                SizedBox(height: Dimensions.marginSizeVertical * 0.9),
                _transferCard(context, isDark),
                SizedBox(height: Dimensions.marginSizeVertical * 0.8),
                _infoCard(context, isDark),
                SizedBox(height: Dimensions.marginSizeVertical),
              ],
            ),
          ),
        ),
        _continueButton(context, isDark),
      ],
    );
  }

  // ─────────────────────────── Balance chip ──────────────────────────────

  Widget _balanceChip(BuildContext context, bool isDark) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms),
        const SlideEffect(begin: Offset(0, -0.1), end: Offset.zero),
      ],
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * 0.55,
          vertical: Dimensions.paddingSizeVertical * 0.28,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Dimensions.radius * 2),
          border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 14, color: Theme.of(context).primaryColor),
            const SizedBox(width: 6),
            Text(
              'Balance: ${controller.data.balance.toFiatString()} ${controller.data.currencyCode}',
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── Transfer card ─────────────────────────────

  Widget _transferCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.14);

    return Animate(
      effects: [
        FadeEffect(duration: 350.ms, delay: 50.ms),
        SlideEffect(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
            delay: 50.ms),
      ],
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(Dimensions.radius * 2),
          border: Border.all(color: borderColor),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4))
                ],
        ),
        child: Column(
          children: [
            _transferSection(context, isDark,
                label: 'You send', isTopSection: true),
            _rateRow(context, isDark),
            _transferSection(context, isDark,
                label: 'They receive', isTopSection: false),
          ],
        ),
      ),
    );
  }

  Widget _transferSection(BuildContext context, bool isDark,
      {required String label, required bool isTopSection}) {
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeHorizontal * 0.8,
        vertical: Dimensions.paddingSizeVertical * 0.7,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize5,
              color: textColor.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: Dimensions.marginSizeVertical * 0.35),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: isTopSection
                    ? _amountInput(textColor)
                    : _convertedAmount(textColor),
              ),
              const SizedBox(width: 12),
              isTopSection
                  ? _currencySelector(context, isDark)
                  : _methodSelector(context, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _amountInput(Color textColor) {
    return TextFormField(
      controller: controller.amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: GoogleFonts.inter(
        fontSize: Dimensions.headingTextSize1 * 1.4,
        fontWeight: FontWeight.w800,
        color: textColor,
        letterSpacing: -1,
      ),
      decoration: InputDecoration(
        hintText: '0.00',
        hintStyle: GoogleFonts.inter(
          fontSize: Dimensions.headingTextSize1 * 1.4,
          fontWeight: FontWeight.w800,
          color: textColor.withOpacity(0.18),
          letterSpacing: -1,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
      ),
      onChanged: (v) => controller.amountObs.value = v,
    );
  }

  Widget _convertedAmount(Color textColor) {
    return Obx(() {
      final amt = double.tryParse(controller.amountObs.value) ?? 0.0;
      final converted = amt * controller.exchangeRate.value;
      final hasValue = converted > 0;
      return Text(
        hasValue ? converted.toFiatString() : '0.00',
        style: GoogleFonts.inter(
          fontSize: Dimensions.headingTextSize1 * 1.4,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          color: textColor.withOpacity(hasValue ? 1.0 : 0.18),
        ),
      );
    });
  }

  // ─────────────────────── Selector pills ────────────────────────────────

  Widget _currencySelector(BuildContext context, bool isDark) {
    return Obx(() => _SelectorPill(
          imageUrl: controller.selectedCurrencyImage.value,
          code: controller.selectedCurrency.value,
          isDark: isDark,
          onTap: () => _showCurrencyPicker(context, isDark),
        ));
  }

  Widget _methodSelector(BuildContext context, bool isDark) {
    return Obx(() => _SelectorPill(
          imageUrl: controller.selectedMethodImage.value,
          code: controller.selectedMethod.value,
          isDark: isDark,
          onTap: () => _showMethodPicker(context, isDark),
        ));
  }

  void _showCurrencyPicker(BuildContext context, bool isDark) {
    final wallets = controller.moneyOutIndexModel.data.userWallet;
    _showPickerSheet(
      context,
      isDark,
      title: 'Select currency',
      items: wallets
          .map((w) => _PickerItem(
                imageUrl: w.img,
                primary: w.title,
                secondary: w.name,
                onTap: () {
                  controller.selectedCurrency.value = w.title;
                  controller.selectedCurrencyType.value = w.type;
                  controller.selectedCurrencyRate.value = w.rate;
                  controller.selectedCurrencyImage.value = w.img;
                  controller.exchangeCalculation();
                  Get.back();
                },
              ))
          .toList(),
    );
  }

  void _showMethodPicker(BuildContext context, bool isDark) {
    final methods = controller.moneyOutIndexModel.data.gatewayCurrencies;
    _showPickerSheet(
      context,
      isDark,
      title: 'Select payment method',
      items: methods
          .map((m) => _PickerItem(
                imageUrl: m.img,
                primary: m.title,
                secondary: m.currencyCode,
                onTap: () {
                  controller.selectedMethodID.value = m.id;
                  controller.selectedMethod.value = m.title;
                  controller.selectedMethodCurrencyCode.value = m.currencyCode;
                  controller.selectedMethodImage.value = m.img;
                  controller.selectedMethodType.value = m.type;
                  controller.selectedMethodAlias.value = m.alias;
                  controller.selectedMethodMax.value = m.max;
                  controller.selectedMethodMin.value = m.min;
                  controller.selectedMethodPCharge.value = m.pCharge;
                  controller.selectedMethodFCharge.value = m.fCharge;
                  controller.selectedMethodRate.value = m.rate;
                  controller.exchangeCalculation();
                  Get.back();
                },
              ))
          .toList(),
    );
  }

  void _showPickerSheet(BuildContext context, bool isDark,
      {required String title, required List<_PickerItem> items}) {
    final sheetBg = isDark ? const Color(0xFF141921) : Colors.white;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.radius * 2.5)),
        ),
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeHorizontal,
            vertical: Dimensions.paddingSizeVertical * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.8),
            Text(title,
                style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize3,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            SizedBox(height: Dimensions.marginSizeVertical * 0.5),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: textColor.withOpacity(0.07)),
                itemBuilder: (_, i) =>
                    _pickerRow(items[i], isDark, textColor),
              ),
            ),
            SizedBox(height: Dimensions.paddingSizeVertical * 0.5),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _pickerRow(_PickerItem item, bool isDark, Color textColor) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: Dimensions.paddingSizeVertical * 0.55),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 40,
                height: 27,
                child: item.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            _fallback(item.primary, isDark),
                      )
                    : _fallback(item.primary, isDark),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.primary,
                      style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize4,
                          fontWeight: FontWeight.w600,
                          color: textColor)),
                  if (item.secondary.isNotEmpty)
                    Text(item.secondary,
                        style: GoogleFonts.inter(
                            fontSize: Dimensions.headingTextSize6,
                            color: textColor.withOpacity(0.45))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: textColor.withOpacity(0.25), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _fallback(String label, bool isDark) {
    return Container(
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : Colors.grey.withOpacity(0.12),
      child: Center(
        child: Text(
          label.isNotEmpty ? label[0].toUpperCase() : '?',
          style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: CustomColor.primaryLightColor),
        ),
      ),
    );
  }

  // ─────────────────────────── Rate row ──────────────────────────────────

  Widget _rateRow(BuildContext context, bool isDark) {
    final dividerColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.12);

    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(height: 1, color: dividerColor),
        Obx(() => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: CustomColor.primaryLightColor,
                borderRadius: BorderRadius.circular(Dimensions.radius * 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.swap_vert_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    '1 ${controller.selectedCurrency.value} = ${controller.exchangeRate.value.toRateString()} ${controller.selectedMethodCurrencyCode.value}',
                    style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize6,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // ───────────────────────── Info card ───────────────────────────────────

  Widget _infoCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.13);
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Animate(
      effects: [FadeEffect(duration: 350.ms, delay: 100.ms)],
      child: Obx(() => Container(
            padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal * 0.8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(Dimensions.radius * 1.5),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                _infoLine(
                  icon: Icons.percent_rounded,
                  label: 'Fee',
                  value:
                      '${controller.selectedMethodFCharge.value.toFiatString()} ${controller.selectedMethodCurrencyCode.value} + ${controller.selectedMethodPCharge.value.toFiatString()}%',
                  textColor: textColor,
                ),
                Divider(
                    height: Dimensions.marginSizeVertical * 0.8,
                    color: textColor.withOpacity(0.07)),
                _infoLine(
                  icon: Icons.tune_rounded,
                  label: 'Limit',
                  value:
                      '${controller.min.value.toFormattedCurrency(controller.selectedCurrencyType.value == "FIAT" ? 2 : 6)}'
                      ' – '
                      '${controller.max.value.toFormattedCurrency(controller.selectedCurrencyType.value == "FIAT" ? 2 : 6)}'
                      ' ${controller.selectedCurrency.value}',
                  textColor: textColor,
                ),
              ],
            ),
          )),
    );
  }

  Widget _infoLine({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: CustomColor.primaryLightColor),
        const SizedBox(width: 8),
        Text(label,
            style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize5,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.5))),
        const Spacer(),
        Text(value,
            style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize5,
                fontWeight: FontWeight.w600,
                color: textColor)),
      ],
    );
  }

  // ─────────────────────── Continue button ───────────────────────────────

  Widget _continueButton(BuildContext context, bool isDark) {
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.12);
    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.paddingSizeHorizontal,
        Dimensions.paddingSizeVertical * 0.5,
        Dimensions.paddingSizeHorizontal,
        Dimensions.paddingSizeVertical,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? CustomColor.primaryDarkScaffoldBackgroundColor
            : CustomColor.primaryLightScaffoldBackgroundColor,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Obx(() => SizedBox(
            width: double.infinity,
            height: Dimensions.buttonHeight,
            child: ElevatedButton(
              onPressed: controller.isSubmitLoading
                  ? null
                  : () {
                      if (controller.amountController.text.isEmpty) {
                        CustomSnackBar.error(Strings.enterAmount);
                      } else {
                        controller.moneyOutBTNClicked(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.primaryLightColor,
                disabledBackgroundColor:
                    CustomColor.primaryLightColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(Dimensions.radius * 1.5),
                ),
                elevation: 0,
              ),
              child: controller.isSubmitLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Continue',
                            style: GoogleFonts.inter(
                                fontSize: Dimensions.headingTextSize3,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 20),
                      ],
                    ),
            ),
          )),
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────────────────

class _SelectorPill extends StatelessWidget {
  const _SelectorPill({
    required this.imageUrl,
    required this.code,
    required this.isDark,
    required this.onTap,
  });
  final String imageUrl;
  final String code;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.grey.withOpacity(0.08);
    final border = isDark
        ? Colors.white.withOpacity(0.1)
        : Colors.grey.withOpacity(0.2);
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  width: 24,
                  height: 16,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      color: CustomColor.primaryLightColor.withOpacity(0.15),
                      child: Center(
                        child: Text(code.isNotEmpty ? code[0] : '?',
                            style: const TextStyle(
                                fontSize: 9, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                ),
              ),
            if (imageUrl.isNotEmpty) const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 70),
              child: Text(
                code,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: Dimensions.headingTextSize5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: textColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}

class _PickerItem {
  final String imageUrl;
  final String primary;
  final String secondary;
  final VoidCallback onTap;
  const _PickerItem({
    required this.imageUrl,
    required this.primary,
    required this.secondary,
    required this.onTap,
  });
}
