import 'package:flutter/material.dart';
import 'neumorphic_container.dart';
import '../../core/theme/app_spacing.dart';

class NeumorphicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final Color? customColor;

  const NeumorphicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin = const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    this.borderRadius = AppSpacing.radiusMd,
    this.onTap,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = NeumorphicContainer(
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      customColor: customColor,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
