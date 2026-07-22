import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  /// Standard hard shadow for neobrutalist elements.
  static List<BoxShadow> hard(bool isDark, {double offsetScale = 1.0}) {
    return [
      BoxShadow(
        color: AppColors.getBorder(isDark),
        offset: Offset(4 * offsetScale, 4 * offsetScale),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  /// Pressed-state shadow (reduced offset).
  static List<BoxShadow> pressed(bool isDark) {
    return [
      BoxShadow(
        color: AppColors.getBorder(isDark),
        offset: const Offset(1, 1),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ];
  }

  /// No shadow (for inset / flat states).
  static List<BoxShadow> none() => [];
}
