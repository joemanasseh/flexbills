import 'package:adescrow_app/controller/dashboard/bills/bills_controller.dart';
import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class BillBillerScreen extends GetView<BillsController> {
  const BillBillerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;

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
        title: Obx(() => Text(
              controller.selectedCategoryName.value,
              style: GoogleFonts.inter(
                fontSize: Dimensions.headingTextSize3,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            )),
        bottom: BreadcrumbBar(crumbs: [
          'Home',
          'Bills',
          controller.selectedCategoryName.value,
        ]),
      ),
      body: Obx(() {
        if (controller.isLoadingBillers) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.billers.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_rounded,
                    size: 56, color: textColor.withOpacity(0.25)),
                const SizedBox(height: 12),
                Text(
                  'No billers available',
                  style: GoogleFonts.inter(
                      fontSize: Dimensions.headingTextSize4,
                      color: textColor.withOpacity(0.45)),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal),
          itemCount: controller.billers.length,
          separatorBuilder: (_, __) =>
              SizedBox(height: Dimensions.marginSizeVertical * 0.5),
          itemBuilder: (context, index) {
            final biller = controller.billers[index];
            final cardBg = isDark ? const Color(0xFF141921) : Colors.white;
            final borderColor = isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.grey.withOpacity(0.13);
            return Animate(
              effects: [
                FadeEffect(delay: (index * 40).ms),
                const SlideEffect(
                    begin: Offset(0, 0.06), end: Offset.zero),
              ],
              child: InkWell(
                onTap: () => controller.openBillerForm(biller),
                borderRadius:
                    BorderRadius.circular(Dimensions.radius * 1.5),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeHorizontal * 0.8,
                    vertical: Dimensions.paddingSizeVertical * 0.7,
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
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .primaryColor
                              .withOpacity(0.1),
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
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                            if (!biller.isVariableAmount) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Fixed: ₦${biller.amount.toWholeString()}',
                                style: GoogleFonts.inter(
                                  fontSize: Dimensions.headingTextSize6,
                                  color: textColor.withOpacity(0.45),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (biller.fee > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: CustomColor.greenColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Fee: ₦${biller.fee.toWholeString()}',
                            style: GoogleFonts.inter(
                              fontSize: Dimensions.headingTextSize6,
                              color: CustomColor.greenColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      SizedBox(
                          width: Dimensions.marginSizeHorizontal * 0.4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: textColor.withOpacity(0.3),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
