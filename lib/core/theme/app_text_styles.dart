import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle pageHeading(bool isDark) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle sectionHeading(bool isDark) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle cardTitle(bool isDark) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle cardSubtitle(bool isDark) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.getTextSecondary(isDark),
      );

  static TextStyle body(bool isDark) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle bodySmall(bool isDark) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.getTextSecondary(isDark),
      );

  static TextStyle label(bool isDark) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle bigAmount(bool isDark) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.getTextPrimary(isDark),
      );

  static TextStyle buttonText({Color? color}) => TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: color ?? Colors.white,
      );
}
