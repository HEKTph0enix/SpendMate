import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../providers/statistics_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../../constants/categories.dart';
import '../../widgets/neumorphic/neumorphic_stat_card.dart';
import '../../widgets/neumorphic/neumorphic_card.dart';
import '../../widgets/neumorphic/neumorphic_icon_button.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, stats, child) {
          if (stats.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Month Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeumorphicIconButton(
                    icon: Icons.chevron_left,
                    onPressed: () {
                      final prev = DateTime(stats.selectedMonth.year, stats.selectedMonth.month - 1);
                      stats.setMonth(prev);
                    },
                  ),
                  Text(
                    DateFormatter.formatMonthYear(stats.selectedMonth),
                    style: theme.textTheme.titleLarge,
                  ),
                  NeumorphicIconButton(
                    icon: Icons.chevron_right,
                    onPressed: () {
                      final next = DateTime(stats.selectedMonth.year, stats.selectedMonth.month + 1);
                      // Don't allow going to future months
                      if (next.isBefore(DateTime.now()) || 
                          (next.year == DateTime.now().year && next.month == DateTime.now().month)) {
                        stats.setMonth(next);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (stats.transactionCount == 0)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No expenses found for this month.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else ...[
                // Overview Cards
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicStatCard(
                        title: 'Total Spending',
                        amount: CurrencyFormatter.format(stats.totalSpending),
                        icon: Icons.account_balance_wallet,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeumorphicStatCard(
                        title: 'Daily Average',
                        amount: CurrencyFormatter.format(stats.averageDaily),
                        icon: Icons.calendar_today,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicStatCard(
                        title: 'Transactions',
                        amount: stats.transactionCount.toString(),
                        icon: Icons.receipt_long,
                        color: theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeumorphicStatCard(
                        title: 'Highest',
                        amount: CurrencyFormatter.formatCompact(stats.highestExpense),
                        icon: Icons.trending_up,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Category Chart
                Text(
                  'Spending by Category',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                NeumorphicCard(
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: stats.categoryTotals.entries.map((entry) {
                          final color = CategoryHelper.getColor(entry.key);
                          final percentage = (entry.value / stats.totalSpending) * 100;
                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 50,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Top Categories
                Text(
                  'Top Categories',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...stats.topCategories.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            CategoryHelper.getIcon(entry.key),
                            color: CategoryHelper.getColor(entry.key),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.key)),
                          Text(
                            CurrencyFormatter.format(entry.value),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
                    
                const SizedBox(height: 32),
                
                // Payment Methods
                Text(
                  'Payment Methods',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...stats.paymentMethodTotals.entries.map((entry) {
                  final percentage = (entry.value / stats.totalSpending);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key),
                            Text(CurrencyFormatter.format(entry.value)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        NeumorphicContainer(
                          isInset: true,
                          height: 8,
                          borderRadius: 4,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  width: constraints.maxWidth * percentage,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 40),
              ],
            ],
          );
        },
      ),
    );
  }

}
