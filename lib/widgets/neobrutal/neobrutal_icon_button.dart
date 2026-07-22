import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// A neobrutalist icon button with thick border, hard shadow, and press animation.
class NeoBrutalIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? iconColor;
  final Color? backgroundColor;

  const NeoBrutalIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 24.0,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  State<NeoBrutalIconButton> createState() => _NeoBrutalIconButtonState();
}

class _NeoBrutalIconButtonState extends State<NeoBrutalIconButton> {
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
    final bg = widget.backgroundColor ?? AppColors.getSurface(isDark);
    final isLight = bg.computeLuminance() > 0.5;
    final iconColor = widget.iconColor ??
        (isLight ? AppColors.lightTextPrimary : Colors.white);
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
              ? (Matrix4.identity()..translate(2.0, 2.0))
              : Matrix4.identity(),
          padding: EdgeInsets.all(widget.size * 0.4),
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.getBorder(isDark),
              width: AppSpacing.borderWidth,
            ),
            boxShadow: _isPressed
                ? AppShadows.pressed(isDark)
                : AppShadows.hard(isDark, offsetScale: 0.75),
          ),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
