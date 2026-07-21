import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const primary = Color(0xFF6C5CE7);
  static const secondary = Color(0xFF00CEC9);
  static const tertiary = Color(0xFFFD79A8);

  // Light Theme Colors
  static const lightBg = Color(0xFFE8EDF2);
  static const lightSurface = Color(0xFFE8EDF2);
  static const lightTextPrimary = Color(0xFF2D3436);
  static const lightTextSecondary = Color(0xFF636E72);
  static const lightShadowDark = Color(0xFFB8C5D1);
  static const lightShadowLight = Color(0xFFFFFFFF);
  static const lightIcon = Color(0xFF636E72);
  static const lightDivider = Color(0xFFDCDFE3);

  // Dark Theme Colors
  static const darkBg = Color(0xFF20242A);
  static const darkSurface = Color(0xFF20242A);
  static const darkTextPrimary = Color(0xFFF5F6FA);
  static const darkTextSecondary = Color(0xFFA4B0BE);
  static const darkShadowDark = Color(0xFF16191D);
  static const darkShadowLight = Color(0xFF2A2F37);
  static const darkIcon = Color(0xFFA4B0BE);
  static const darkDivider = Color(0xFF2D323A);

  // Semantic Colors
  static const success = Color(0xFF00B894);
  static const error = Color(0xFFD63031);
  static const warning = Color(0xFFFDCB6E);
  static const info = Color(0xFF0984E3);

  static Color getBg(bool isDark) => isDark ? darkBg : lightBg;
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getTextPrimary(bool isDark) => isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color getShadowDark(bool isDark) => isDark ? darkShadowDark : lightShadowDark;
  static Color getShadowLight(bool isDark) => isDark ? darkShadowLight : lightShadowLight;
  static Color getDivider(bool isDark) => isDark ? darkDivider : lightDivider;
}
