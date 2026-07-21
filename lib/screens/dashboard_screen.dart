import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_dashboard_provider.dart';
import '../providers/cash_wallet_provider.dart';
import '../providers/expense_provider.dart';
import '../widgets/neumorphic/neumorphic_stat_card.dart';
import '../widgets/neumorphic/neumorphic_expense_tile.dart';
import '../utils/currency_formatter.dart';
import 'bank_accounts_screen.dart';
import 'cash_wallet_screen.dart';
import 'expenses/add_expense_screen.dart';
import 'expenses/upi_payment_screen.dart';
import 'expenses/expense_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinancialDashboardProvider>().refreshDashboard();
      context.read<CashWalletProvider>().refreshWallet();
    });
  }

  void _showAddExpenseOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Expense',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(Icons.edit, color: theme.colorScheme.primary),
                  ),
                  title: const Text('Manual Entry'),
                  subtitle: const Text('Enter expense details manually'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Icon(Icons.account_balance, color: theme.colorScheme.secondary),
                  ),
                  title: const Text('Pay Using UPI'),
                  subtitle: const Text('Pay via UPI and record the expense'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UpiPaymentScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notifications/alerts
            },
          ),
        ],
      ),
      body: Consumer2<FinancialDashboardProvider, CashWalletProvider>(
        builder: (context, dashboard, wallet, child) {
          if (dashboard.isLoading || wallet.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalAvailable = dashboard.totalBankBalance + wallet.balance;

          return RefreshIndicator(
            onRefresh: () async {
              await dashboard.refreshDashboard();
              await wallet.refreshWallet();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total Balance Summary
                _buildTotalBalanceSection(totalAvailable),
                const SizedBox(height: 24),
                
                // Account Cards (Bank vs Cash)
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicStatCard(
                        title: 'Bank Accounts',
                        amount: CurrencyFormatter.format(dashboard.totalBankBalance),
                        icon: Icons.account_balance,
                        color: Colors.indigo,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BankAccountsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeumorphicStatCard(
                        title: 'Cash Wallet',
                        amount: CurrencyFormatter.format(wallet.balance),
                        icon: Icons.account_balance_wallet,
                        color: Colors.teal,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CashWalletScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Recent Expenses from expenses table
                _buildRecentExpensesSection(),
                const SizedBox(height: 24),

                // Recent Transactions from transactions table
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to all transactions
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                if (dashboard.recentTransactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'No recent transactions',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...dashboard.recentTransactions.map((tx) => NeumorphicExpenseTile(item: tx)),

                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentExpensesSection() {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final recent = expenseProvider.recentExpenses;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (recent.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all expenses
                    },
                    child: const Text('See All'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No expenses yet. Tap + to add one!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recent.take(5).map((expense) => NeumorphicExpenseTile(
                item: expense,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExpenseDetailScreen(expenseId: expense.id),
                    ),
                  );
                },
              )),
          ],
        );
      },
    );
  }

  Widget _buildTotalBalanceSection(double totalAvailable) {
    return Column(
      children: [
        const Text(
          'Total Available Balance',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '₹${totalAvailable.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
