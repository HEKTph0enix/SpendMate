import 'package:flutter/material.dart';
import 'neumorphic_container.dart';
import '../../core/theme/app_spacing.dart';

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = AppSpacing.radiusMd,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14.0),
    this.color,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
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
    final opacity = widget.onPressed == null ? 0.5 : 1.0;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: NeumorphicContainer(
          isPressed: _isPressed,
          borderRadius: widget.borderRadius,
          padding: widget.padding,
          customColor: widget.color,
          child: DefaultTextStyle(
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: widget.color != null ? Colors.white : Theme.of(context).colorScheme.primary,
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
