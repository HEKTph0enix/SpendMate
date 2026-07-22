import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/settings_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/neobrutal/neobrutal_card.dart';
import '../../widgets/neobrutal/neobrutal_button.dart';
import '../../widgets/budget_progress_card.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/category_icon.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_detail_screen.dart';
import '../budget/budget_screen.dart';
import '../../constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return Text('Hello, ${settings.userName}');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<ExpenseProvider, BudgetProvider>(
        builder: (context, expenseProvider, budgetProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeoBrutalCard(
                          backgroundColor: AppColors.getCardAccentColors(isDark)[0],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppColors.getBorder(isDark),
                                          width: 1.5),
                                    ),
                                    child: const Icon(Icons.today,
                                        size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('Today',
                                      style: AppTextStyles.cardTitle(isDark)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                CurrencyFormatter.format(
                                    expenseProvider.totalToday),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeoBrutalCard(
                          backgroundColor: AppColors.getCardAccentColors(isDark)[1],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentTeal,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: AppColors.getBorder(isDark),
                                          width: 1.5),
                                    ),
                                    child: const Icon(Icons.calendar_view_week,
                                        size: 16, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('This Week',
                                      style: AppTextStyles.cardTitle(isDark)),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                CurrencyFormatter.format(
                                    expenseProvider.totalThisWeek),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accentTeal,
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
                ),
              ),

              if (budgetProvider.hasBudget)
                SliverToBoxAdapter(
                  child: BudgetProgressCard(
                    limitAmount: budgetProvider.limitAmount,
                    usedAmount: budgetProvider.currentUsage,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BudgetScreen()),
                      );
                    },
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: NeoBrutalButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const BudgetScreen()),
                        );
                      },
                      backgroundColor: AppColors.accentYellow,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined,
                              color: AppColors.lightTextPrimary),
                          const SizedBox(width: 8),
                          Text('Set Monthly Budget',
                              style: AppTextStyles.buttonText(
                                  color: AppColors.lightTextPrimary)),
                        ],
                      ),
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Text('Recent Expenses',
                      style: AppTextStyles.sectionHeading(isDark)),
                ),
              ),

              SliverToBoxAdapter(
                child: FilterBar(
                  filters: const [
                    AppConstants.filterToday,
                    AppConstants.filterWeek,
                    AppConstants.filterMonth
                  ],
                  activeFilter: expenseProvider.activeFilter,
                  onFilterChanged: (filter) {
                    expenseProvider.setActiveFilter(filter);
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              if (expenseProvider.expenses.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'No expenses found',
                    message: 'You have no expenses for this period.',
                    buttonText: 'Add Expense',
                    onButtonPressed: () => _navigateToAddExpense(context),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = expenseProvider.expenses[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: NeoBrutalCard(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ExpenseDetailScreen(expenseId: expense.id),
                              ),
                            );
                          },
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CategoryIcon(
                                  category: expense.category,
                                  size: 20,
                                  padding: 8),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.note?.isNotEmpty == true
                                          ? expense.note!
                                          : expense.category,
                                      style: AppTextStyles.cardTitle(isDark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${DateFormatter.formatExpenseDate(expense.dateTime)} • ${expense.paymentMethod}',
                                      style: AppTextStyles.bodySmall(isDark),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                CurrencyFormatter.format(expense.amount),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.getTextPrimary(isDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: expenseProvider.expenses.length,
                  ),
                ),

              const SliverToBoxAdapter(
                  child: SizedBox(height: 80)), // Space for FAB
            ],
          );
        },
      ),
    );
  }

  void _navigateToAddExpense(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
  }
}
