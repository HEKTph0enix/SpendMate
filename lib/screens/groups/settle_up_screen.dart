import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/settlement.dart';
import '../../models/user.dart';
import '../../providers/group_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/validators.dart';

class SettleUpScreen extends StatefulWidget {
  final String groupId;

  const SettleUpScreen({super.key, required this.groupId});

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  
  User? _paidBy;
  User? _paidTo;
  
  bool _isLoading = false;
  final _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<GroupProvider>(context, listen: false);
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      
      final users = provider.activeGroupUsers;
      if (users.isNotEmpty) {
        setState(() {
          // Default paid by is current user if they are in the group
          _paidBy = users.firstWhere(
            (u) => u.id == settings.currentUserId, 
            orElse: () => users.first
          );
          
          // Default paid to is someone else
          _paidTo = users.firstWhere(
            (u) => u.id != _paidBy?.id,
            orElse: () => users.last
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveSettlement() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_paidBy?.id == _paidTo?.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payer and Payee cannot be the same person.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final amount = Validators.parseAmount(_amountController.text) ?? 0.0;
    
    final settlement = Settlement(
      id: _uuid.v4(),
      groupId: widget.groupId,
      paidByUserId: _paidBy!.id,
      paidToUserId: _paidTo!.id,
      amount: amount,
      dateTime: DateTime.now(),
      note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );

    final provider = Provider.of<GroupProvider>(context, listen: false);
    await provider.addSettlement(settlement);

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final users = Provider.of<GroupProvider>(context).activeGroupUsers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Payment'),
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
              onPressed: _saveSettlement,
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
            TextFormField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
                prefixStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              validator: Validators.amount,
            ),
            const SizedBox(height: 32),
            
            // Paid By
            DropdownButtonFormField<User>(
              value: _paidBy,
              decoration: const InputDecoration(
                labelText: 'Who Paid',
                prefixIcon: Icon(Icons.arrow_upward, color: Colors.red),
              ),
              items: users.map((user) {
                return DropdownMenuItem(value: user, child: Text(user.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _paidBy = value);
              },
            ),
            const SizedBox(height: 16),
            
            // Icon in middle
            const Center(child: Icon(Icons.compare_arrows, size: 32)),
            const SizedBox(height: 16),
            
            // Paid To
            DropdownButtonFormField<User>(
              value: _paidTo,
              decoration: const InputDecoration(
                labelText: 'Who Received',
                prefixIcon: Icon(Icons.arrow_downward, color: Colors.green),
              ),
              items: users.map((user) {
                return DropdownMenuItem(value: user, child: Text(user.name));
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _paidTo = value);
              },
            ),
            const SizedBox(height: 32),
            
            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
                prefixIcon: Icon(Icons.notes),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
