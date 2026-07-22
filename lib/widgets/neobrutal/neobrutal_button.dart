import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';

/// A neobrutalist button with thick border, hard shadow, and press animation.
class NeoBrutalButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const NeoBrutalButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.borderRadius = AppSpacing.radiusMd,
    this.padding =
        const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14.0),
  });

  @override
  State<NeoBrutalButton> createState() => _NeoBrutalButtonState();
}

class _NeoBrutalButtonState extends State<NeoBrutalButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = widget.backgroundColor ?? AppColors.primary;
    final isLight = bg.computeLuminance() > 0.5;
    final textColor = isLight ? AppColors.lightTextPrimary : Colors.white;
    final opacity = widget.onPressed == null ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: _isPressed
              ? (Matrix4.identity()..translate(3.0, 3.0))
              : Matrix4.identity(),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: AppColors.getBorder(isDark),
              width: AppSpacing.borderWidth,
            ),
            boxShadow: _isPressed
                ? AppShadows.pressed(isDark)
                : AppShadows.hard(isDark),
          ),
          child: DefaultTextStyle(
            style: AppTextStyles.buttonText(color: textColor),
            child: IconTheme(
              data: IconThemeData(color: textColor),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [widget.child],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
