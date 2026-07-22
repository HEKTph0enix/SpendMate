import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/expense.dart';
import '../../models/group_split.dart';
import '../../models/user.dart';
import '../../providers/group_provider.dart';
import '../../constants/app_constants.dart';
import '../../constants/categories.dart';
import '../../utils/split_calculator.dart';
import '../../utils/validators.dart';
import '../../widgets/neobrutal/neobrutal_text_field.dart';
import '../../widgets/neobrutal/neobrutal_dropdown.dart';

class AddGroupExpenseScreen extends StatefulWidget {
  final String groupId;

  const AddGroupExpenseScreen({super.key, required this.groupId});

  @override
  State<AddGroupExpenseScreen> createState() => _AddGroupExpenseScreenState();
}

class _AddGroupExpenseScreenState extends State<AddGroupExpenseScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();

  late TabController _tabController;

  String _selectedCategory = AppConstants.categories.first;
  String _selectedPaymentMethod = AppConstants.paymentMethods.first;
  User? _payer;

  // Split state
  Set<String> _includedMemberIds = {};
  Map<String, TextEditingController> _customControllers = {};
  Map<String, TextEditingController> _percentControllers = {};

  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Re-render when tab changes
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GroupProvider>(context, listen: false);
      if (provider.activeGroupUsers.isNotEmpty) {
        setState(() {
          _payer = provider.activeGroupUsers.first;
          _includedMemberIds =
              provider.activeGroupUsers.map((u) => u.id).toSet();

          for (var user in provider.activeGroupUsers) {
            _customControllers[user.id] = TextEditingController();
            _percentControllers[user.id] = TextEditingController();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descController.dispose();
    _tabController.dispose();
    for (var c in _customControllers.values) {
      c.dispose();
    }
    for (var c in _percentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    final totalAmount = Validators.parseAmount(_amountController.text) ?? 0.0;
    final provider = Provider.of<GroupProvider>(context, listen: false);

    // Validate Splits
    List<GroupSplit> finalSplits = [];
    final expenseId = _uuid.v4();

    if (_tabController.index == 0) {
      // Equal
      if (_includedMemberIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Select at least one member to split with.')));
        return;
      }
      finalSplits = SplitCalculator.calculateEqualSplit(
        expenseId: expenseId,
        totalAmount: totalAmount,
        memberUserIds: _includedMemberIds.toList(),
      );
    } else if (_tabController.index == 1) {
      // Custom
      Map<String, double> shares = {};
      for (var id in _includedMemberIds) {
        shares[id] =
            Validators.parseAmount(_customControllers[id]?.text) ?? 0.0;
      }

      final error = Validators.customSplit(totalAmount, shares);
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        return;
      }

      finalSplits = SplitCalculator.calculateCustomSplit(
        expenseId: expenseId,
        totalAmount: totalAmount,
        memberShares: shares,
      );
    } else {
      // Percentage
      Map<String, double> percentages = {};
      for (var id in _includedMemberIds) {
        percentages[id] =
            Validators.parseAmount(_percentControllers[id]?.text) ?? 0.0;
      }

      final error = Validators.percentageSplit(percentages);
      if (error != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error)));
        return;
      }

      finalSplits = SplitCalculator.calculatePercentageSplit(
        expenseId: expenseId,
        totalAmount: totalAmount,
        memberPercentages: percentages,
      );
    }

    setState(() => _isLoading = true);

    final expense = Expense(
      id: expenseId,
      amount: totalAmount,
      dateTime: DateTime.now(),
      category: _selectedCategory,
      paymentMethod: _selectedPaymentMethod,
      note: _descController.text.trim(),
      isGroupExpense: true,
      groupId: widget.groupId,
      payerUserId: _payer!.id,
    );

    await provider.addGroupExpense(expense, finalSplits);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<GroupProvider>(context);
    final users = provider.activeGroupUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Group Expense'),
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
              onPressed: _saveExpense,
              child: const Text('SAVE'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Amount
            NeoBrutalTextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              labelText: 'Total Amount',
              prefixText: '₹ ',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              validator: Validators.amount,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Description
            NeoBrutalTextField(
              controller: _descController,
              labelText: 'Description',
              prefixIcon: const Icon(Icons.description),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) => Validators.required(v, 'Description'),
            ),
            const SizedBox(height: 16),

            // Paid By
            NeoBrutalDropdown<User>(
              value: _payer,
              labelText: 'Paid By',
              prefixIcon: const Icon(Icons.person),
              items: users.map((user) {
                return DropdownMenuItem(
                  value: user,
                  child: Text(user.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _payer = value);
              },
            ),
            const SizedBox(height: 16),

            // Category (Simplified single line scroll)
            NeoBrutalDropdown<String>(
              value: _selectedCategory,
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category),
              items: AppConstants.categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedCategory = v);
              },
            ),

            const SizedBox(height: 32),

            // Split Options
            Text('Split Details', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),

            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Equal'),
                Tab(text: 'Exact'),
                Tab(text: '%'),
              ],
            ),

            const SizedBox(height: 16),

            // Dynamic Split List based on Tab
            ...users.map((user) {
              final isIncluded = _includedMemberIds.contains(user.id);

              Widget splitInput = const SizedBox.shrink();

              if (_tabController.index == 1) {
                // Exact Amount
                splitInput = SizedBox(
                  width: 100,
                  child: NeoBrutalTextField(
                    controller: _customControllers[user.id],
                    enabled: isIncluded,
                    keyboardType: TextInputType.number,
                    prefixText: '₹',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                );
              } else if (_tabController.index == 2) {
                // Percentage
                splitInput = SizedBox(
                  width: 80,
                  child: NeoBrutalTextField(
                    controller: _percentControllers[user.id],
                    enabled: isIncluded,
                    keyboardType: TextInputType.number,
                    suffixText: '%',
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  ),
                );
              } else {
                // Equal split calculation for display
                final total =
                    Validators.parseAmount(_amountController.text) ?? 0.0;
                final count = _includedMemberIds.length;
                final share = isIncluded && count > 0
                    ? (total / count).toStringAsFixed(2)
                    : '0.00';
                splitInput =
                    Text('₹$share', style: theme.textTheme.titleMedium);
              }

              return CheckboxListTile(
                value: isIncluded,
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _includedMemberIds.add(user.id);
                    } else {
                      _includedMemberIds.remove(user.id);
                    }
                  });
                },
                title: Text(user.name),
                secondary: splitInput,
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
          ],
        ),
      ),
    );
  }
}
