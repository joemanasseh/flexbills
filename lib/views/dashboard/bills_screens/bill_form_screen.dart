import 'package:adescrow_app/controller/dashboard/bills/bills_controller.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:google_fonts/google_fonts.dart';

class BillFormScreen extends GetView<BillsController> {
  const BillFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
    final inputBg = isDark ? const Color(0xFF1A2035) : Colors.grey.shade50;
    final borderColor = isDark
        ? Colors.white.withOpacity(0.08)
        : Colors.grey.withOpacity(0.2);

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
          'Enter Details',
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
          'Enter Details',
        ]),
      ),
      body: Obx(() {
        final biller = controller.selectedBiller.value;
        if (biller == null) return const SizedBox.shrink();

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.all(Dimensions.paddingSizeHorizontal),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Biller info card
                    Container(
                      padding: EdgeInsets.all(
                          Dimensions.paddingSizeHorizontal * 0.9),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .primaryColor
                            .withOpacity(0.08),
                        borderRadius: BorderRadius.circular(
                            Dimensions.radius * 1.5),
                        border: Border.all(
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                biller.name.isNotEmpty
                                    ? biller.name[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w800,
                                  fontSize: Dimensions.headingTextSize3,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                              width: Dimensions.marginSizeHorizontal * 0.7),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  biller.name,
                                  style: GoogleFonts.inter(
                                    fontSize: Dimensions.headingTextSize4,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                                ),
                                Text(
                                  controller.selectedCategoryName.value,
                                  style: GoogleFonts.inter(
                                    fontSize: Dimensions.headingTextSize6,
                                    color: textColor.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.marginSizeVertical * 1.2),

                    // Customer ID field
                    _label(biller.labelName, textColor),
                    SizedBox(height: Dimensions.marginSizeVertical * 0.4),
                    _inputField(
                      controller: controller.customerController,
                      hint: 'Enter ${biller.labelName}',
                      keyboardType: TextInputType.text,
                      cardBg: cardBg,
                      inputBg: inputBg,
                      borderColor: borderColor,
                      textColor: textColor,
                      onChanged: (_) => controller.resetValidation(),
                      suffix: Obx(() => controller.isValidated
                          ? const Icon(Icons.check_circle_rounded,
                              color: CustomColor.greenColor, size: 20)
                          : const SizedBox.shrink()),
                    ),
                    SizedBox(height: Dimensions.marginSizeVertical * 0.6),

                    // Validate button
                    Obx(() => controller.isValidated
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: CustomColor.greenColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.person_rounded,
                                    color: CustomColor.greenColor, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.validatedName.value,
                                    style: GoogleFonts.inter(
                                      fontSize: Dimensions.headingTextSize5,
                                      fontWeight: FontWeight.w600,
                                      color: CustomColor.greenColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: controller.isValidating
                                  ? null
                                  : controller.validateCustomer,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Theme.of(context).primaryColor),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius * 1.2),
                                ),
                              ),
                              child: controller.isValidating
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color:
                                            Theme.of(context).primaryColor,
                                      ),
                                    )
                                  : Text(
                                      'Validate ${biller.labelName}',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(context).primaryColor,
                                      ),
                                    ),
                            ),
                          )),

                    SizedBox(height: Dimensions.marginSizeVertical * 1.2),

                    // Phone field (for airtime/data)
                    if (biller.isAirtime) ...[
                      _label('Phone Number', textColor),
                      SizedBox(
                          height: Dimensions.marginSizeVertical * 0.4),
                      _inputField(
                        controller: controller.phoneController,
                        hint: 'e.g. 08012345678',
                        keyboardType: TextInputType.phone,
                        cardBg: cardBg,
                        inputBg: inputBg,
                        borderColor: borderColor,
                        textColor: textColor,
                      ),
                      SizedBox(
                          height: Dimensions.marginSizeVertical * 1.2),
                    ],

                    // Amount field
                    _label('Amount (₦)', textColor),
                    SizedBox(height: Dimensions.marginSizeVertical * 0.4),
                    _inputField(
                      controller: controller.amountController,
                      hint: biller.isVariableAmount
                          ? 'Enter amount'
                          : '₦${biller.amount.toFiatString()}',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      cardBg: cardBg,
                      inputBg: inputBg,
                      borderColor: borderColor,
                      textColor: textColor,
                      enabled: biller.isVariableAmount,
                    ),

                    if (biller.fee > 0) ...[
                      SizedBox(
                          height: Dimensions.marginSizeVertical * 0.6),
                      Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              size: 14,
                              color: textColor.withOpacity(0.4)),
                          const SizedBox(width: 6),
                          Text(
                            'Service fee: ₦${biller.fee.toFiatString()}',
                            style: GoogleFonts.inter(
                              fontSize: Dimensions.headingTextSize6,
                              color: textColor.withOpacity(0.45),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Continue button
            Obx(() => _continueButton(context, textColor)),
          ],
        );
      }),
    );
  }

  Widget _label(String text, Color textColor) => Text(
        text,
        style: GoogleFonts.inter(
          fontSize: Dimensions.headingTextSize5,
          fontWeight: FontWeight.w600,
          color: textColor.withOpacity(0.7),
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
    required Color cardBg,
    required Color inputBg,
    required Color borderColor,
    required Color textColor,
    bool enabled = true,
    Widget? suffix,
    void Function(String)? onChanged,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: enabled ? inputBg : inputBg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
          border: Border.all(color: borderColor),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          onChanged: onChanged,
          style: GoogleFonts.inter(
            fontSize: Dimensions.headingTextSize4,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: Dimensions.headingTextSize4,
              color: textColor.withOpacity(0.35),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeHorizontal * 0.7,
              vertical: Dimensions.paddingSizeVertical * 0.6,
            ),
            suffixIcon: suffix,
          ),
        ),
      );

  Widget _continueButton(BuildContext context, Color textColor) {
    final canContinue = controller.isValidated &&
        controller.amountController.text.trim().isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canContinue ? controller.goToPreview : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              disabledBackgroundColor:
                  Theme.of(context).primaryColor.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(Dimensions.radius * 1.5),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: Dimensions.headingTextSize4,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
