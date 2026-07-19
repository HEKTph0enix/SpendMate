import 'package:flutter/material.dart';
import '../models/transaction.dart' as app;
import '../services/cash_wallet_service.dart';

class CashWalletProvider extends ChangeNotifier {
  final CashWalletService _walletService = CashWalletService();

  bool _isLoading = false;
  double _balance = 0.0;
  List<app.Transaction> _cashTransactions = [];

  bool get isLoading => _isLoading;
  double get balance => _balance;
  List<app.Transaction> get cashTransactions => _cashTransactions;

  CashWalletProvider() {
    refreshWallet();
  }

  Future<void> refreshWallet() async {
    _isLoading = true;
    notifyListeners();

    try {
      _balance = await _walletService.getBalance();
      _cashTransactions = await _walletService.getCashTransactions();
      _cashTransactions.sort((a, b) => b.date.compareTo(a.date)); // Sort latest first
    } catch (e) {
      debugPrint('Error refreshing cash wallet: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCashReceived(double amount, {String? note, String category = 'Other Income'}) async {
    await _walletService.addCashReceived(amount: amount, note: note, category: category);
    await refreshWallet();
  }

  Future<void> recordCashExpense(double amount, String category, {String? note}) async {
    await _walletService.recordCashExpense(amount: amount, category: category, note: note);
    await refreshWallet();
  }

  Future<void> correctBalance(double newBalance) async {
    await _walletService.correctBalance(newBalance);
    await refreshWallet();
  }
}
