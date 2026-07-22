import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../constants/app_constants.dart';
import '../../constants/categories.dart';
import '../../models/expense.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/statistics_provider.dart';
import '../../providers/financial_dashboard_provider.dart';
import '../../providers/cash_wallet_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/neobrutal/neobrutal_text_field.dart';
import '../../widgets/neobrutal/neobrutal_button.dart';
import 'qr_scanner_screen.dart';

/// Opens an installed UPI application and records the expense after the user
/// manually confirms that the payment succeeded.
///
/// This screen does not read bank balances, UPI transaction history,
/// or automatically verify payment status.
class UpiPaymentScreen extends StatefulWidget {
  const UpiPaymentScreen({super.key});

  @override
  State<UpiPaymentScreen> createState() => _UpiPaymentScreenState();
}

class _UpiPaymentScreenState extends State<UpiPaymentScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _upiIdController = TextEditingController();
  final TextEditingController _payeeNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final Uuid _uuid = const Uuid();

  String _selectedCategory = AppConstants.categories.first;

  bool _isLaunching = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _upiIdController.dispose();
    _payeeNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// Encodes UPI query parameters correctly.
  ///
  /// The @ symbol in the payee UPI ID is preserved because some UPI apps
  /// may not correctly handle it when encoded as %40.
  String _encodeUpiQueryParameters(Map<String, String> parameters) {
    return parameters.entries.map((entry) {
      final String encodedKey = Uri.encodeQueryComponent(entry.key);
      String encodedValue = Uri.encodeQueryComponent(entry.value);

      if (entry.key == 'pa') {
        encodedValue = encodedValue.replaceAll('%40', '@');
      }

      return '$encodedKey=$encodedValue';
    }).join('&');
  }

  Future<void> _scanQR() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QRScannerScreen()),
    );

    if (result != null && result is Map<String, String>) {
      setState(() {
        if (result['upiId'] != null && result['upiId']!.isNotEmpty) {
          _upiIdController.text = result['upiId']!;
        }
        if (result['name'] != null && result['name']!.isNotEmpty) {
          _payeeNameController.text = result['name']!;
        }
      });
    }
  }

  Future<void> _initiateUpiPayment() async {
    final FormState? formState = _formKey.currentState;

    if (formState == null || !formState.validate()) {
      return;
    }

    final String amountText = _amountController.text.trim();
    final double? amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      _showMessage(
        'Please enter a valid amount greater than zero',
        isError: true,
      );
      return;
    }

    final String upiId = _upiIdController.text.trim();
    final String payeeName = _payeeNameController.text.trim();
    final String note = _noteController.text.trim();

    final String query = _encodeUpiQueryParameters({
      'pa': upiId,
      'pn': payeeName,
      'am': amount.toStringAsFixed(2),
      'cu': 'INR',
      'tn': note.isNotEmpty ? note : 'Payment via SpendMate',
      'tr': 'SM${DateTime.now().millisecondsSinceEpoch}',
    });

    final Uri upiUri = Uri.parse('upi://pay?$query');

    setState(() {
      _isLaunching = true;
    });

    try {
      debugPrint('Attempting to open installed UPI application');

      final bool launched = await launchUrl(
        upiUri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        if (!mounted) return;

        _showMessage(
          'Unable to open a UPI app. Make sure Google Pay, PhonePe, '
          'Paytm or BHIM is installed.',
          isError: true,
        );
        return;
      }

      if (!mounted) return;

      await _showPaymentConfirmationDialog(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        note: note.isNotEmpty ? note : null,
      );
    } catch (error) {
      if (!mounted) return;

      debugPrint('UPI launch error: $error');

      _showMessage(
        'Unable to open the UPI application: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLaunching = false;
        });
      }
    }
  }

  Future<void> _showPaymentConfirmationDialog({
    required String upiId,
    required String payeeName,
    required double amount,
    String? note,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Payment Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Did the payment complete successfully in your UPI app?',
              ),
              const SizedBox(height: 16),
              _buildConfirmDetailRow('To', payeeName),
              _buildConfirmDetailRow('UPI ID', upiId),
              _buildConfirmDetailRow(
                'Amount',
                '₹${amount.toStringAsFixed(2)}',
              ),
              if (note != null && note.isNotEmpty)
                _buildConfirmDetailRow('Note', note),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No, it failed'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Yes, payment succeeded'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (confirmed == true) {
      await _saveUpiExpense(
        upiId: upiId,
        payeeName: payeeName,
        amount: amount,
        note: note,
      );
    } else {
      _showMessage('Payment was not recorded');
    }
  }

  Future<void> _saveUpiExpense({
    required String upiId,
    required String payeeName,
    required double amount,
    String? note,
  }) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final Expense expense = Expense(
        id: _uuid.v4(),
        amount: amount,
        dateTime: DateTime.now(),
        category: _selectedCategory,
        paymentMethod: 'Online Transaction',
        note: note,
        upiId: upiId,
        payeeName: payeeName,
        source: AppConstants.txSourceUpiIntent,
        paymentStatus: 'completed',
      );

      final ExpenseProvider expenseProvider = Provider.of<ExpenseProvider>(
        context,
        listen: false,
      );

      await expenseProvider.addExpense(expense);

      if (!mounted) return;

      context.read<BudgetProvider>().loadCurrentBudget();
      context.read<StatisticsProvider>().loadStatistics();
      context.read<FinancialDashboardProvider>().refreshDashboard();
      context.read<CashWalletProvider>().refreshWallet();
      context.read<AnalyticsProvider>().loadAnalytics();

      _showMessage(
        'UPI payment recorded successfully',
        isSuccess: true,
      );

      _clearForm();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (error) {
      if (!mounted) return;

      debugPrint('Failed to save UPI expense: $error');

      _showMessage(
        'Failed to save payment: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _clearForm() {
    _upiIdController.clear();
    _payeeNameController.clear();
    _amountController.clear();
    _noteController.clear();

    setState(() {
      _selectedCategory = AppConstants.categories.first;
    });

    _formKey.currentState?.reset();
  }

  void _showMessage(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.red
            : isSuccess
                ? Colors.green
                : null,
      ),
    );
  }

  Widget _buildConfirmDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay Using UPI'),
        actions: [
          if (_isLaunching || _isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _initiateUpiPayment,
              child: const Text('PAY'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scanQR,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Scan QR'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This opens an installed UPI app to complete the '
                      'payment. When you return, confirm whether the '
                      'payment succeeded.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            NeoBrutalTextField(
              controller: _upiIdController,
              labelText: 'Payee UPI ID',
              hintText: 'Example: name@okaxis',
              prefixIcon: const Icon(Icons.alternate_email),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: Validators.upiId,
            ),
            const SizedBox(height: 20),
            NeoBrutalTextField(
              controller: _payeeNameController,
              labelText: 'Payee Name',
              prefixIcon: const Icon(Icons.person_outline),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: Validators.payeeName,
            ),
            const SizedBox(height: 20),
            NeoBrutalTextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              labelText: 'Amount',
              prefixText: '₹ ',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textInputAction: TextInputAction.next,
              validator: (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Amount is required';
                }

                final double? parsed = double.tryParse(value.trim());

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
            Text(
              'Category',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: AppConstants.categories.map(
                (String category) {
                  final bool isSelected = _selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (!selected) return;

                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    avatar: Icon(
                      CategoryHelper.getIcon(category),
                      size: 18,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : CategoryHelper.getColor(category),
                    ),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                    ),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 24),
            NeoBrutalTextField(
              controller: _noteController,
              labelText: 'Note (Optional)',
              prefixIcon: const Icon(Icons.notes),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!_isLaunching && !_isSaving) {
                  _initiateUpiPayment();
                }
              },
            ),
            const SizedBox(height: 32),
            NeoBrutalButton(
              onPressed:
                  (_isLaunching || _isSaving) ? null : _initiateUpiPayment,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLaunching)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  else
                    const Icon(Icons.launch),
                  const SizedBox(width: 8),
                  Text(
                    _isLaunching
                        ? 'Opening UPI App...'
                        : _isSaving
                            ? 'Saving Payment...'
                            : 'Pay Using UPI',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
