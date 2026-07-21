import 'package:flutter/material.dart';
import 'neumorphic_container.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/expense.dart';
import '../../models/transaction.dart' as app_tx;
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../category_icon.dart';

class NeumorphicExpenseTile extends StatelessWidget {
  final dynamic item; // Can be Expense or Transaction
  final VoidCallback? onTap;

  const NeumorphicExpenseTile({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    String title = '';
    String subtitle = '';
    String amountStr = '';
    Color amountColor = theme.colorScheme.onSurface;
    Widget leading;
    
    if (item is Expense) {
      final expense = item as Expense;
      title = expense.note?.isNotEmpty == true ? expense.note! : expense.category;
      subtitle = '${DateFormatter.formatExpenseDate(expense.dateTime)} • ${expense.paymentMethod}';
      amountStr = CurrencyFormatter.format(expense.amount);
      amountColor = theme.colorScheme.onSurface;
      leading = CategoryIcon(category: expense.category, size: 20, padding: 8);
    } else if (item is app_tx.Transaction) {
      final tx = item as app_tx.Transaction;
      final isIncome = tx.type == app_tx.TransactionType.income;
      title = tx.note ?? tx.category;
      subtitle = '${tx.paymentMethod} • ${tx.source.name.toUpperCase()}';
      amountStr = '${isIncome ? '+' : '-'} ₹${tx.amount.toStringAsFixed(0)}';
      amountColor = isIncome ? Colors.green : Colors.red;
      leading = NeumorphicContainer(
        isInset: true,
        padding: const EdgeInsets.all(8),
        shape: BoxShape.circle,
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: amountColor,
          size: 20,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: NeumorphicContainer(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: AppSpacing.radiusMd,
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                amountStr,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
