// Repository for group operations: CRUD for groups, members, splits, and balance calculations.

import '../database/database_helper.dart';
import '../models/expense.dart';
import '../models/expense_group.dart';
import '../models/group_member.dart';
import '../models/group_split.dart';

class GroupRepository {
  final DatabaseHelper _db = DatabaseHelper();

  // ─── Groups ────────────────────────────────────────────────────────

  Future<void> insertGroup(ExpenseGroup group) async {
    await _db.insert('expense_groups', group.toMap());
  }

  Future<void> updateGroup(ExpenseGroup group) async {
    await _db.update(
      'expense_groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<void> deleteGroup(String id) async {
    // CASCADE will handle members, but we need to clean up expenses and settlements
    await _db.runTransaction((txn) async {
      // Delete splits for group expenses
      await txn.rawDelete(
        'DELETE FROM group_splits WHERE expense_id IN (SELECT id FROM expenses WHERE group_id = ?)',
        [id],
      );
      // Delete settlements
      await txn.delete('settlements', where: 'group_id = ?', whereArgs: [id]);
      // Delete group expenses
      await txn.delete('expenses', where: 'group_id = ?', whereArgs: [id]);
      // Delete members (cascade should handle but being explicit)
      await txn.delete('group_members', where: 'group_id = ?', whereArgs: [id]);
      // Delete group
      await txn.delete('expense_groups', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<ExpenseGroup?> getGroupById(String id) async {
    final results = await _db.query(
      'expense_groups',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (results.isEmpty) return null;
    return ExpenseGroup.fromMap(results.first);
  }

  Future<List<ExpenseGroup>> getAllGroups() async {
    final results = await _db.query('expense_groups', orderBy: 'updated_at DESC');
    return results.map((m) => ExpenseGroup.fromMap(m)).toList();
  }

  // ─── Members ───────────────────────────────────────────────────────

  Future<void> addMember(GroupMember member) async {
    await _db.insert('group_members', member.toMap());
  }

  Future<void> removeMember(String memberId) async {
    await _db.delete('group_members', where: 'id = ?', whereArgs: [memberId]);
  }

  Future<void> removeMemberByUserAndGroup(String userId, String groupId) async {
    await _db.delete(
      'group_members',
      where: 'user_id = ? AND group_id = ?',
      whereArgs: [userId, groupId],
    );
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    final results = await _db.query(
      'group_members',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );
    return results.map((m) => GroupMember.fromMap(m)).toList();
  }

  Future<int> getMemberCount(String groupId) async {
    final results = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM group_members WHERE group_id = ?',
      [groupId],
    );
    return (results.first['count'] as int?) ?? 0;
  }

  Future<bool> isMember(String userId, String groupId) async {
    final results = await _db.query(
      'group_members',
      where: 'user_id = ? AND group_id = ?',
      whereArgs: [userId, groupId],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  // ─── Splits ────────────────────────────────────────────────────────

  Future<void> insertSplit(GroupSplit split) async {
    await _db.insert('group_splits', split.toMap());
  }

  Future<List<GroupSplit>> getSplitsForExpense(String expenseId) async {
    final results = await _db.query(
      'group_splits',
      where: 'expense_id = ?',
      whereArgs: [expenseId],
    );
    return results.map((m) => GroupSplit.fromMap(m)).toList();
  }

  Future<void> deleteSplitsForExpense(String expenseId) async {
    await _db.delete('group_splits', where: 'expense_id = ?', whereArgs: [expenseId]);
  }

  // ─── Group Expenses with Splits (transactional) ────────────────────

  Future<void> addGroupExpenseWithSplits(
    Expense expense,
    List<GroupSplit> splits,
  ) async {
    await _db.insertGroupExpenseWithSplits(
      expense.toMap(),
      splits.map((s) => s.toMap()).toList(),
    );
  }

  Future<void> updateGroupExpenseWithSplits(
    Expense expense,
    List<GroupSplit> splits,
  ) async {
    await _db.runTransaction((txn) async {
      await txn.update(
        'expenses',
        expense.toMap(),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      await txn.delete('group_splits', where: 'expense_id = ?', whereArgs: [expense.id]);
      for (final split in splits) {
        await txn.insert('group_splits', split.toMap());
      }
    });
  }

  // ─── Group Expenses ────────────────────────────────────────────────

  Future<List<Expense>> getGroupExpenses(String groupId) async {
    final results = await _db.query(
      'expenses',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'date_time DESC',
    );
    return results.map((m) => Expense.fromMap(m)).toList();
  }

  // ─── Balance Calculations ──────────────────────────────────────────

  /// Calculate net balance for each member in a group.
  /// Balance = Total paid - Total share
  /// Positive = is owed money, Negative = owes money
  Future<Map<String, double>> calculateGroupBalances(String groupId) async {
    final Map<String, double> balances = {};

    // Get all group expenses
    final expenses = await getGroupExpenses(groupId);

    for (final expense in expenses) {
      // Add full amount to payer's balance (they paid)
      if (expense.payerUserId != null) {
        balances[expense.payerUserId!] =
            (balances[expense.payerUserId!] ?? 0) + expense.amount;
      }

      // Subtract each person's share from their balance
      final splits = await getSplitsForExpense(expense.id);
      for (final split in splits) {
        balances[split.userId] =
            (balances[split.userId] ?? 0) - split.shareAmount;
      }
    }

    // Factor in settlements
    final settlements = await _db.query(
      'settlements',
      where: 'group_id = ?',
      whereArgs: [groupId],
    );

    for (final s in settlements) {
      final paidBy = s['paid_by_user_id'] as String;
      final paidTo = s['paid_to_user_id'] as String;
      final amount = (s['amount'] as num).toDouble();

      // Settlement: paidBy gives money to paidTo
      // paidBy's balance goes down (they paid out)
      // paidTo's balance goes up (they received)
      // But in our system: positive = owed money, negative = owes money
      // When A pays B in settlement: A's debt decreases, B's credit decreases
      balances[paidBy] = (balances[paidBy] ?? 0) + amount;
      balances[paidTo] = (balances[paidTo] ?? 0) - amount;
    }

    return balances;
  }

  Future<Expense?> getLatestGroupExpense(String groupId) async {
    final results = await _db.query(
      'expenses',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'date_time DESC',
      limit: 1,
    );
    if (results.isEmpty) return null;
    return Expense.fromMap(results.first);
  }

  Future<List<ExpenseGroup>> searchGroups(String query) async {
    final results = await _db.query(
      'expense_groups',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'updated_at DESC',
    );
    return results.map((m) => ExpenseGroup.fromMap(m)).toList();
  }
}
