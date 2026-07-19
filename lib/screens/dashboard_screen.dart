import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_dashboard_provider.dart';
import '../providers/cash_wallet_provider.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_tile.dart';
import 'bank_accounts_screen.dart';
import 'cash_wallet_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
                      child: BalanceCard(
                        title: 'Bank Accounts',
                        amount: dashboard.totalBankBalance,
                        icon: Icons.account_balance,
                        gradientColors: const [Colors.indigo, Colors.blueAccent],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const BankAccountsScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BalanceCard(
                        title: 'Cash Wallet',
                        amount: wallet.balance,
                        icon: Icons.account_balance_wallet,
                        gradientColors: const [Colors.teal, Colors.green],
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

                // Recent Transactions
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
                  ...dashboard.recentTransactions.map((tx) => TransactionTile(transaction: tx)),
              ],
            ),
          );
        },
      ),
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
