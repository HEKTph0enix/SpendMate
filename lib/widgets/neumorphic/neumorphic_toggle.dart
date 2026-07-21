import 'package:flutter/material.dart';
import 'neumorphic_container.dart';

class NeumorphicToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const NeumorphicToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: NeumorphicContainer(
        isInset: true,
        borderRadius: 20,
        padding: const EdgeInsets.all(4),
        width: 60,
        height: 32,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: NeumorphicContainer(
            shape: BoxShape.circle,
            width: 24,
            height: 24,
            customColor: value ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            child: const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
