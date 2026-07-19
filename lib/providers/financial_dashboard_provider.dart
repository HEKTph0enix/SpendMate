import 'package:flutter/material.dart';
import '../models/financial_account.dart';
import '../models/transaction.dart' as app;
import '../services/bank_sync_service.dart';
import '../services/sms_transaction_parser.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/financial_account_repository.dart';

class FinancialDashboardProvider extends ChangeNotifier {
  final BankSyncService _bankSyncService = BankSyncService();
  final TransactionRepository _transactionRepo = TransactionRepository();
  final FinancialAccountRepository _accountRepo = FinancialAccountRepository();
  final SmsTransactionParser _smsParser = SmsTransactionParser();

  bool _isLoading = false;
  double _totalBankBalance = 0.0;
  List<FinancialAccount> _accounts = [];
  List<app.Transaction> _recentTransactions = [];

  bool get isLoading => _isLoading;
  double get totalBankBalance => _totalBankBalance;
  List<FinancialAccount> get accounts => _accounts;
  List<app.Transaction> get recentTransactions => _recentTransactions;

  FinancialDashboardProvider() {
    refreshDashboard();
  }

  Future<void> refreshDashboard() async {
    _isLoading = true;
    notifyListeners();

    try {
      _totalBankBalance = await _bankSyncService.getTotalBankBalance();
      _accounts = await _bankSyncService.getActiveAccounts();
      _recentTransactions = await _transactionRepo.getRecent(limit: 5);
    } catch (e) {
      debugPrint('Error refreshing dashboard: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addManualAccount(String name, double initialBalance, String type, String? bankName, String? maskedNumber) async {
    final accountType = AccountType.values.firstWhere(
      (e) => e.name.toLowerCase() == type.toLowerCase() || (e.name == 'bank' && !['wallet', 'upi'].contains(type.toLowerCase())),
      orElse: () => AccountType.bank,
    );

    final account = FinancialAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: accountType,
      bankName: bankName,
      maskedAccountNumber: maskedNumber,
      balance: initialBalance,
    );
    await _accountRepo.insertAccount(account);
    await refreshDashboard();
  }

  Future<void> updateAccountBalance(String accountId, double newBalance) async {
    await _bankSyncService.manualBalanceUpdate(accountId, newBalance);
    await refreshDashboard();
  }

  Future<void> deleteAccount(String accountId) async {
    await _accountRepo.deleteAccountAndTransactions(accountId);
    await refreshDashboard();
  }

  Future<void> parseSmsMessages(List<SmsMessage> messages) async {
    final newTransactions = _smsParser.parseMessages(messages);
    if (newTransactions.isNotEmpty) {
      await _transactionRepo.importBulk(newTransactions);
      await refreshDashboard();
    }
  }
}
