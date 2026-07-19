import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_wallet_provider.dart';
import '../widgets/transaction_tile.dart';

class CashWalletScreen extends StatelessWidget {
  const CashWalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Wallet'),
      ),
      body: Consumer<CashWalletProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                color: Colors.teal.withOpacity(0.1),
                child: Column(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 48, color: Colors.teal),
                    const SizedBox(height: 16),
                    const Text('Available Cash', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${provider.balance.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Cash'),
                        onPressed: () => _showAddCashDialog(context, provider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit),
                        label: const Text('Correct'),
                        onPressed: () => _showCorrectBalanceDialog(context, provider),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Expanded(
                child: provider.cashTransactions.isEmpty
                    ? const Center(child: Text('No cash transactions yet'))
                    : ListView.builder(
                        itemCount: provider.cashTransactions.length,
                        itemBuilder: (context, index) {
                          return TransactionTile(
                            transaction: provider.cashTransactions[index],
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddCashDialog(BuildContext context, CashWalletProvider provider) {
    final amountController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Cash Received'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹'),
            ),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: 'Note (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                provider.addCashReceived(amount, note: noteController.text.isNotEmpty ? noteController.text : null);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCorrectBalanceDialog(BuildContext context, CashWalletProvider provider) {
    final amountController = TextEditingController(text: provider.balance.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Correct Cash Balance'),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Actual Cash in Hand',
            prefixText: '₹',
            helperText: 'This will adjust your balance and log the correction.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null) {
                provider.correctBalance(amount);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
