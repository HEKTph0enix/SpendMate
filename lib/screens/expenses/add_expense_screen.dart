import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../providers/expense_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../models/expense.dart';
import '../../constants/app_constants.dart';
import '../../constants/categories.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/neumorphic/neumorphic_text_field.dart';
import '../../widgets/neumorphic/neumorphic_dropdown.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import 'upi_payment_screen.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expenseToEdit;

  const AddExpenseScreen({super.key, this.expenseToEdit});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  String _selectedCategory = AppConstants.categories.first;
  String _selectedPaymentMethod = AppConstants.paymentMethods.first;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    if (widget.expenseToEdit != null) {
      final e = widget.expenseToEdit!;
      _amountController.text = e.amount.toString();
      _noteController.text = e.note ?? '';
      _selectedCategory = e.category;
      _selectedPaymentMethod = e.paymentMethod;
      _selectedDate = e.dateTime;
      _selectedTime = TimeOfDay.fromDateTime(e.dateTime);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    // Parse and validate amount using the recommended approach
    final amount = double.tryParse(_amountController.text.trim());

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than zero')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final expense = Expense(
        id: widget.expenseToEdit?.id ?? _uuid.v4(),
        amount: amount,
        dateTime: dateTime,
        category: _selectedCategory,
        paymentMethod: _selectedPaymentMethod,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        source: widget.expenseToEdit?.source ?? 'manual',
        createdAt: widget.expenseToEdit?.createdAt,
      );

      final provider = Provider.of<ExpenseProvider>(context, listen: false);

      if (widget.expenseToEdit != null) {
        await provider.updateExpense(expense);
      } else {
        await provider.addExpense(expense);
      }

      if (!mounted) return;

      // Refresh budget and statistics after saving
      context.read<BudgetProvider>().loadCurrentBudget();
      context.read<StatisticsProvider>().loadStatistics();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.expenseToEdit != null
              ? 'Expense updated successfully'
              : 'Expense added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form for new expenses, pop for edits
      if (widget.expenseToEdit != null) {
        Navigator.pop(context);
      } else {
        // Clear the form after successful save
        _amountController.clear();
        _noteController.clear();
        setState(() {
          _selectedCategory = AppConstants.categories.first;
          _selectedPaymentMethod = AppConstants.paymentMethods.first;
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
        });
        _formKey.currentState?.reset();
        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save expense: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToUpiPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UpiPaymentScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.expenseToEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _isLoading ? null : _saveExpense,
              child: const Text('SAVE'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Pay via UPI button (only for new expenses, not when editing)
            if (!isEditing) ...[
              NeumorphicButton(
                onPressed: _navigateToUpiPayment,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.account_balance),
                    SizedBox(width: 8),
                    Text('Pay Using UPI'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR ENTER MANUALLY',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Amount
            NeumorphicTextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              labelText: 'Amount',
              prefixText: '₹ ',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }
                final parsed = double.tryParse(value.trim());
                if (parsed == null) {
                  return 'Enter a valid amount';
                }
                if (parsed <= 0) {
                  return 'Amount must be greater than zero';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Note
            NeumorphicTextField(
              controller: _noteController,
              labelText: 'Note (Optional)',
              prefixIcon: const Icon(Icons.notes),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // Date & Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(DateFormatter.formatDateOnly(_selectedDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(_selectedTime.format(context)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Payment Method
            NeumorphicDropdown<String>(
              value: _selectedPaymentMethod,
              labelText: 'Payment Method',
              prefixIcon: const Icon(Icons.account_balance_wallet),
              items: AppConstants.paymentMethods.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPaymentMethod = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Category
            Text(
              'Category',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: AppConstants.categories.map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                  avatar: Icon(
                    CategoryHelper.getIcon(category),
                    size: 18,
                    color: isSelected ? theme.colorScheme.onPrimary : CategoryHelper.getColor(category),
                  ),
                  selectedColor: theme.colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
