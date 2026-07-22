import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Primary Brand Colors ────────────────────────────────────────
  static const primary = Color(0xFF7C3AED); // Bright purple
  static const secondary = Color(0xFF14B8A6); // Teal
  static const tertiary = Color(0xFFFB7185); // Coral

  // ─── Neobrutalist Light Theme ────────────────────────────────────
  static const lightBg = Color(0xFFFFF8F0); // Cream / off-white
  static const lightSurface = Color(0xFFFFFDF9); // Slightly lighter cream
  static const lightTextPrimary = Color(0xFF1A1A2E);
  static const lightTextSecondary = Color(0xFF4A4A5A);
  static const lightBorder = Color(0xFF1A1A2E); // Near-black borders
  static const lightIcon = Color(0xFF1A1A2E);
  static const lightDivider = Color(0xFF1A1A2E);

  // ─── Neobrutalist Dark Theme ─────────────────────────────────────
  static const darkBg = Color(0xFF1A1A2E);
  static const darkSurface = Color(0xFF252540);
  static const darkTextPrimary = Color(0xFFF5F5F0);
  static const darkTextSecondary = Color(0xFFB0B0C0);
  static const darkBorder = Color(0xFFF5F5F0); // Off-white borders on dark
  static const darkIcon = Color(0xFFF5F5F0);
  static const darkDivider = Color(0xFF3A3A50);

  // ─── Accent / Card Colors ───────────────────────────────────────
  static const accentPurple = Color(0xFF7C3AED);
  static const accentTeal = Color(0xFF14B8A6);
  static const accentYellow = Color(0xFFFACC15);
  static const accentBlue = Color(0xFF3B82F6);
  static const accentGreen = Color(0xFF22C55E);
  static const accentCoral = Color(0xFFFB7185);
  static const accentOrange = Color(0xFFF97316);

  /// Pastel card backgrounds for light mode
  static const List<Color> lightCardAccentColors = [
    Color(0xFFE8DBFF), // light purple
    Color(0xFFCCFBF1), // light teal
    Color(0xFFFEF9C3), // light yellow
    Color(0xFFDBEAFE), // light blue
    Color(0xFFDCFCE7), // light green
    Color(0xFFFFE4E6), // light coral
    Color(0xFFFFEDD5), // light orange
  ];

  /// Deep card backgrounds for dark mode to ensure white text is visible
  static const List<Color> darkCardAccentColors = [
    Color(0xFF3B286D), // deep purple
    Color(0xFF0F5A53), // deep teal
    Color(0xFF715F00), // deep yellow/olive
    Color(0xFF1E3A8A), // deep blue
    Color(0xFF14532D), // deep green
    Color(0xFF881337), // deep coral/red
    Color(0xFF7C2D12), // deep orange
  ];

  // ─── Semantic Colors ────────────────────────────────────────────
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFFACC15);
  static const info = Color(0xFF3B82F6);

  // ─── Helpers ────────────────────────────────────────────────────
  static Color getBg(bool isDark) => isDark ? darkBg : lightBg;
  static Color getSurface(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color getTextPrimary(bool isDark) =>
      isDark ? darkTextPrimary : lightTextPrimary;
  static Color getTextSecondary(bool isDark) =>
      isDark ? darkTextSecondary : lightTextSecondary;
  static Color getBorder(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color getDivider(bool isDark) => isDark ? darkDivider : lightDivider;
  
  static List<Color> getCardAccentColors(bool isDark) => 
      isDark ? darkCardAccentColors : lightCardAccentColors;
}
