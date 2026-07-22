import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// A neobrutalist toggle switch with thick border and hard shadow.
class NeoBrutalToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeoBrutalToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.getSurface(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getBorder(isDark),
            width: AppSpacing.borderWidth,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.getBorder(isDark),
              offset: const Offset(2, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? Colors.white : AppColors.getTextSecondary(isDark),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.getBorder(isDark),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
