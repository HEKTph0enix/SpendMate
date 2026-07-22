import 'package:flutter/material.dart';
import '../models/transaction.dart' as app;
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import 'neobrutal/neobrutal_card.dart';

class TransactionTile extends StatelessWidget {
  final app.Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIncome = transaction.type == app.TransactionType.income;
    final amountColor = isIncome ? AppColors.accentGreen : AppColors.error;
    final sign = isIncome ? '+' : '-';

    return NeoBrutalCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isIncome
                  ? AppColors.accentGreen.withOpacity(0.15)
                  : AppColors.error.withOpacity(0.15),
              shape: BoxShape.circle,
              border:
                  Border.all(color: AppColors.getBorder(isDark), width: 1.5),
            ),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: amountColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note ?? transaction.category,
                  style: AppTextStyles.cardTitle(isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction.paymentMethod,
                      style: AppTextStyles.bodySmall(isDark),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.getBorder(isDark), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        transaction.source.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.getTextSecondary(isDark),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign ₹${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${transaction.date.day}/${transaction.date.month}/${transaction.date.year}',
                style: AppTextStyles.bodySmall(isDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
