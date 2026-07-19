// Repository for unified Transaction CRUD with filtering, aggregation, and bulk import.

import '../database/database_helper.dart';
import '../models/transaction.dart' as app;

class TransactionRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'transactions';

  Future<void> insertTransaction(app.Transaction transaction) async {
    await _db.insert(_table, transaction.toMap());
  }

  Future<void> updateTransaction(app.Transaction transaction) async {
    await _db.update(
      _table,
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<app.Transaction?> getById(String id) async {
    final results = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return app.Transaction.fromMap(results.first);
  }

  Future<List<app.Transaction>> getAll({String orderBy = 'date DESC'}) async {
    final results = await _db.query(_table, orderBy: orderBy);
    return results.map((m) => app.Transaction.fromMap(m)).toList();
  }

  Future<List<app.Transaction>> getByDateRange(
    DateTime start,
    DateTime end, {
    String? type,
    String? category,
  }) async {
    String where = 'date >= ? AND date <= ?';
    List<dynamic> whereArgs = [start.toIso8601String(), end.toIso8601String()];

    if (type != null) {
      where += ' AND type = ?';
      whereArgs.add(type);
    }
    if (category != null) {
      where += ' AND category = ?';
      whereArgs.add(category);
    }

    final results = await _db.query(
      _table,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );
    return results.map((m) => app.Transaction.fromMap(m)).toList();
  }

  Future<List<app.Transaction>> getByAccount(String accountId) async {
    final results = await _db.query(
      _table,
      where: 'account_id = ?',
      whereArgs: [accountId],
      orderBy: 'date DESC',
    );
    return results.map((m) => app.Transaction.fromMap(m)).toList();
  }

  Future<List<app.Transaction>> getByCategory(String category) async {
    final results = await _db.query(
      _table,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date DESC',
    );
    return results.map((m) => app.Transaction.fromMap(m)).toList();
  }

  Future<double> getIncomeTotal(DateTime start, DateTime end) async {
    final result = await _db.rawQuery(
      '''SELECT COALESCE(SUM(amount), 0) as total FROM $_table 
         WHERE type = 'income' AND date >= ? AND date <= ?''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getExpenseTotal(DateTime start, DateTime end) async {
    final result = await _db.rawQuery(
      '''SELECT COALESCE(SUM(amount), 0) as total FROM $_table 
         WHERE type = 'expense' AND date >= ? AND date <= ?''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<Map<String, double>> getCategoryTotals(
    DateTime start,
    DateTime end, {
    String type = 'expense',
  }) async {
    final result = await _db.rawQuery(
      '''SELECT category, SUM(amount) as total FROM $_table 
         WHERE type = ? AND date >= ? AND date <= ?
         GROUP BY category ORDER BY total DESC''',
      [type, start.toIso8601String(), end.toIso8601String()],
    );
    return {
      for (final row in result)
        row['category'] as String: (row['total'] as num).toDouble(),
    };
  }

  Future<Map<String, double>> getPaymentMethodTotals(
    DateTime start,
    DateTime end,
  ) async {
    final result = await _db.rawQuery(
      '''SELECT payment_method, SUM(amount) as total FROM $_table 
         WHERE type = 'expense' AND date >= ? AND date <= ?
         GROUP BY payment_method ORDER BY total DESC''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return {
      for (final row in result)
        row['payment_method'] as String: (row['total'] as num).toDouble(),
    };
  }

  Future<List<app.Transaction>> getRecent({int limit = 10}) async {
    final results = await _db.query(
      _table,
      orderBy: 'date DESC',
      limit: limit,
    );
    return results.map((m) => app.Transaction.fromMap(m)).toList();
  }

  Future<void> importBulk(List<app.Transaction> transactions) async {
    await _db.insertBulkTransactions(
      transactions.map((t) => t.toMap()).toList(),
    );
  }

  /// Daily totals for a date range (for chart data).
  Future<Map<DateTime, double>> getDailyTotals(
    DateTime start,
    DateTime end, {
    String type = 'expense',
  }) async {
    final transactions = await getByDateRange(start, end, type: type);
    final Map<DateTime, double> dailyTotals = {};

    for (final tx in transactions) {
      final dayKey = DateTime(tx.date.year, tx.date.month, tx.date.day);
      dailyTotals[dayKey] = (dailyTotals[dayKey] ?? 0) + tx.amount;
    }
    return dailyTotals;
  }

  Future<int> getTransactionCount(DateTime start, DateTime end) async {
    final result = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM $_table WHERE date >= ? AND date <= ?',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<double> getHighestTransaction(DateTime start, DateTime end) async {
    final result = await _db.rawQuery(
      '''SELECT COALESCE(MAX(amount), 0) as max_amount FROM $_table 
         WHERE type = 'expense' AND date >= ? AND date <= ?''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    return (result.first['max_amount'] as num?)?.toDouble() ?? 0.0;
  }
}
