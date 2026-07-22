import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/detected_transaction.dart';
import '../../providers/income_detection_provider.dart';
import '../../providers/financial_dashboard_provider.dart';
import '../../providers/cash_wallet_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/expense_provider.dart';
import '../../database/database_helper.dart';
import '../../constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/neobrutal/neobrutal_text_field.dart';
import '../../widgets/neobrutal/neobrutal_button.dart';
import '../../utils/validators.dart';

class ConfirmIncomeScreen extends StatefulWidget {
  final DetectedTransaction transaction;

  const ConfirmIncomeScreen({super.key, required this.transaction});

  @override
  State<ConfirmIncomeScreen> createState() => _ConfirmIncomeScreenState();
}

class _ConfirmIncomeScreenState extends State<ConfirmIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TextEditingController _senderController;
  
  String _selectedCategory = AppConstants.incomeCategories.first;
  String _selectedPaymentMethod = 'Online Transaction';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.transaction.amount.toStringAsFixed(2));
    _noteController = TextEditingController(text: 'Received via ${widget.transaction.packageName}');
    _senderController = TextEditingController(text: widget.transaction.senderName ?? '');
    _selectedDate = widget.transaction.timestamp;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final amount = double.parse(_amountController.text);
      final note = _noteController.text;
      final sender = _senderController.text;

      // Ensure account ID is set (using primary bank for online, or cash)
      final dashboardProvider = context.read<FinancialDashboardProvider>();
      String? accountId;
      
      if (_selectedPaymentMethod == 'Online Transaction') {
        final accounts = dashboardProvider.accounts;
        if (accounts.isNotEmpty) {
          accountId = accounts.first.id;
        }
      }

      final transactionId = const Uuid().v4();

      final transactionMap = {
        'id': transactionId,
        'amount': amount,
        'type': AppConstants.txTypeIncome,
        'category': _selectedCategory,
        'payment_method': _selectedPaymentMethod,
        'source': 'notification_sync',
        'date': _selectedDate.toIso8601String(),
        'note': note.isNotEmpty ? note : null,
        'account_id': accountId,
        'is_recurring': 0,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Insert into transactions (V2) table directly
      final db = DatabaseHelper();
      await db.insert('transactions', transactionMap);

      // Update balances
      if (_selectedPaymentMethod == 'Cash') {
        final cashProvider = context.read<CashWalletProvider>();
        await cashProvider.addCashReceived(amount);
      } else if (accountId != null) {
        await dashboardProvider.updateAccountBalance(accountId, amount); // positive for income
      }

      // Mark detection as confirmed
      await context.read<IncomeDetectionProvider>().markAsConfirmed(widget.transaction.id);

      // Refresh providers
      context.read<FinancialDashboardProvider>().refreshDashboard();
      context.read<AnalyticsProvider>().loadAnalytics();
      
      if (mounted) {
        Navigator.pop(context); // close confirm screen
      }
    } catch (e) {
      debugPrint('Error saving income: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save income: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Income')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NeoBrutalTextField(
                controller: _amountController,
                labelText: 'Amount (₹)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: Validators.amount,
              ),
              const SizedBox(height: 16),
              NeoBrutalTextField(
                controller: _senderController,
                labelText: 'Sender / Source',
                hintText: 'Who sent this money?',
              ),
              const SizedBox(height: 16),
              Text('Category', style: AppTextStyles.label(isDark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.getBorder(isDark), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    items: AppConstants.incomeCategories.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedCategory = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Payment Method', style: AppTextStyles.label(isDark)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.getBorder(isDark), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPaymentMethod,
                    isExpanded: true,
                    items: ['Online Transaction', 'Cash'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedPaymentMethod = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              NeoBrutalTextField(
                controller: _noteController,
                labelText: 'Note',
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              NeoBrutalButton(
                onPressed: _isSaving ? null : _saveIncome,
                backgroundColor: AppColors.accentTeal,
                child: _isSaving 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('CONFIRM AND SAVE'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
