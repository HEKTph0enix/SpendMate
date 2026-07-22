import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_dashboard_provider.dart';
import '../providers/cash_wallet_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/income_detection_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/neobrutal/neobrutal_card.dart';
import '../widgets/neobrutal/neobrutal_icon_button.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/category_icon.dart';
import '../models/expense.dart';
import '../models/transaction.dart' as app_tx;
import 'bank_accounts_screen.dart';
import 'cash_wallet_screen.dart';
import 'expenses/add_expense_screen.dart';
import 'expenses/upi_payment_screen.dart';
import 'expenses/expense_detail_screen.dart';
import 'detected_transactions_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Consumer2<FinancialDashboardProvider, CashWalletProvider>(
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // ─── Header ──────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dashboard', style: AppTextStyles.pageHeading(isDark)),
                    NeoBrutalIconButton(
                      icon: Icons.notifications_outlined,
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ─── Pending Income Detection Indicator ──
                Consumer<IncomeDetectionProvider>(
                  builder: (context, incomeProvider, _) {
                    final pendingCount = incomeProvider.pendingTransactions.length;
                    if (pendingCount == 0) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DetectedTransactionsScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentTeal.withOpacity(0.15),
                            border: Border.all(color: AppColors.accentTeal, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notifications_active, color: AppColors.accentTeal),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '$pendingCount possible income detection${pendingCount > 1 ? 's' : ''} pending review!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.tealAccent : AppColors.accentTeal,
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.accentTeal),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // ─── Total Balance Card ──────────────────
                NeoBrutalCard(
                  backgroundColor: AppColors.accentPurple,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Total Available Balance',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${totalAvailable.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Bank Accounts & Cash Wallet ─────────
                Row(
                  children: [
                    Expanded(
                      child: NeoBrutalCard(
                        backgroundColor:
                            AppColors.getCardAccentColors(isDark)[3], // light blue
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BankAccountsScreen()),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentBlue,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: AppColors.getBorder(isDark),
                                        width: 1.5),
                                  ),
                                  child: const Icon(Icons.account_balance,
                                      size: 18, color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Bank Accounts',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              CurrencyFormatter.format(
                                  dashboard.totalBankBalance),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.accentBlue,
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
                            AppColors.getCardAccentColors(isDark)[1], // light teal
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CashWalletScreen()),
                          );
                        },
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
                                  child: const Icon(
                                      Icons.account_balance_wallet,
                                      size: 18,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Cash Wallet',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              CurrencyFormatter.format(wallet.balance),
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
                const SizedBox(height: 28),

                // ─── Recent Expenses ─────────────────────
                _buildRecentExpenses(isDark),
                const SizedBox(height: 24),

                // ─── Recent Transactions ─────────────────
                _buildRecentTransactions(isDark, dashboard),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentExpenses(bool isDark) {
    return Consumer<ExpenseProvider>(
      builder: (context, expenseProvider, child) {
        final recent = expenseProvider.recentExpenses;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent Expenses',
                    style: AppTextStyles.sectionHeading(isDark)),
                if (recent.isNotEmpty)
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See All',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              NeoBrutalCard(
                backgroundColor: AppColors.getCardAccentColors(isDark)[2], // light yellow
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 40, color: AppColors.getTextSecondary(isDark)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'No expenses yet. Tap + to add one!',
                        style: AppTextStyles.body(isDark),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...recent.take(5).map((expense) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildExpenseTile(expense, isDark),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildExpenseTile(Expense expense, bool isDark) {
    return NeoBrutalCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExpenseDetailScreen(expenseId: expense.id),
          ),
        );
      },
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CategoryIcon(category: expense.category, size: 20, padding: 8),
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
    );
  }

  Widget _buildRecentTransactions(
      bool isDark, FinancialDashboardProvider dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Transactions',
                style: AppTextStyles.sectionHeading(isDark)),
            TextButton(
              onPressed: () {},
              child: Text(
                'See All',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (dashboard.recentTransactions.isEmpty)
          NeoBrutalCard(
            backgroundColor: AppColors.getCardAccentColors(isDark)[5], // light coral
            child: Row(
              children: [
                Icon(Icons.swap_horiz,
                    size: 40, color: AppColors.getTextSecondary(isDark)),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'No recent transactions',
                    style: AppTextStyles.body(isDark),
                  ),
                ),
              ],
            ),
          )
        else
          ...dashboard.recentTransactions.map((tx) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTransactionTile(tx, isDark),
              )),
      ],
    );
  }

  Widget _buildTransactionTile(app_tx.Transaction tx, bool isDark) {
    final isIncome = tx.type == app_tx.TransactionType.income;
    final amountColor = isIncome ? AppColors.accentGreen : AppColors.error;
    final sign = isIncome ? '+' : '-';

    return NeoBrutalCard(
      padding: const EdgeInsets.all(12),
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
                  tx.note ?? tx.category,
                  style: AppTextStyles.cardTitle(isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${tx.paymentMethod} • ${tx.source.name.toUpperCase()}',
                  style: AppTextStyles.bodySmall(isDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$sign ₹${tx.amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
