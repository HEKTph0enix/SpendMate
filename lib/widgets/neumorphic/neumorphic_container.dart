import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final bool isInset;
  final bool isPressed;
  final BoxShape shape;
  final Color? customColor;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.isInset = false,
    this.isPressed = false,
    this.shape = BoxShape.rectangle,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // The base color of the container should be the surface color
    final color = customColor ?? AppColors.getSurface(isDark);
    
    final shadowScale = isPressed ? 0.5 : 1.0;
    
    // For inset shadows in Flutter, we use an inner linear gradient trick or stack
    // Since BoxShadow doesn't natively support inset, we approximate or use a simple
    // outer shadow for raised, and no outer shadow + darker color for inset.
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: isInset || isPressed ? _darken(color, 0.05) : color,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        shape: shape,
        boxShadow: (isInset || isPressed)
            ? [] // We remove outer shadows for inset/pressed
            : AppShadows.getNeumorphicShadow(isDark, elevation: shadowScale),
      ),
      child: child,
    );
  }

  Color _darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
