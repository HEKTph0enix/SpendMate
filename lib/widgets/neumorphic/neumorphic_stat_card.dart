import 'package:flutter/material.dart';
import 'neumorphic_container.dart';
import '../../core/theme/app_spacing.dart';

class NeumorphicStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const NeumorphicStatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = NeumorphicContainer(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              NeumorphicContainer(
                isInset: true,
                padding: const EdgeInsets.all(8),
                shape: BoxShape.circle,
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amount,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
