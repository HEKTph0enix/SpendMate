import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/financial_dashboard_provider.dart';
import 'statement_import_screen.dart';
import '../widgets/neumorphic/neumorphic_card.dart';
import '../widgets/neumorphic/neumorphic_button.dart';

class BankAccountsScreen extends StatelessWidget {
  const BankAccountsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                MaterialPageRoute(builder: (_) => const StatementImportScreen()),
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
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.accounts.length,
            itemBuilder: (context, index) {
              final account = provider.accounts[index];
              return NeumorphicCard(
                margin: const EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.account_balance, color: Colors.white),
                  ),
                  title: Text(account.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(account.maskedAccountNumber ?? account.type.name.toUpperCase()),
                  trailing: Text(
                    '₹${account.balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onTap: () {
                    // TODO: Show account details/transactions
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: NeumorphicButton(
          onPressed: () => _showAddAccountDialog(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('Add Account', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No bank accounts added yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
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
                  decoration: const InputDecoration(labelText: 'Account Name (e.g. Personal)'),
                ),
                TextField(
                  controller: bankNameController,
                  decoration: const InputDecoration(labelText: 'Bank Name (Optional)'),
                ),
                TextField(
                  controller: accountNumController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Last 4 Digits of A/C (Optional)'),
                  maxLength: 4,
                ),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Account Type'),
                  items: ['Savings', 'Current', 'Credit Card', 'Wallet'].map((t) {
                    return DropdownMenuItem(value: t, child: Text(t));
                  }).toList(),
                  onChanged: (v) => setState(() => selectedType = v!),
                ),
                TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Current Balance', prefixText: '₹'),
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
                    bankNameController.text.isEmpty ? null : bankNameController.text,
                    accountNumController.text.isEmpty ? null : 'XXXX-XXXX-${accountNumController.text}',
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
