import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/budget_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/validators.dart';
import '../../constants/app_constants.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BudgetProvider>(context, listen: false);
      if (provider.hasBudget) {
        _amountController.text = provider.limitAmount.toString();
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final amount = Validators.parseAmount(_amountController.text) ?? 0.0;
    
    final provider = Provider.of<BudgetProvider>(context, listen: false);
    await provider.setBudget(amount);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Budget'),
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
              onPressed: _saveBudget,
              child: const Text('SAVE'),
            ),
        ],
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Set a monthly limit for your personal spending to keep your finances on track.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Budget Amount',
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  validator: Validators.amount,
                ),
                const SizedBox(height: 32),

                if (provider.hasBudget) ...[
                  Text('Current Status', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 16),
                  
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Used'),
                              Text(
                                CurrencyFormatter.format(provider.currentUsage),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Remaining'),
                              Text(
                                CurrencyFormatter.format(provider.remainingAmount),
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: provider.isSafe ? Colors.green : (provider.isWarning ? Colors.orange : Colors.red),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          LinearProgressIndicator(
                            value: provider.usagePercentage,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              provider.isSafe ? Colors.green : (provider.isWarning ? Colors.orange : Colors.red),
                            ),
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
