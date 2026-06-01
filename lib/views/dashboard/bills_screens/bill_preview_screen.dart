import 'package:adescrow_app/controller/dashboard/bills/bills_controller.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:google_fonts/google_fonts.dart';

class BillPreviewScreen extends GetView<BillsController> {
  const BillPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.07)
        : Colors.grey.withOpacity(0.13);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: textColor, size: 20),
          onPressed: Get.back,
        ),
        title: Text(
          'Review Payment',
          style: GoogleFonts.inter(
            fontSize: Dimensions.headingTextSize3,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        bottom: BreadcrumbBar(crumbs: [
          'Home',
          'Bills',
          controller.selectedCategoryName.value,
          'Review',
        ]),
      ),
      body: Obx(() {
        final biller = controller.selectedBiller.value;
        if (biller == null) return const SizedBox.shrink();

        final amount =
            double.tryParse(controller.amountController.text.trim()) ?? 0;
        final total = amount + biller.fee;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.all(Dimensions.paddingSizeHorizontal),
                child: Column(
                  children: [
                    // Amount hero
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.paddingSizeVertical * 1.5,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.12),
                            Theme.of(context).primaryColor.withOpacity(0.04),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius * 2),
                        border: Border.all(
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'You are paying',
                            style: GoogleFonts.inter(
                              fontSize: Dimensions.headingTextSize5,
                              color: textColor.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₦${amount.toFiatString()}',
                            style: GoogleFonts.inter(
                              fontSize: Dimensions.headingTextSize1 * 1.4,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            biller.name,
                            style: GoogleFonts.inter(
                              fontSize: Dimensions.headingTextSize4,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Dimensions.marginSizeVertical * 1.2),

                    // Details card
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius * 1.5),
                        border: Border.all(color: borderColor),
                        boxShadow: isDark
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                )
                              ],
                      ),
                      child: Column(
                        children: [
                          _row(context, Icons.person_rounded, 'Customer',
                              controller.validatedName.value, textColor),
                          _divider(borderColor),
                          _row(
                              context,
                              Icons.receipt_rounded,
                              biller.labelName,
                              controller.customerController.text.trim(),
                              textColor),
                          _divider(borderColor),
                          _row(
                              context,
                              Icons.business_rounded,
                              'Biller',
                              biller.name,
                              textColor),
                          _divider(borderColor),
                          _row(
                              context,
                              Icons.category_rounded,
                              'Category',
                              controller.selectedCategoryName.value,
                              textColor),
                          _divider(borderColor),
                          _row(
                              context,
                              Icons.percent_rounded,
                              'Service Fee',
                              '₦${biller.fee.toFiatString()}',
                              textColor),
                          _divider(borderColor),
                          _row(
                              context,
                              Icons.payments_rounded,
                              'Total Payable',
                              '₦${total.toFiatString()}',
                              textColor,
                              isBold: true,
                              valueColor:
                                  Theme.of(context).primaryColor),
                        ],
                      ),
                    ),

                    SizedBox(height: Dimensions.marginSizeVertical * 1.2),

                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            CustomColor.yellowColor.withOpacity(0.08),
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius),
                        border: Border.all(
                          color:
                              CustomColor.yellowColor.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_rounded,
                              color: CustomColor.yellowColor, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Payment will only be delivered after confirmation from the network.',
                              style: GoogleFonts.inter(
                                fontSize: Dimensions.headingTextSize6,
                                color: textColor.withOpacity(0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confirm button
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal),
                child: Obx(() => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: controller.isPaying
                            ? null
                            : controller.initiatePayment,
                        icon: controller.isPaying
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white))
                            : const Icon(Icons.send_rounded,
                                size: 18, color: Colors.white),
                        label: Text(
                          controller.isPaying
                              ? 'Processing...'
                              : 'Confirm & Pay',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w700,
                            fontSize: Dimensions.headingTextSize4,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                Dimensions.radius * 1.5),
                          ),
                        ),
                      ),
                    )),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _divider(Color borderColor) => Divider(
      height: 1, thickness: 1, color: borderColor, indent: 16, endIndent: 16);

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color textColor, {
    bool isBold = false,
    Color? valueColor,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeHorizontal * 0.8,
          vertical: Dimensions.paddingSizeVertical * 0.55,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16,
                color: Theme.of(context).primaryColor.withOpacity(0.7)),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize5,
                color: textColor.withOpacity(0.5),
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: GoogleFonts.inter(
                  fontSize: Dimensions.headingTextSize5,
                  fontWeight:
                      isBold ? FontWeight.w700 : FontWeight.w600,
                  color: valueColor ?? textColor,
                ),
              ),
            ),
          ],
        ),
      );
}
