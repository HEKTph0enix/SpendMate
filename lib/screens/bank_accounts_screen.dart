import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_dashboard_provider.dart';
import 'statement_import_screen.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/neobrutal/neobrutal_card.dart';
import '../widgets/neobrutal/neobrutal_button.dart';

class BankAccountsScreen extends StatelessWidget {
  const BankAccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bank Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import Statement',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const StatementImportScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<FinancialDashboardProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.accounts.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.accounts.length,
            itemBuilder: (context, index) {
              final account = provider.accounts[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeoBrutalCard(
                  backgroundColor: AppColors.getCardAccentColors(isDark)[
                      index % AppColors.getCardAccentColors(isDark).length],
                  onTap: () {
                    // TODO: Show account details/transactions
                  },
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentBlue,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.getBorder(isDark), width: 1.5),
                        ),
                        child: const Icon(Icons.account_balance,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(account.name,
                                style: AppTextStyles.cardTitle(isDark)),
                            const SizedBox(height: 2),
                            Text(
                              account.maskedAccountNumber ??
                                  account.type.name.toUpperCase(),
                              style: AppTextStyles.bodySmall(isDark),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '₹${account.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.getTextPrimary(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: NeoBrutalButton(
          onPressed: () => _showAddAccountDialog(context),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('Add Account'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.getCardAccentColors(isDark)[3],
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.getBorder(isDark), width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.getBorder(isDark),
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(Icons.account_balance,
                size: 48, color: AppColors.accentBlue),
          ),
          const SizedBox(height: 20),
          Text('No bank accounts added yet',
              style: AppTextStyles.sectionHeading(isDark)),
          const SizedBox(height: 24),
          NeoBrutalButton(
            onPressed: () => _showAddAccountDialog(context),
            child: const Text('Add Manual Account'),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    final bankNameController = TextEditingController();
    final accountNumController = TextEditingController();
    String selectedType = 'Savings';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Bank Account'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText: 'Account Name (e.g. Personal)'),
                ),
                TextField(
                  controller: bankNameController,
                  decoration:
                      const InputDecoration(labelText: 'Bank Name (Optional)'),
                ),
                TextField(
                  controller: accountNumController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Last 4 Digits of A/C (Optional)'),
                  maxLength: 4,
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Account Type'),
                  items:
                      ['Savings', 'Current', 'Credit Card', 'Wallet'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                TextField(
                  controller: balanceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Current Balance', prefixText: '₹'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final balance = double.tryParse(balanceController.text) ?? 0;
                if (nameController.text.isNotEmpty) {
                  context.read<FinancialDashboardProvider>().addManualAccount(
                        nameController.text,
                        balance,
                        selectedType,
                        bankNameController.text.isEmpty
                            ? null
                            : bankNameController.text,
                        accountNumController.text.isEmpty
                            ? null
                            : 'XXXX-XXXX-${accountNumController.text}',
                      );
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
