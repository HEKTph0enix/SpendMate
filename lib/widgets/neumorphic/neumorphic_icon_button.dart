import 'package:flutter/material.dart';
import 'neumorphic_container.dart';

class NeumorphicIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const NeumorphicIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = 24.0,
    this.color,
    this.backgroundColor,
  });

  @override
  State<NeumorphicIconButton> createState() => _NeumorphicIconButtonState();
}

class _NeumorphicIconButtonState extends State<NeumorphicIconButton> {
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
    final iconColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: NeumorphicContainer(
          shape: BoxShape.circle,
          isPressed: _isPressed,
          customColor: widget.backgroundColor,
          padding: EdgeInsets.all(widget.size * 0.4),
          child: Icon(
            widget.icon,
            size: widget.size,
            color: widget.backgroundColor != null ? Colors.white : iconColor,
          ),
        ),
      ),
    );
  }
}
