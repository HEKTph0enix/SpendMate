import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/neumorphic/neumorphic_stat_card.dart';
import '../../widgets/neumorphic/neumorphic_expense_tile.dart';
import '../../widgets/budget_progress_card.dart';
import '../../widgets/filter_bar.dart';
import '../../widgets/empty_state.dart';
import '../../utils/currency_formatter.dart';
import '../expenses/add_expense_screen.dart';
import '../expenses/expense_detail_screen.dart';
import '../budget/budget_screen.dart';
import '../../constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            onPressed: () {
              // Show search dialog/bar (Simplified for now)
            },
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: NeumorphicStatCard(
                          title: 'Today',
                          amount: CurrencyFormatter.format(expenseProvider.totalToday),
                          icon: Icons.today,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: NeumorphicStatCard(
                          title: 'This Week',
                          amount: CurrencyFormatter.format(expenseProvider.totalThisWeek),
                          icon: Icons.calendar_view_week,
                          color: theme.colorScheme.secondary,
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
                        MaterialPageRoute(builder: (context) => const BudgetScreen()),
                      );
                    },
                  ),
                )
              else
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BudgetScreen()),
                        );
                      },
                      icon: const Icon(Icons.account_balance_wallet_outlined),
                      label: const Text('Set Monthly Budget'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ),
                ),
                
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Expenses',
                        style: theme.textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: FilterBar(
                  filters: const [AppConstants.filterToday, AppConstants.filterWeek, AppConstants.filterMonth],
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
                      // If it's a group expense, show full amount but denote it's a group expense (logic handled in card)
                      return NeumorphicExpenseTile(
                        item: expense,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExpenseDetailScreen(expenseId: expense.id),
                            ),
                          );
                        },
                      );
                    },
                    childCount: expenseProvider.expenses.length,
                  ),
                ),
                
              const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for FAB
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
