import 'package:flutter/material.dart';
import 'neumorphic_container.dart';
import 'neumorphic_icon_button.dart';

class NeumorphicBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onAddPressed;

  const NeumorphicBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.only(bottom: 24, top: 12, left: 16, right: 16),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(context, 0, Icons.dashboard_outlined, Icons.dashboard),
          _buildNavItem(context, 1, Icons.analytics_outlined, Icons.analytics),
          
          // Center FAB-like button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: NeumorphicIconButton(
              icon: Icons.add,
              onPressed: onAddPressed,
              size: 32,
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
          
          _buildNavItem(context, 2, Icons.lightbulb_outline, Icons.lightbulb),
          _buildNavItem(context, 3, Icons.group_outlined, Icons.group),
          // We have 5 screens, but I'll add the 5th one or adjust. The original has 5.
          // Let's keep 4 + FAB if we want, or add the 5th.
          // Original: Dashboard, Insights, Savings, Groups, Settings.
          // Since we have a FAB in the middle, we can put Settings here too.
          _buildNavItem(context, 4, Icons.settings_outlined, Icons.settings),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData outlineIcon, IconData filledIcon) {
    final isSelected = selectedIndex == index;
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        child: isSelected
            ? NeumorphicContainer(
                isInset: true,
                shape: BoxShape.circle,
                padding: const EdgeInsets.all(12),
                child: Icon(filledIcon, color: theme.colorScheme.primary),
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(outlineIcon, color: theme.colorScheme.onSurfaceVariant),
              ),
      ),
    );
  }
}
