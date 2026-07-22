// Repository for financial account CRUD operations.

import '../database/database_helper.dart';
import '../models/financial_account.dart';

class FinancialAccountRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'financial_accounts';

  Future<void> insertAccount(FinancialAccount account) async {
    await _db.insert(_table, account.toMap());
  }

  Future<void> updateAccount(FinancialAccount account) async {
    await _db.update(
      _table,
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

  Future<FinancialAccount?> getAccountById(String id) async {
    final results = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return FinancialAccount.fromMap(results.first);
  }

  Future<List<FinancialAccount>> getAllAccounts() async {
    final results = await _db.query(_table, orderBy: 'created_at DESC');
    return results.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  Future<List<FinancialAccount>> getActiveAccounts() async {
    final results = await _db.query(
      _table,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => FinancialAccount.fromMap(m)).toList();
  }

  Future<double> getTotalBankBalance() async {
    final result = await _db.rawQuery(
      'SELECT COALESCE(SUM(balance), 0) as total FROM $_table WHERE is_active = 1',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<void> updateBalance(String accountId, double newBalance) async {
    await _db.update(
      _table,
      {
        'balance': newBalance,
        'last_synced_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<void> deactivateAccount(String accountId) async {
    await _db.update(
      _table,
      {
        'is_active': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [accountId],
    );
  }

  Future<void> deleteAccountAndTransactions(String accountId) async {
    final db = await _db.database;
    await db.transaction((txn) async {
      await txn.delete('transactions',
          where: 'account_id = ?', whereArgs: [accountId]);
      await txn.delete(_table, where: 'id = ?', whereArgs: [accountId]);
    });
  }

  Future<void> deleteAccount(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
