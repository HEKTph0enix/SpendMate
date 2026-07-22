// Cash wallet service — manages cash-in-hand balance with full audit trail.
// Every cash operation is logged as a Transaction for history tracking.

import 'package:uuid/uuid.dart';
import '../models/transaction.dart' as app;
import '../repositories/cash_wallet_repository.dart';
import '../repositories/transaction_repository.dart';

class CashWalletService {
  final CashWalletRepository _walletRepo;
  final TransactionRepository _transactionRepo;
  static const _uuid = Uuid();

  CashWalletService({
    CashWalletRepository? walletRepo,
    TransactionRepository? transactionRepo,
  })  : _walletRepo = walletRepo ?? CashWalletRepository(),
        _transactionRepo = transactionRepo ?? TransactionRepository();

  /// Get current cash balance.
  Future<double> getBalance() async {
    return await _walletRepo.getBalance();
  }

  /// Set the initial cash balance (first-time setup).
  Future<void> setInitialBalance(double amount) async {
    await _walletRepo.updateBalance(amount);
  }

  /// Add cash received (income).
  Future<void> addCashReceived({
    required double amount,
    String? note,
    String category = 'Other Income',
  }) async {
    final currentBalance = await _walletRepo.getBalance();
    await _walletRepo.updateBalance(currentBalance + amount);

    // Log as income transaction
    final tx = app.Transaction(
      id: _uuid.v4(),
      amount: amount,
      type: app.TransactionType.income,
      category: category,
      paymentMethod: 'Cash',
      source: app.TransactionSource.manual,
      date: DateTime.now(),
      note: note ?? 'Cash received',
    );
    await _transactionRepo.insertTransaction(tx);
  }

  /// Record a cash expense (deducts from balance).
  Future<void> recordCashExpense({
    required double amount,
    required String category,
    String? note,
  }) async {
    final currentBalance = await _walletRepo.getBalance();
    await _walletRepo.updateBalance(currentBalance - amount);

    // Log as expense transaction
    final tx = app.Transaction(
      id: _uuid.v4(),
      amount: amount,
      type: app.TransactionType.expense,
      category: category,
      paymentMethod: 'Cash',
      source: app.TransactionSource.manual,
      date: DateTime.now(),
      note: note,
    );
    await _transactionRepo.insertTransaction(tx);
  }

  /// Manually correct the cash balance (for discrepancies).
  Future<void> correctBalance(double newBalance) async {
    final currentBalance = await _walletRepo.getBalance();
    final difference = newBalance - currentBalance;

    await _walletRepo.updateBalance(newBalance);

    // Log the correction as an adjustment transaction
    if (difference != 0) {
      final tx = app.Transaction(
        id: _uuid.v4(),
        amount: difference.abs(),
        type: difference > 0
            ? app.TransactionType.income
            : app.TransactionType.expense,
        category: 'Other',
        paymentMethod: 'Cash',
        source: app.TransactionSource.manual,
        date: DateTime.now(),
        note:
            'Balance correction: ${difference > 0 ? '+' : ''}${difference.toStringAsFixed(2)}',
      );
      await _transactionRepo.insertTransaction(tx);
    }
  }

  /// Get all cash transactions.
  Future<List<app.Transaction>> getCashTransactions() async {
    final all = await _transactionRepo.getAll();
    return all.where((tx) => tx.paymentMethod == 'Cash').toList();
  }
}
