import 'package:flutter/material.dart';
import 'neumorphic_container.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_colors.dart';

class NeumorphicDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? labelText;
  final Widget? prefixIcon;

  const NeumorphicDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.labelText,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              labelText!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.getTextSecondary(isDark),
              ),
            ),
          ),
        ],
        NeumorphicContainer(
          isInset: true,
          borderRadius: AppSpacing.radiusMd,
          padding: EdgeInsets.zero,
          child: DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: prefixIcon,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              fillColor: Colors.transparent,
              filled: true,
            ),
            icon: const Icon(Icons.keyboard_arrow_down),
            dropdownColor: AppColors.getSurface(isDark),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ],
    );
  }
}
