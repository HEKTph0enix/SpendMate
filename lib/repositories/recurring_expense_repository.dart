// Repository for recurring expense CRUD.

import '../database/database_helper.dart';
import '../models/recurring_expense.dart';

class RecurringExpenseRepository {
  final DatabaseHelper _db = DatabaseHelper();
  static const _table = 'recurring_expenses';

  Future<void> insert(RecurringExpense expense) async {
    await _db.insert(_table, expense.toMap());
  }

  Future<void> update(RecurringExpense expense) async {
    await _db.update(
      _table,
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RecurringExpense>> getAll() async {
    final results = await _db.query(_table, orderBy: 'created_at DESC');
    return results.map((m) => RecurringExpense.fromMap(m)).toList();
  }

  Future<List<RecurringExpense>> getActive() async {
    final results = await _db.query(
      _table,
      where: 'is_active = ?',
      whereArgs: [1],
      orderBy: 'amount DESC',
    );
    return results.map((m) => RecurringExpense.fromMap(m)).toList();
  }

  Future<void> deactivate(String id) async {
    await _db.update(
      _table,
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    await _db.delete(_table);
  }
}
