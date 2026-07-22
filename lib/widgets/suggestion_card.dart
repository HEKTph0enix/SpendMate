import 'package:flutter/material.dart';
import '../models/savings_suggestion.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'neobrutal/neobrutal_card.dart';

class SuggestionCard extends StatelessWidget {
  final SavingsSuggestion suggestion;
  final VoidCallback onDismiss;

  const SuggestionCard({
    Key? key,
    required this.suggestion,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color priorityColor;
    IconData priorityIcon;

    switch (suggestion.priority) {
      case SuggestionPriority.high:
        priorityColor = AppColors.error;
        priorityIcon = Icons.warning_amber_rounded;
        break;
      case SuggestionPriority.medium:
        priorityColor = AppColors.accentOrange;
        priorityIcon = Icons.info_outline;
        break;
      case SuggestionPriority.low:
        priorityColor = AppColors.accentGreen;
        priorityIcon = Icons.lightbulb_outline;
        break;
    }

    return NeoBrutalCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(priorityIcon, color: priorityColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Potential Savings: ₹${suggestion.estimatedSavings.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: priorityColor,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.getBorder(isDark), width: 1.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.close, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            suggestion.reason,
            style: AppTextStyles.body(isDark),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border:
                  Border.all(color: AppColors.getBorder(isDark), width: 1.5),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.accentBlue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.recommendedAction,
                    style: AppTextStyles.bodySmall(isDark),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
