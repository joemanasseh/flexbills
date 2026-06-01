import 'package:adescrow_app/controller/dashboard/bills/bills_controller.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class BillStatusScreen extends GetView<BillsController> {
  const BillStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Obx(() {
            final status = controller.paymentStatus.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: status == 'pending'
                  ? _buildPending(context, textColor, isDark)
                  : status == 'successful'
                      ? _buildSuccess(context, textColor, isDark)
                      : _buildFailed(context, textColor, isDark),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPending(
      BuildContext context, Color textColor, bool isDark) =>
      Center(
        key: const ValueKey('pending'),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 1.5),
            Text(
              'Processing Payment',
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize2,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.5),
            Text(
              'Please wait while we confirm\nyour transaction…',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize4,
                color: textColor.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.8),
            Obx(() => Text(
                  'Ref: ${controller.paymentReference.value}',
                  style: GoogleFonts.sourceCodePro(
                    fontSize: Dimensions.headingTextSize6,
                    color: textColor.withOpacity(0.35),
                  ),
                )),
          ],
        ),
      );

  Widget _buildSuccess(
      BuildContext context, Color textColor, bool isDark) =>
      Padding(
        key: const ValueKey('successful'),
        padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal * 1.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Animate(
              effects: const [
                ScaleEffect(begin: Offset(0.5, 0.5), end: Offset(1, 1)),
                FadeEffect(),
              ],
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: CustomColor.greenColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: CustomColor.greenColor, size: 52),
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 1.5),
            Text(
              'Payment Successful!',
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize1,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.5),
            Text(
              'Your bill payment has been processed\nand value delivered.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize4,
                color: textColor.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 1.2),
            Obx(() {
              final data = controller.lastStatusData;
              final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
              final borderColor = isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.grey.withOpacity(0.13);
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeHorizontal * 0.9,
                  vertical: Dimensions.paddingSizeVertical * 0.8,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radius * 1.5),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    if (data?.provider.isNotEmpty == true)
                      _statusRow('Provider', data!.provider, textColor),
                    if (data?.amount != null && data!.amount > 0) ...[
                      _statusDivider(borderColor),
                      _statusRow(
                        'Amount',
                        '${data.currency.isNotEmpty ? data.currency : 'NGN'} ${data.amount.toFiatString()}',
                        textColor,
                      ),
                    ],
                    if (data?.fee != null && data!.fee > 0) ...[
                      _statusDivider(borderColor),
                      _statusRow(
                        'Fee',
                        '${data.currency.isNotEmpty ? data.currency : 'NGN'} ${data.fee.toFiatString()}',
                        textColor,
                      ),
                    ],
                    _statusDivider(borderColor),
                    _statusRow(
                      'Reference',
                      controller.paymentReference.value,
                      textColor,
                      mono: true,
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: Dimensions.marginSizeVertical * 2),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: controller.resetAndGoHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColor.greenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radius * 1.5),
                  ),
                ),
                child: Text(
                  'Done',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: Dimensions.headingTextSize4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _statusRow(String label, String value, Color textColor,
          {bool mono = false}) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize5,
                color: textColor.withOpacity(0.5),
              ),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: mono
                    ? GoogleFonts.sourceCodePro(
                        fontSize: Dimensions.headingTextSize6,
                        color: textColor.withOpacity(0.45),
                      )
                    : GoogleFonts.inter(
                        fontSize: Dimensions.headingTextSize5,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
              ),
            ),
          ],
        ),
      );

  Widget _statusDivider(Color borderColor) =>
      Divider(height: 1, thickness: 1, color: borderColor);

  Widget _buildFailed(
      BuildContext context, Color textColor, bool isDark) =>
      Padding(
        key: const ValueKey('failed'),
        padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal * 1.2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Animate(
              effects: const [
                ScaleEffect(begin: Offset(0.5, 0.5), end: Offset(1, 1)),
                FadeEffect(),
              ],
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: CustomColor.redColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_rounded,
                    color: CustomColor.redColor, size: 52),
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 1.5),
            Text(
              'Payment Failed',
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize1,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 0.5),
            Text(
              'We could not confirm your payment.\nPlease try again or contact support.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize4,
                color: textColor.withOpacity(0.5),
                height: 1.5,
              ),
            ),
            SizedBox(height: Dimensions.marginSizeVertical * 2),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.resetAndGoHome,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: textColor.withOpacity(0.3)),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            Dimensions.radius * 1.5),
                      ),
                    ),
                    child: Text(
                      'Go Home',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.marginSizeHorizontal * 0.8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: Get.back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            Dimensions.radius * 1.5),
                      ),
                    ),
                    child: Text(
                      'Try Again',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
