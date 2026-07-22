import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';
import '../constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import 'neobrutal/neobrutal_card.dart';

class BudgetProgressCard extends StatelessWidget {
  final double limitAmount;
  final double usedAmount;
  final VoidCallback onTap;

  const BudgetProgressCard({
    super.key,
    required this.limitAmount,
    required this.usedAmount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remainingAmount =
        limitAmount - usedAmount > 0 ? limitAmount - usedAmount : 0.0;

    double usagePercentage = limitAmount > 0 ? usedAmount / limitAmount : 0.0;

    // Status colors
    Color statusColor;
    String statusText;

    if (usagePercentage < AppConstants.budgetSafeThreshold) {
      statusColor = AppColors.accentGreen;
      statusText = 'On Track';
    } else if (usagePercentage < AppConstants.budgetWarningThreshold) {
      statusColor = AppColors.accentOrange;
      statusText = 'Nearing Limit';
    } else {
      statusColor = AppColors.error;
      statusText = 'Over Budget';
      if (usagePercentage > 1.0) usagePercentage = 1.0;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: NeoBrutalCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Monthly Budget', style: AppTextStyles.cardTitle(isDark)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: AppColors.getBorder(isDark), width: 1.5),
                  ),
                  child: Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.format(usedAmount),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'of ${CurrencyFormatter.format(limitAmount)} used',
                      style: AppTextStyles.bodySmall(isDark),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(remainingAmount),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('left', style: AppTextStyles.bodySmall(isDark)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.getSurface(isDark),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.getBorder(isDark),
                  width: 1.5,
                ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Container(
                      width: constraints.maxWidth * usagePercentage,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
