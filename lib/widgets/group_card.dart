import 'package:flutter/material.dart';
import '../models/expense_group.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import 'neumorphic/neumorphic_card.dart';
import 'neumorphic/neumorphic_container.dart';

class GroupCard extends StatelessWidget {
  final ExpenseGroup group;
  final int memberCount;
  final double userBalance;
  final VoidCallback onTap;

  const GroupCard({
    super.key,
    required this.group,
    required this.memberCount,
    required this.userBalance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Balance logic
    // Positive balance = owed money (creditor)
    // Negative balance = owes money (debtor)
    // Zero balance = settled up
    
    final isSettled = userBalance.abs() < 0.01;
    final isOwed = userBalance > 0.01;
    final balanceAmount = userBalance.abs();

    Color balanceColor;
    String balanceText;

    if (isSettled) {
      balanceColor = theme.colorScheme.onSurfaceVariant;
      balanceText = 'Settled up';
    } else if (isOwed) {
      balanceColor = Colors.green.shade600;
      balanceText = 'You are owed\n${CurrencyFormatter.format(balanceAmount)}';
    } else {
      balanceColor = Colors.red.shade600;
      balanceText = 'You owe\n${CurrencyFormatter.format(balanceAmount)}';
    }

    return NeumorphicCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                          style: theme.textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$memberCount members',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  NeumorphicContainer(
                    isInset: true,
                    borderRadius: 8,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text(
                      balanceText,
                      textAlign: TextAlign.right,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: balanceColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (group.description != null && group.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  group.description!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last updated: ${DateFormatter.formatDateOnly(group.updatedAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}
