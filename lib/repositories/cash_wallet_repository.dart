// Repository for cash wallet — single-instance balance tracker.

import '../database/database_helper.dart';
import '../models/cash_wallet.dart';
import 'package:uuid/uuid.dart';

class CashWalletRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'cash_wallet';
  static const _uuid = Uuid();

  /// Gets the existing wallet or creates one with zero balance.
  Future<CashWallet> getOrCreateWallet() async {
    final results = await _db.query(_table, limit: 1);
    if (results.isNotEmpty) {
      return CashWallet.fromMap(results.first);
    }

    final wallet = CashWallet(id: _uuid.v4(), balance: 0.0);
    await _db.insert(_table, wallet.toMap());
    return wallet;
  }

  Future<double> getBalance() async {
    final wallet = await getOrCreateWallet();
    return wallet.balance;
  }

  Future<void> updateBalance(double newBalance) async {
    final wallet = await getOrCreateWallet();
    final updated = wallet.copyWith(balance: newBalance);
    await _db.update(
      _table,
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [wallet.id],
    );
  }

  Future<void> clearWallet() async {
    await _db.delete(_table);
  }
}
