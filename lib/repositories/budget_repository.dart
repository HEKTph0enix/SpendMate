// Repository for budget CRUD with month/year uniqueness.

import '../database/database_helper.dart';
import '../models/budget.dart';
import 'package:uuid/uuid.dart';

class BudgetRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'budgets';
  final _uuid = const Uuid();

  Future<Budget?> getBudgetForMonth(int month, int year) async {
    final results = await _db.query(
      _table,
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Budget.fromMap(results.first);
  }

  Future<Budget> setOrUpdateBudget(
      int month, int year, double limitAmount) async {
    final existing = await getBudgetForMonth(month, year);
    if (existing != null) {
      final updated = existing.copyWith(limitAmount: limitAmount);
      await _db.update(
        _table,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
      return updated;
    } else {
      final budget = Budget(
        id: _uuid.v4(),
        month: month,
        year: year,
        limitAmount: limitAmount,
      );
      await _db.insert(_table, budget.toMap());
      return budget;
    }
  }

  Future<void> deleteBudget(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Budget>> getAllBudgets() async {
    final results = await _db.query(_table, orderBy: 'year DESC, month DESC');
    return results.map((m) => Budget.fromMap(m)).toList();
  }

  Future<void> insertBudget(Budget budget) async {
    await _db.insert(_table, budget.toMap());
  }
}
