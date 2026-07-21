import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ─── Light Theme ───────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ─── Dark Theme ────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.tertiary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scaffoldBg = AppColors.getBg(isDark);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,

      // Typography
      fontFamily: 'Inter',
      textTheme: _buildTextTheme(isDark),

      // AppBar
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scaffoldBg,
        foregroundColor: AppColors.getTextPrimary(isDark),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.getTextPrimary(isDark),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: scaffoldBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scaffoldBg,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      
      // Floating Action Button Theme (fallback)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        thickness: 1,
        color: AppColors.getDivider(isDark),
      ),
    );
  }

  static TextTheme _buildTextTheme(bool isDark) {
    final color = AppColors.getTextPrimary(isDark);

    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.w700, color: color),
      displayMedium: TextStyle(fontFamily: 'Inter', fontSize: 28, fontWeight: FontWeight.w700, color: color),
      headlineLarge: TextStyle(fontFamily: 'Inter', fontSize: 24, fontWeight: FontWeight.w600, color: color),
      headlineMedium: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w500, color: color),
      titleSmall: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w500, color: color),
      bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodySmall: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.getTextSecondary(isDark)),
      labelLarge: TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600, color: color),
      labelMedium: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w500, color: AppColors.getTextSecondary(isDark)),
    );
  }
}
