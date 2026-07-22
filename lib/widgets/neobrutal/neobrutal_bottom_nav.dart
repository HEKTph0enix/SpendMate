import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shadows.dart';
import '../../core/theme/app_spacing.dart';

/// Neobrutalist bottom navigation bar.
///
/// 4 tabs: Dashboard (0), Insights (1), Groups (2), Settings (3).
/// Centered + button is an action button, NOT part of selectedIndex.
class NeoBrutalBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onAddPressed;

  const NeoBrutalBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onAddPressed,
  });

  static const _items = <_NavItemData>[
    _NavItemData(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Home'),
    _NavItemData(
        icon: Icons.insights_outlined,
        activeIcon: Icons.insights,
        label: 'Insights'),
    // gap for the + button
    _NavItemData(
        icon: Icons.group_outlined, activeIcon: Icons.group, label: 'Groups'),
    _NavItemData(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.getSurface(isDark),
        border: Border(
          top: BorderSide(
            color: AppColors.getBorder(isDark),
            width: AppSpacing.borderWidth,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // First two tabs
              _buildNavItem(context, isDark, 0, _items[0]),
              _buildNavItem(context, isDark, 1, _items[1]),

              // Center + button
              _buildAddButton(context, isDark),

              // Last two tabs
              _buildNavItem(context, isDark, 2, _items[2]),
              _buildNavItem(context, isDark, 3, _items[3]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, bool isDark, int index, _NavItemData item) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                  color: AppColors.getBorder(isDark),
                  width: AppSpacing.borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getBorder(isDark),
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.getTextSecondary(isDark),
              size: 24,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.getTextSecondary(isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, bool isDark) {
    return _NeoBrutalFab(
      onPressed: onAddPressed,
      isDark: isDark,
    );
  }
}

class _NeoBrutalFab extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isDark;

  const _NeoBrutalFab({required this.onPressed, required this.isDark});

  @override
  State<_NeoBrutalFab> createState() => _NeoBrutalFabState();
}

class _NeoBrutalFabState extends State<_NeoBrutalFab> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: _isPressed
            ? (Matrix4.identity()..translate(2.0, 2.0))
            : (Matrix4.identity()..translate(0.0, -8.0)),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.getBorder(widget.isDark),
            width: AppSpacing.borderWidthThick,
          ),
          boxShadow: _isPressed
              ? AppShadows.pressed(widget.isDark)
              : AppShadows.hard(widget.isDark),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
