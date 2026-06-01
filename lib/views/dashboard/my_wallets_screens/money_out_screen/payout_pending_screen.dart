import 'package:adescrow_app/utils/basic_screen_imports.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../routes/routes.dart';

class PayoutPendingScreen extends StatelessWidget {
  const PayoutPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map<String, dynamic>? ) ?? {};
    final ref      = args['ref']      as String? ?? '—';
    final amount   = args['amount']   as String? ?? '—';
    final currency = args['currency'] as String? ?? '';
    final message  = args['message']  as String? ?? '';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? CustomColor.primaryDarkTextColor
        : CustomColor.primaryLightTextColor;
    final cardColor = isDark ? Colors.grey[900]! : Colors.white;

    return WillPopScope(
      // Block hardware back — user must use the explicit button.
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal * 1.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon ──────────────────────────────────────────────────
                Animate(
                  effects: const [ScaleEffect(begin: Offset(0.5, 0.5)), FadeEffect()],
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: CustomColor.primaryLightColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      color: CustomColor.primaryLightColor,
                      size: 48,
                    ),
                  ),
                ),

                SizedBox(height: Dimensions.marginSizeVertical * 1.5),

                // ── Headline ──────────────────────────────────────────────
                Text(
                  'Transfer Pending',
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize1,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),

                SizedBox(height: Dimensions.marginSizeVertical * 0.5),

                Text(
                  'We couldn\'t confirm your transfer in time,\n'
                  'but it may still be processing on our ledger.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize4,
                    color: textColor.withOpacity(0.55),
                    height: 1.6,
                  ),
                ),

                SizedBox(height: Dimensions.marginSizeVertical * 1.5),

                // ── Detail card ───────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(Dimensions.paddingSizeHorizontal),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radius * 1.5),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.grey.withOpacity(0.15),
                    ),
                  ),
                  child: Column(
                    children: [
                      _row('Amount', '$amount $currency', textColor),
                      Divider(
                          height: Dimensions.marginSizeVertical,
                          color: textColor.withOpacity(0.08)),
                      _row('Reference', ref, textColor, mono: true),
                      if (message.isNotEmpty) ...[
                        Divider(
                            height: Dimensions.marginSizeVertical,
                            color: textColor.withOpacity(0.08)),
                        _row('Reason', message, textColor),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.marginSizeVertical),

                // ── Notice ────────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CustomColor.yellowColor.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radius),
                    border: Border.all(
                        color: CustomColor.yellowColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          size: 18,
                          color: CustomColor.yellowColor.withOpacity(0.9)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Keep your reference safe. If funds are debited and the '
                          'transfer does not arrive within 24 hours, contact '
                          'support with this reference.',
                          style: GoogleFonts.inter(
                            fontSize: Dimensions.headingTextSize6,
                            color: textColor.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.marginSizeVertical * 2),

                // ── Action ────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(Routes.dashboardScreen),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.primaryLightColor,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius * 1.5),
                      ),
                    ),
                    child: Text(
                      'Go to Dashboard',
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
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, Color textColor,
      {bool mono = false}) {
    return Row(
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
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  )
                : GoogleFonts.inter(
                    fontSize: Dimensions.headingTextSize5,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
          ),
        ),
      ],
    );
  }
}
