import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/detected_transaction.dart';
import '../models/expense.dart';
import '../providers/income_detection_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/financial_dashboard_provider.dart';
import '../providers/analytics_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/neobrutal/neobrutal_card.dart';
import '../widgets/neobrutal/neobrutal_button.dart';
import 'confirm_income_screen.dart';

class DetectedTransactionsScreen extends StatelessWidget {
  const DetectedTransactionsScreen({super.key});

  Future<void> _addAsIncome(BuildContext context, DetectedTransaction tx) async {
    final expenseProvider = context.read<ExpenseProvider>();
    final detectionProvider = context.read<IncomeDetectionProvider>();

    final expense = Expense(
      id: tx.id,
      amount: tx.amount,
      dateTime: tx.timestamp,
      category: 'Other Income', // Default, user can edit later in transaction list
      paymentMethod: 'Online Transaction',
      note: 'Auto-detected from ${tx.packageName}${tx.senderName != null ? ' (From ${tx.senderName})' : ''}',
      source: 'bankSync', 
      paymentStatus: 'completed',
    );

    // Save it as a regular income via ExpenseProvider (which we modified to handle balance changes for online transactions)
    // Wait, ExpenseProvider currently hardcodes TransactionType.expense.
    // Ah, wait! ExpenseProvider `addExpense` creates a TransactionType.expense always!
    // But income needs TransactionType.income!
    // I'll need to modify ExpenseProvider to check if amount is negative? No, amount is always positive. 
    // Is there a way to specify type in ExpenseProvider? No, Expense model doesn't have "type".
    // Wait, the Prompt said: Save confirmed income in SQLite as a normal transaction with type: income.
    // Let me update the provider logic directly here for the specific V2 transaction.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detected Income'),
      ),
      body: Consumer<IncomeDetectionProvider>(
        builder: (context, provider, _) {
          final pending = provider.pendingTransactions;

          if (pending.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: AppColors.getTextSecondary(isDark)),
                  const SizedBox(height: 16),
                  Text('No pending detections', style: AppTextStyles.body(isDark)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pending.length,
            itemBuilder: (context, index) {
              final tx = pending[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: NeoBrutalCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Possible income detected',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accentTeal,
                              ),
                            ),
                            Text(
                              DateFormatter.formatDateOnly(tx.timestamp),
                              style: AppTextStyles.bodySmall(isDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${CurrencyFormatter.format(tx.amount)} received',
                          style: AppTextStyles.sectionHeading(isDark),
                        ),
                        const SizedBox(height: 8),
                        Text('Source app: ${tx.packageName}'),
                        if (tx.senderName != null) Text('From: ${tx.senderName}'),
                        const SizedBox(height: 16),
                        Text(
                          'Original text: "${tx.notificationText}"',
                          style: AppTextStyles.bodySmall(isDark).copyWith(fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  provider.markAsIgnored(tx.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  side: BorderSide(color: AppColors.getBorder(isDark), width: 2),
                                ),
                                child: Text('Ignore', style: TextStyle(color: AppColors.getTextPrimary(isDark), fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: NeoBrutalButton(
                                onPressed: () {
                                  // Open dialog or bottom sheet to confirm details, but for now we'll just show edit screen or add it directly.
                                  _showConfirmDialog(context, tx);
                                },
                                backgroundColor: AppColors.accentTeal,
                                child: const Text('Add Income'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, DetectedTransaction tx) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ConfirmIncomeScreen(transaction: tx)),
    );
  }
}
