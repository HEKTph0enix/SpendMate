import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'neumorphic_container.dart';

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? prefixText;
  final String? suffixText;
  final Widget? prefixIcon;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onFieldSubmitted;

  final TextCapitalization textCapitalization;
  final TextStyle? style;

  final int? maxLines;
  final int? maxLength;

  final bool enabled;
  final bool? isDense;
  final EdgeInsetsGeometry? contentPadding;

  const NeumorphicTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixText,
    this.suffixText,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onFieldSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.isDense,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: 4,
              bottom: 8,
            ),
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
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            inputFormatters: inputFormatters,
            validator: validator,
            textCapitalization: textCapitalization,
            style: style,
            maxLines: maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            onFieldSubmitted: onSubmitted ?? onFieldSubmitted,
            decoration: InputDecoration(
              hintText: hintText,
              prefixText: prefixText,
              suffixText: suffixText,
              prefixIcon: prefixIcon,
              isDense: isDense,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding:
              contentPadding ??
                  const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
              fillColor: Colors.transparent,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}