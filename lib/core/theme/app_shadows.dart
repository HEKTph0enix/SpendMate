import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> getNeumorphicShadow(bool isDark, {bool isInset = false, double elevation = 1.0}) {
    if (isInset) {
      // Inset shadow effect is usually simulated with inner shadows, 
      // but Flutter's BoxShadow doesn't natively support inset.
      // We will handle inset via inner container trick or just return empty for normal shadows and handle it in the widget.
      // However, we can use a trick with gradient or borders in the widget.
      // For BoxShadows, we just return the standard raised shadows here.
      return [];
    }
    
    return [
      BoxShadow(
        color: AppColors.getShadowDark(isDark),
        offset: Offset(4 * elevation, 4 * elevation),
        blurRadius: 10 * elevation,
        spreadRadius: 1 * elevation,
      ),
      BoxShadow(
        color: AppColors.getShadowLight(isDark),
        offset: Offset(-4 * elevation, -4 * elevation),
        blurRadius: 10 * elevation,
        spreadRadius: 1 * elevation,
      ),
    ];
  }
}
