// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';

import 'custom_color.dart';

class Themes {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  _saveThemeToBox(bool isDarkMode) => _box.write(_key, isDarkMode);

  bool _loadThemeFromBox() => _box.read(_key) ?? false;

  ThemeMode get theme => _loadThemeFromBox() ? ThemeMode.dark : ThemeMode.light;

  void switchTheme() {
    Get.changeThemeMode(_loadThemeFromBox() ? ThemeMode.light : ThemeMode.dark);
    _saveThemeToBox(!_loadThemeFromBox());
  }

  static final light = ThemeData.light().copyWith(
    useMaterial3: true,
    primaryColor: CustomColor.primaryLightColor,
    scaffoldBackgroundColor: CustomColor.primaryLightScaffoldBackgroundColor,
    brightness: Brightness.light,
    textTheme: ThemeData.dark().textTheme.apply(
          // bodyColor: Colors.white,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
    colorScheme: const ColorScheme(
        brightness: Brightness.light,
        error: CustomColor.primaryBGLightColor,
        onError: CustomColor.primaryBGLightColor,
        onPrimary: CustomColor.primaryBGLightColor,
        onSecondary: CustomColor.primaryBGLightColor,
        onSurface: CustomColor.primaryBGLightColor,
        primary: CustomColor.primaryBGLightColor,
        secondary: CustomColor.primaryBGLightColor,
        surface: CustomColor.primaryBGLightColor,
        background: CustomColor.primaryBGLightColor,
        onBackground: CustomColor.primaryBGLightColor), // Added this line
  );

  static final dark = ThemeData.dark().copyWith(
    useMaterial3: true,
    primaryColor: CustomColor.primaryDarkColor,
    scaffoldBackgroundColor: CustomColor.primaryDarkScaffoldBackgroundColor,
    brightness: Brightness.dark,
    textTheme: ThemeData.dark().textTheme.apply(
          // bodyColor: Colors.white,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
    colorScheme: const ColorScheme(
        brightness: Brightness.light,
        error: CustomColor.primaryBGDarkColor,
        onError: CustomColor.primaryBGDarkColor,
        onPrimary: CustomColor.primaryBGDarkColor,
        onSecondary: CustomColor.primaryBGDarkColor,
        onSurface: CustomColor.primaryBGDarkColor,
        primary: CustomColor.primaryBGDarkColor,
        secondary: CustomColor.primaryBGDarkColor,
        surface: CustomColor.primaryBGDarkColor,
        background: CustomColor.primaryBGDarkColor,
        onBackground: CustomColor.primaryBGDarkColor), // Added this line
  );
}
