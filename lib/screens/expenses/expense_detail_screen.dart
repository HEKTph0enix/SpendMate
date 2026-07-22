import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/expense_provider.dart';
import '../../models/expense.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/confirm_dialog.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/date_formatter.dart';
import 'add_expense_screen.dart';
import '../../widgets/neobrutal/neobrutal_card.dart';
import '../../widgets/neobrutal/neobrutal_icon_button.dart';

class ExpenseDetailScreen extends StatefulWidget {
  final String expenseId;

  const ExpenseDetailScreen({super.key, required this.expenseId});

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  Expense? _expense;

  @override
  void initState() {
    super.initState();
    _loadExpense();
  }

  void _loadExpense() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final expense = provider.allExpenses.cast<Expense?>().firstWhere(
          (e) => e?.id == widget.expenseId,
          orElse: () => null,
        );
    setState(() {
      _expense = expense;
    });
  }

  Future<void> _deleteExpense() async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Expense',
      content:
          'Are you sure you want to delete this expense? This action cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );

    if (confirmed == true && mounted) {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      await provider.deleteExpense(widget.expenseId);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _editExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expenseToEdit: _expense),
      ),
    ).then((_) {
      // Reload expense after editing
      if (mounted) {
        _loadExpense();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_expense == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Expense not found')),
      );
    }

    final theme = Theme.of(context);
    final expense = _expense!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        actions: [
          if (!expense.isGroupExpense) ...[
            NeoBrutalIconButton(
              icon: Icons.edit,
              onPressed: _editExpense,
            ),
            const SizedBox(width: 8),
            NeoBrutalIconButton(
              icon: Icons.delete,
              onPressed: _deleteExpense,
            ),
            const SizedBox(width: 8),
          ] else
            // For group expenses, we typically navigate to the group or show a message
            NeoBrutalIconButton(
              icon: Icons.info_outline,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Edit group expenses from the Groups tab.')),
                );
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                CategoryIcon(category: expense.category, size: 48, padding: 24),
                const SizedBox(height: 16),
                Text(
                  expense.category,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.format(expense.amount),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                if (expense.isGroupExpense) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Group Expense',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
          const SizedBox(height: 32),
          NeoBrutalCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow(
                      context,
                      'Date & Time',
                      DateFormatter.formatFull(expense.dateTime),
                      Icons.calendar_today),
                  const Divider(height: 24),
                  _buildDetailRow(context, 'Payment Method',
                      expense.paymentMethod, Icons.account_balance_wallet),
                  if (expense.payeeName != null &&
                      expense.payeeName!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildDetailRow(context, 'Payee Name', expense.payeeName!,
                        Icons.person_outline),
                  ],
                  if (expense.upiId != null && expense.upiId!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildDetailRow(context, 'UPI ID', expense.upiId!,
                        Icons.alternate_email),
                  ],
                  if (expense.source != 'manual') ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                        context,
                        'Source',
                        expense.source == 'upi_intent'
                            ? 'UPI Payment'
                            : expense.source,
                        Icons.source),
                  ],
                  if (expense.note != null && expense.note!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _buildDetailRow(
                        context, 'Note', expense.note!, Icons.notes),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
