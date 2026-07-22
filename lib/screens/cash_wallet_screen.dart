import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cash_wallet_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../widgets/neobrutal/neobrutal_card.dart';
import '../widgets/neobrutal/neobrutal_button.dart';
import '../widgets/transaction_tile.dart';

class CashWalletScreen extends StatelessWidget {
  const CashWalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              // Balance header
              Padding(
                padding: const EdgeInsets.all(16),
                child: NeoBrutalCard(
                  backgroundColor: AppColors.getCardAccentColors(isDark)[1], // light teal
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accentTeal,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.getBorder(isDark), width: 2),
                        ),
                        child: const Icon(Icons.account_balance_wallet,
                            size: 32, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text('Available Cash',
                          style: AppTextStyles.cardSubtitle(isDark)),
                      const SizedBox(height: 8),
                      Text(
                        '₹${provider.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accentTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: NeoBrutalButton(
                        onPressed: () => _showAddCashDialog(context, provider),
                        backgroundColor: AppColors.accentTeal,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 18),
                            SizedBox(width: 6),
                            Text('Add Cash'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: NeoBrutalButton(
                        onPressed: () =>
                            _showCorrectBalanceDialog(context, provider),
                        backgroundColor: AppColors.getSurface(isDark),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit,
                                size: 18,
                                color: AppColors.getTextPrimary(isDark)),
                            const SizedBox(width: 6),
                            Text('Correct',
                                style: AppTextStyles.buttonText(
                                    color: AppColors.getTextPrimary(isDark))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(height: 2, color: AppColors.getBorder(isDark)),
              Expanded(
                child: provider.cashTransactions.isEmpty
                    ? Center(
                        child: Text(
                          'No cash transactions yet',
                          style: AppTextStyles.body(isDark).copyWith(
                            color: AppColors.getTextSecondary(isDark),
                          ),
                        ),
                      )
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  const InputDecoration(labelText: 'Amount', prefixText: '₹'),
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
                provider.addCashReceived(amount,
                    note: noteController.text.isNotEmpty
                        ? noteController.text
                        : null);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showCorrectBalanceDialog(
      BuildContext context, CashWalletProvider provider) {
    final amountController =
        TextEditingController(text: provider.balance.toStringAsFixed(2));

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
