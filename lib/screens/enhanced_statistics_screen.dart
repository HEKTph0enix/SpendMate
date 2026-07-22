import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/savings_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/neobrutal/neobrutal_card.dart';
import '../widgets/neobrutal/neobrutal_icon_button.dart';
import '../widgets/neobrutal/neobrutal_button.dart';
import '../widgets/insight_badge.dart';
import '../utils/date_formatter.dart';
import '../utils/currency_formatter.dart';
import '../models/savings_suggestion.dart';
import '../widgets/charts/category_pie_chart.dart';
import '../widgets/charts/income_expense_bar_chart.dart';
class EnhancedStatisticsScreen extends StatefulWidget {
  const EnhancedStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<EnhancedStatisticsScreen> createState() =>
      _EnhancedStatisticsScreenState();
}

class _EnhancedStatisticsScreenState extends State<EnhancedStatisticsScreen> {
  bool _showSavingsSuggestions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().loadAnalytics();
      context.read<SavingsProvider>().loadSuggestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading || provider.currentMonthStats == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.currentMonthStats!;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            children: [
              // ─── Header ──────────────────────────────
              Text('Insights', style: AppTextStyles.pageHeading(isDark)),
              const SizedBox(height: 20),

              // ─── Month Selector ──────────────────────
              NeoBrutalCard(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NeoBrutalIconButton(
                      icon: Icons.chevron_left,
                      size: 20,
                      onPressed: () {
                        final prev = DateTime(provider.selectedMonth.year,
                            provider.selectedMonth.month - 1);
                        provider.setMonth(prev);
                      },
                    ),
                    Text(
                      DateFormatter.formatMonthYear(provider.selectedMonth),
                      style: AppTextStyles.sectionHeading(isDark),
                    ),
                    NeoBrutalIconButton(
                      icon: Icons.chevron_right,
                      size: 20,
                      onPressed: () {
                        final next = DateTime(provider.selectedMonth.year,
                            provider.selectedMonth.month + 1);
                        provider.setMonth(next);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ─── Overview Cards ──────────────────────
              Row(
                children: [
                  Expanded(
                    child: NeoBrutalCard(
                      backgroundColor:
                          AppColors.getCardAccentColors(isDark)[5], // light coral
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.getBorder(isDark),
                                      width: 1.5),
                                ),
                                child: const Icon(Icons.arrow_upward,
                                    size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text('Expenses',
                                  style: AppTextStyles.cardTitle(isDark)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            CurrencyFormatter.format(stats.totalExpense),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.error,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: NeoBrutalCard(
                      backgroundColor:
                          AppColors.getCardAccentColors(isDark)[4], // light green
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.accentGreen,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: AppColors.getBorder(isDark),
                                      width: 1.5),
                                ),
                                child: const Icon(Icons.arrow_downward,
                                    size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Text('Income',
                                  style: AppTextStyles.cardTitle(isDark)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            CurrencyFormatter.format(stats.totalIncome),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accentGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ─── Income vs Expense Chart ─────────────
              Text('Income vs Expenses',
                  style: AppTextStyles.sectionHeading(isDark)),
              const SizedBox(height: 12),
              NeoBrutalCard(
                backgroundColor:
                    AppColors.getCardAccentColors(isDark)[3], // light blue
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: IncomeExpenseBarChart(
                    totalIncome: stats.totalIncome,
                    totalExpense: stats.totalExpense,
                    isDark: isDark,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Key Insights ────────────────────────
              if (provider.anomalies.isNotEmpty ||
                  provider.insights.isNotEmpty) ...[
                Text('Key Insights',
                    style: AppTextStyles.sectionHeading(isDark)),
                const SizedBox(height: 12),
                ...provider.anomalies.map((a) => InsightBadge(insight: a)),
                ...provider.insights.map((i) => InsightBadge(insight: i)),
                const SizedBox(height: 24),
              ],

              // ─── Recurring Expenses ──────────────────
              if (provider.recurringExpenses.isNotEmpty &&
                  provider.selectedMonth.month == DateTime.now().month) ...[
                Text('Detected Subscriptions',
                    style: AppTextStyles.sectionHeading(isDark)),
                const SizedBox(height: 12),
                ...provider.recurringExpenses.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: NeoBrutalCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.accentBlue.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.getBorder(isDark),
                                    width: 1.5),
                              ),
                              child: Icon(Icons.autorenew,
                                  color: AppColors.accentBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(r.description,
                                      style: AppTextStyles.cardTitle(isDark)),
                                  Text(r.category,
                                      style: AppTextStyles.bodySmall(isDark)),
                                ],
                              ),
                            ),
                            Text(
                              '₹${r.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color: AppColors.getTextPrimary(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
              ],

              // ─── Top Spending Categories ─────────────
              Text('Top Spending Categories',
                  style: AppTextStyles.sectionHeading(isDark)),
              const SizedBox(height: 12),
              NeoBrutalCard(
                  backgroundColor:
                      AppColors.getCardAccentColors(isDark)[2], // light yellow
                  child: Column(
                    children: [
                      CategoryPieChart(
                        categoryTotals: stats.categoryTotals,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      ...stats.categoryTotals.entries
                          .take(5)
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e.key,
                                        style: AppTextStyles.body(isDark),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '₹${e.value.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.getTextPrimary(isDark),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

              // ─── Savings Assistant ───────────────────
              _buildSavingsAssistant(isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSavingsAssistant(bool isDark) {
    return Consumer<SavingsProvider>(
      builder: (context, savingsProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Savings Assistant',
                style: AppTextStyles.sectionHeading(isDark)),
            const SizedBox(height: 12),
            if (savingsProvider.isLoading)
              const Center(
                  child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ))
            else if (savingsProvider.suggestions.isEmpty)
              NeoBrutalCard(
                backgroundColor: AppColors.getCardAccentColors(isDark)[4], // light green
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.getBorder(isDark), width: 1.5),
                      ),
                      child: const Icon(Icons.check_circle_outline,
                          color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your spending looks great!',
                              style: AppTextStyles.cardTitle(isDark)),
                          const SizedBox(height: 4),
                          Text(
                            'No new savings suggestions at the moment.',
                            style: AppTextStyles.bodySmall(isDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              // Savings summary card
              NeoBrutalCard(
                backgroundColor: AppColors.getCardAccentColors(isDark)[0], // light purple
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentPurple,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.getBorder(isDark), width: 1.5),
                          ),
                          child: const Icon(Icons.savings_outlined,
                              color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Potential Monthly Savings',
                                  style: AppTextStyles.cardTitle(isDark)),
                              const SizedBox(height: 4),
                              Text(
                                '₹${savingsProvider.totalPotentialSavings.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.accentPurple,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: NeoBrutalButton(
                        backgroundColor: AppColors.accentPurple,
                        onPressed: () {
                          setState(() {
                            _showSavingsSuggestions = !_showSavingsSuggestions;
                          });
                        },
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _showSavingsSuggestions
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(_showSavingsSuggestions
                                ? 'Hide Suggestions'
                                : 'View Suggestions'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Expandable suggestions
              if (_showSavingsSuggestions) ...[
                const SizedBox(height: 12),
                ...savingsProvider.suggestions.map((suggestion) {
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

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: NeoBrutalCard(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(priorityIcon,
                                  color: priorityColor, size: 20),
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
                                onTap: () => savingsProvider
                                    .markAsRevisited(suggestion.id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.getBorder(isDark),
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.close, size: 16),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            suggestion.reason,
                            style: AppTextStyles.body(isDark),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.accentBlue.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                              border: Border.all(
                                  color: AppColors.getBorder(isDark),
                                  width: 1.5),
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
                    ),
                  );
                }),
              ],
            ],
          ],
        );
      },
    );
  }
}
