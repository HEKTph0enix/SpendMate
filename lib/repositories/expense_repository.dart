// Repository for expense CRUD with filtering, search, and personal spending calculations.

import '../database/database_helper.dart';
import '../models/expense.dart';

class ExpenseRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'expenses';

  Future<void> insertExpense(Expense expense) async {
    await _db.insert(_table, expense.toMap());
  }

  Future<void> updateExpense(Expense expense) async {
    await _db.update(
      _table,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> deleteExpense(String id) async {
    // Splits are cascade-deleted by foreign key
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<Expense?> getExpenseById(String id) async {
    final results = await _db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Expense.fromMap(results.first);
  }

  Future<List<Expense>> getAllExpenses({String orderBy = 'date_time DESC'}) async {
    final results = await _db.query(_table, orderBy: orderBy);
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getPersonalExpenses({String orderBy = 'date_time DESC'}) async {
    final results = await _db.query(
      _table,
      where: 'is_group_expense = ?',
      whereArgs: [0],
      orderBy: orderBy,
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getExpensesByDateRange(
    DateTime start,
    DateTime end, {
    bool personalOnly = false,
  }) async {
    String where = 'date_time >= ? AND date_time <= ?';
    List<dynamic> whereArgs = [start.toIso8601String(), end.toIso8601String()];

    if (personalOnly) {
      where += ' AND is_group_expense = ?';
      whereArgs.add(0);
    }

    final results = await _db.query(
      _table,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date_time DESC',
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getExpensesByCategory(String category) async {
    final results = await _db.query(
      _table,
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'date_time DESC',
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getExpensesByPaymentMethod(String method) async {
    final results = await _db.query(
      _table,
      where: 'payment_method = ?',
      whereArgs: [method],
      orderBy: 'date_time DESC',
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getGroupExpenses(String groupId) async {
    final results = await _db.query(
      _table,
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'date_time DESC',
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> searchExpenses(String query) async {
    final results = await _db.query(
      _table,
      where: 'note LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date_time DESC',
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  Future<List<Expense>> getFilteredExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    String? paymentMethod,
    bool? isGroupExpense,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
  }) async {
    List<String> conditions = [];
    List<dynamic> args = [];

    if (startDate != null) {
      conditions.add('date_time >= ?');
      args.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      conditions.add('date_time <= ?');
      args.add(endDate.toIso8601String());
    }
    if (category != null) {
      conditions.add('category = ?');
      args.add(category);
    }
    if (paymentMethod != null) {
      conditions.add('payment_method = ?');
      args.add(paymentMethod);
    }
    if (isGroupExpense != null) {
      conditions.add('is_group_expense = ?');
      args.add(isGroupExpense ? 1 : 0);
    }
    if (minAmount != null) {
      conditions.add('amount >= ?');
      args.add(minAmount);
    }
    if (maxAmount != null) {
      conditions.add('amount <= ?');
      args.add(maxAmount);
    }
    if (searchQuery != null && searchQuery.isNotEmpty) {
      conditions.add('note LIKE ?');
      args.add('%$searchQuery%');
    }

    final where = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final results = await _db.query(
      _table,
      where: where,
      whereArgs: args.isNotEmpty ? args : null,
      orderBy: 'date_time DESC',
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  /// Get total personal spending for a date range.
  /// For group expenses, only counts the user's share (via group_splits).
  Future<double> getPersonalSpendingTotal(
    DateTime start,
    DateTime end,
    String currentUserId,
  ) async {
    // Personal expenses total
    final personalResult = await _db.rawQuery(
      '''SELECT COALESCE(SUM(amount), 0) as total FROM expenses 
         WHERE is_group_expense = 0 
         AND date_time >= ? AND date_time <= ?''',
      [start.toIso8601String(), end.toIso8601String()],
    );
    final personalTotal = (personalResult.first['total'] as num?)?.toDouble() ?? 0.0;

    // Group expenses: user's share only
    final groupResult = await _db.rawQuery(
      '''SELECT COALESCE(SUM(gs.share_amount), 0) as total 
         FROM group_splits gs
         INNER JOIN expenses e ON gs.expense_id = e.id
         WHERE gs.user_id = ?
         AND e.date_time >= ? AND e.date_time <= ?''',
      [currentUserId, start.toIso8601String(), end.toIso8601String()],
    );
    final groupShareTotal = (groupResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return personalTotal + groupShareTotal;
  }

  Future<List<Expense>> getRecentExpenses({int limit = 10}) async {
    final results = await _db.query(
      _table,
      orderBy: 'date_time DESC',
      limit: limit,
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }
}
