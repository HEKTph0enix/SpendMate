import 'package:flutter/material.dart';
import '../utils/currency_formatter.dart';
import '../constants/app_constants.dart';
import 'neumorphic/neumorphic_card.dart';
import 'neumorphic/neumorphic_container.dart';

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
    final theme = Theme.of(context);
    final remainingAmount = limitAmount - usedAmount > 0 ? limitAmount - usedAmount : 0.0;
    
    double usagePercentage = limitAmount > 0 ? usedAmount / limitAmount : 0.0;
    
    // Status colors
    Color statusColor;
    String statusText;
    
    if (usagePercentage < AppConstants.budgetSafeThreshold) {
      statusColor = Colors.green;
      statusText = 'On Track';
    } else if (usagePercentage < AppConstants.budgetWarningThreshold) {
      statusColor = Colors.orange;
      statusText = 'Nearing Limit';
    } else {
      statusColor = Colors.red;
      statusText = 'Over Budget';
      if (usagePercentage > 1.0) usagePercentage = 1.0;
    }

    return NeumorphicCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monthly Budget',
                    style: theme.textTheme.titleMedium,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
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
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'of ${CurrencyFormatter.format(limitAmount)} used',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormatter.format(remainingAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'left',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              NeumorphicContainer(
                isInset: true,
                height: 10,
                borderRadius: 8,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: constraints.maxWidth * usagePercentage,
                        height: 10,
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(8),
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
