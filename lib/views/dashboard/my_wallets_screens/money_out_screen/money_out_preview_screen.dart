import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:adescrow_app/utils/responsive_layout.dart';
import 'package:adescrow_app/widgets/others/custom_loading_widget.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../controller/dashboard/my_wallets/money_out_controller.dart';

class MoneyOutPreviewScreen extends GetView<MoneyOutController> {
  const MoneyOutPreviewScreen({super.key});

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
        'Review Transfer',
        style: GoogleFonts.inter(
          fontSize: Dimensions.headingTextSize3,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
      centerTitle: false,
      bottom: const BreadcrumbBar(crumbs: ['Home', 'Wallet', 'Send Money', 'Review']),
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
              children: [
                _summaryCard(context, isDark),
                SizedBox(height: Dimensions.marginSizeVertical * 0.8),
                _detailsCard(context, isDark),
                SizedBox(height: Dimensions.marginSizeVertical),
              ],
            ),
          ),
        ),
        _confirmButton(context, isDark),
      ],
    );
  }

  // ──────────────────── Transfer summary card ──────────────────────────

  Widget _summaryCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.13);
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return Animate(
      effects: [
        FadeEffect(duration: 350.ms),
        const SlideEffect(begin: Offset(0, 0.06), end: Offset.zero),
      ],
      child: Container(
        width: double.infinity,
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
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.paddingSizeHorizontal * 0.9,
                Dimensions.paddingSizeVertical * 0.85,
                Dimensions.paddingSizeHorizontal * 0.9,
                Dimensions.paddingSizeVertical * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sending',
                      style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize5,
                          color: textColor.withOpacity(0.5),
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: Dimensions.marginSizeVertical * 0.2),
                  Text(
                    '${controller.amountController.text} ${controller.selectedCurrency.value}',
                    style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize1 * 1.3,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Divider(height: 1, color: borderColor),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CustomColor.primaryLightColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: CustomColor.primaryLightColor.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.south_rounded,
                      color: CustomColor.primaryLightColor, size: 16),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                Dimensions.paddingSizeHorizontal * 0.9,
                Dimensions.paddingSizeVertical * 0.7,
                Dimensions.paddingSizeHorizontal * 0.9,
                Dimensions.paddingSizeVertical * 0.85,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Recipient gets',
                      style: GoogleFonts.inter(
                          fontSize: Dimensions.headingTextSize5,
                          color: textColor.withOpacity(0.5),
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: Dimensions.marginSizeVertical * 0.2),
                  Text(
                    '${controller.information.willGet} ${controller.selectedMethodCurrencyCode.value}',
                    style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize1 * 1.3,
                      fontWeight: FontWeight.w800,
                      color: CustomColor.greenColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────── Details card ────────────────────────────────

  Widget _detailsCard(BuildContext context, bool isDark) {
    final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.13);
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    final rows = <_DetailRow>[
      _DetailRow(Icons.tag_rounded, 'Reference',
          controller.information.trx, highlight: true),
      _DetailRow(Icons.percent_rounded, 'Total charge',
          controller.information.totalCharge),
      _DetailRow(Icons.swap_horiz_rounded, 'Exchange rate',
          controller.information.exchangeRate),
      _DetailRow(Icons.input_rounded, 'Request amount',
          controller.information.requestAmount),
      _DetailRow(Icons.south_east_rounded, 'Recipient gets',
          controller.information.willGet),
      _DetailRow(Icons.payment_rounded, 'Via',
          controller.information.gatewayCurrencyName),
      _DetailRow(Icons.receipt_long_rounded, 'Total payable',
          controller.information.payable, isBold: true),
    ];

    return Animate(
      effects: [FadeEffect(duration: 350.ms, delay: 80.ms)],
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * 0.85,
          vertical: Dimensions.paddingSizeVertical * 0.8,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(Dimensions.radius * 2),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction details',
                style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize4,
                    fontWeight: FontWeight.w700,
                    color: textColor)),
            SizedBox(height: Dimensions.marginSizeVertical * 0.6),
            ...rows.map((r) => _detailRow(r, isDark, textColor)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(_DetailRow row, bool isDark, Color textColor) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeVertical * 0.45),
          child: Row(
            children: [
              Icon(row.icon,
                  size: 15,
                  color: CustomColor.primaryLightColor.withOpacity(0.8)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(row.label,
                    style: GoogleFonts.inter(
                        fontSize: Dimensions.headingTextSize5,
                        color: textColor.withOpacity(0.55),
                        fontWeight: FontWeight.w500)),
              ),
              Flexible(
                child: Text(
                  row.value,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize5,
                    fontWeight:
                        row.isBold ? FontWeight.w700 : FontWeight.w600,
                    color: row.highlight
                        ? CustomColor.primaryLightColor
                        : (row.isBold
                            ? textColor
                            : textColor.withOpacity(0.85)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: textColor.withOpacity(0.07)),
      ],
    );
  }

  // ────────────────────── Confirm button ────────────────────────────────

  Widget _confirmButton(BuildContext context, bool isDark) {
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
              onPressed: controller.isLoading
                  ? null
                  : () => controller.onConfirmProcess(context),
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
              child: controller.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Confirm & Send',
                            style: GoogleFonts.inter(
                                fontSize: Dimensions.headingTextSize3,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(width: 8),
                        const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
            ),
          )),
    );
  }
}

class _DetailRow {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  final bool isBold;
  const _DetailRow(this.icon, this.label, this.value,
      {this.highlight = false, this.isBold = false});
}
