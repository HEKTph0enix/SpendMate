import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/insight_badge.dart';
import '../utils/date_formatter.dart';
import '../utils/currency_formatter.dart';
import '../widgets/neumorphic/neumorphic_stat_card.dart';
import '../widgets/neumorphic/neumorphic_icon_button.dart';
import '../widgets/neumorphic/neumorphic_container.dart';

class EnhancedStatisticsScreen extends StatefulWidget {
  const EnhancedStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedStatisticsScreen> createState() => _EnhancedStatisticsScreenState();
}

class _EnhancedStatisticsScreenState extends State<EnhancedStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics & Insights'),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.currentMonthStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.currentMonthStats!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Month Selector
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeumorphicIconButton(
                    icon: Icons.chevron_left,
                    onPressed: () {
                      final prev = DateTime(provider.selectedMonth.year, provider.selectedMonth.month - 1);
                      provider.setMonth(prev);
                    },
                  ),
                  Text(
                    DateFormatter.formatMonthYear(provider.selectedMonth),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  NeumorphicIconButton(
                    icon: Icons.chevron_right,
                    onPressed: () {
                      final next = DateTime(provider.selectedMonth.year, provider.selectedMonth.month + 1);
                      provider.setMonth(next);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Overview Cards
              Row(
                children: [
                  Expanded(
                    child: NeumorphicStatCard(
                      title: 'Expenses',
                      amount: CurrencyFormatter.format(stats.totalExpense),
                      icon: Icons.arrow_upward,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: NeumorphicStatCard(
                      title: 'Income',
                      amount: CurrencyFormatter.format(stats.totalIncome),
                      icon: Icons.arrow_downward,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Anomalies & Insights Section
              if (provider.anomalies.isNotEmpty || provider.insights.isNotEmpty) ...[
                const Text('Key Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...provider.anomalies.map((a) => InsightBadge(insight: a)),
                ...provider.insights.map((i) => InsightBadge(insight: i)),
                const SizedBox(height: 24),
              ],

              // Recurring Expenses Section (Only current month)
              if (provider.recurringExpenses.isNotEmpty && 
                  provider.selectedMonth.month == DateTime.now().month) ...[
                const Text('Detected Subscriptions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...provider.recurringExpenses.map((r) => ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.autorenew)),
                  title: Text(r.description),
                  subtitle: Text(r.category),
                  trailing: Text('₹${r.amount.toStringAsFixed(0)}'),
                )),
                const SizedBox(height: 24),
              ],

              // Top Categories
              if (stats.categoryTotals.isNotEmpty) ...[
                const Text('Top Spending Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ...stats.categoryTotals.entries.take(5).map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key),
                      Text('₹${e.value.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )),
              ],
            ],
          );
        },
      ),
    );
  }
}

