import 'package:flutter/material.dart';
import '../models/expense_group.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/app_spacing.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'neobrutal/neobrutal_card.dart';

class GroupCard extends StatelessWidget {
  final ExpenseGroup group;
  final int memberCount;
  final double userBalance;
  final VoidCallback onTap;
  final Color? cardColor;

  const GroupCard({
    super.key,
    required this.group,
    required this.memberCount,
    required this.userBalance,
    required this.onTap,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Balance logic
    final isSettled = userBalance.abs() < 0.01;
    final isOwed = userBalance > 0.01;
    final balanceAmount = userBalance.abs();

    Color balanceColor;
    String balanceText;

    if (isSettled) {
      balanceColor = AppColors.getTextSecondary(isDark);
      balanceText = 'Settled up';
    } else if (isOwed) {
      balanceColor = AppColors.accentGreen;
      balanceText = 'You are owed\n${CurrencyFormatter.format(balanceAmount)}';
    } else {
      balanceColor = AppColors.error;
      balanceText = 'You owe\n${CurrencyFormatter.format(balanceAmount)}';
    }

    return NeoBrutalCard(
      margin: const EdgeInsets.symmetric(vertical: 6),
      backgroundColor: cardColor,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: AppTextStyles.sectionHeading(isDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.group,
                            size: 14,
                            color: AppColors.getTextSecondary(isDark)),
                        const SizedBox(width: 4),
                        Text(
                          '$memberCount members',
                          style: AppTextStyles.bodySmall(isDark),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.getSurface(isDark),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: AppColors.getBorder(isDark),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  balanceText,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: balanceColor,
                  ),
                ),
              ),
            ],
          ),
          if (group.description != null && group.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              group.description!,
              style: AppTextStyles.body(isDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Container(height: 2, color: AppColors.getBorder(isDark)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Last updated: ${DateFormatter.formatDateOnly(group.updatedAt)}',
                style: AppTextStyles.bodySmall(isDark),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
