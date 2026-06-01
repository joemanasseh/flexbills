import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_color.dart';
import 'dimensions.dart';

class CustomStyle {
  static String get _font => GoogleFonts.inter().fontFamily!;

//------------------------dark--------------------------------
  static TextStyle get darkHeading1TextStyle => TextStyle(
    color: CustomColor.primaryDarkTextColor,
    fontSize: Dimensions.headingTextSize1,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle get darkHeading2TextStyle => TextStyle(
    color: CustomColor.primaryDarkTextColor,
    fontSize: Dimensions.headingTextSize2,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle get darkHeading3TextStyle => TextStyle(
    color: CustomColor.primaryDarkTextColor,
    fontSize: Dimensions.headingTextSize3,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle get darkHeading4TextStyle => TextStyle(
    color: CustomColor.primaryDarkTextColor,
    fontSize: Dimensions.headingTextSize4,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );
  static TextStyle get darkHeading5TextStyle => TextStyle(
    color: CustomColor.primaryDarkTextColor,
    fontSize: Dimensions.headingTextSize5,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

//------------------------light--------------------------------
  static TextStyle get lightHeading1TextStyle => TextStyle(
    color: CustomColor.primaryLightTextColor,
    fontSize: Dimensions.headingTextSize1,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle get lightHeading2TextStyle => TextStyle(
    color: CustomColor.primaryLightTextColor,
    fontSize: Dimensions.headingTextSize2,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle get lightHeading3TextStyle => TextStyle(
    color: CustomColor.primaryLightTextColor,
    fontSize: Dimensions.headingTextSize3,
    fontWeight: FontWeight.w700,
    fontFamily: _font,
  );
  static TextStyle get lightHeading4TextStyle => TextStyle(
    color: CustomColor.primaryLightTextColor,
    fontSize: Dimensions.headingTextSize4,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );
  static TextStyle get lightHeading5TextStyle => TextStyle(
    color: CustomColor.primaryLightTextColor,
    fontSize: Dimensions.headingTextSize5,
    fontWeight: FontWeight.w400,
    fontFamily: _font,
  );

  static var screenGradientBG2 = const BoxDecoration(
      gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
        CustomColor.primaryDarkColor,
        CustomColor.primaryBGDarkColor,
      ]));

// Button
//
//   static var secondaryButtonStyle = ElevatedButton.styleFrom(
//     elevation: 0,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(5))),
//   );
//   // Category
//   static var categoryButtonStyle = ElevatedButton.styleFrom(
//     elevation: 0,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(5))),
//   );
}
