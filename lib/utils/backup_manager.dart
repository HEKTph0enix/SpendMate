// JSON backup and restore manager for all app data.

import 'dart:convert';
import 'dart:io';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../models/expense.dart';
import '../models/expense_group.dart';
import '../models/group_member.dart';
import '../models/group_split.dart';
import '../models/settlement.dart';
import '../models/budget.dart';

class BackupData {
  final List<User> users;
  final List<Expense> expenses;
  final List<ExpenseGroup> groups;
  final List<GroupMember> members;
  final List<GroupSplit> splits;
  final List<Settlement> settlements;
  final List<Budget> budgets;
  final String backupVersion;
  final DateTime backupDate;

  BackupData({
    required this.users,
    required this.expenses,
    required this.groups,
    required this.members,
    required this.splits,
    required this.settlements,
    required this.budgets,
    this.backupVersion = '1.0',
    DateTime? backupDate,
  }) : backupDate = backupDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'backup_version': backupVersion,
      'backup_date': backupDate.toIso8601String(),
      'users': users.map((u) => u.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'groups': groups.map((g) => g.toJson()).toList(),
      'members': members.map((m) => m.toJson()).toList(),
      'splits': splits.map((s) => s.toJson()).toList(),
      'settlements': settlements.map((s) => s.toJson()).toList(),
      'budgets': budgets.map((b) => b.toJson()).toList(),
    };
  }

  factory BackupData.fromJson(Map<String, dynamic> json) {
    return BackupData(
      backupVersion: json['backup_version'] as String? ?? '1.0',
      backupDate: json['backup_date'] != null
          ? DateTime.parse(json['backup_date'] as String)
          : DateTime.now(),
      users: (json['users'] as List<dynamic>?)
              ?.map((e) => User.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => ExpenseGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      splits: (json['splits'] as List<dynamic>?)
              ?.map((e) => GroupSplit.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      settlements: (json['settlements'] as List<dynamic>?)
              ?.map((e) => Settlement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      budgets: (json['budgets'] as List<dynamic>?)
              ?.map((e) => Budget.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class BackupManager {
  final DatabaseHelper _db = DatabaseHelper();

  /// Create a full backup of all data.
  Future<BackupData> createBackup() async {
    final users = (await _db.query('users'))
        .map((m) => User.fromMap(m))
        .toList();
    final expenses = (await _db.query('expenses'))
        .map((m) => Expense.fromMap(m))
        .toList();
    final groups = (await _db.query('expense_groups'))
        .map((m) => ExpenseGroup.fromMap(m))
        .toList();
    final members = (await _db.query('group_members'))
        .map((m) => GroupMember.fromMap(m))
        .toList();
    final splits = (await _db.query('group_splits'))
        .map((m) => GroupSplit.fromMap(m))
        .toList();
    final settlements = (await _db.query('settlements'))
        .map((m) => Settlement.fromMap(m))
        .toList();
    final budgets = (await _db.query('budgets'))
        .map((m) => Budget.fromMap(m))
        .toList();

    return BackupData(
      users: users,
      expenses: expenses,
      groups: groups,
      members: members,
      splits: splits,
      settlements: settlements,
      budgets: budgets,
    );
  }

  /// Export backup to JSON string.
  Future<String> exportToJson() async {
    final backup = await createBackup();
    return const JsonEncoder.withIndent('  ').convert(backup.toJson());
  }

  /// Save backup to file.
  Future<File> saveToFile(String filePath) async {
    final json = await exportToJson();
    return File(filePath).writeAsString(json);
  }

  /// Validate a backup JSON string before restoring.
  static BackupValidationResult validateBackup(String jsonString) {
    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Check required fields
      if (!json.containsKey('backup_version')) {
        return BackupValidationResult(
          isValid: false,
          error: 'Invalid backup file: missing backup_version',
        );
      }

      // Try parsing all entities
      final backup = BackupData.fromJson(json);

      return BackupValidationResult(
        isValid: true,
        backup: backup,
        stats: {
          'users': backup.users.length,
          'expenses': backup.expenses.length,
          'groups': backup.groups.length,
          'members': backup.members.length,
          'splits': backup.splits.length,
          'settlements': backup.settlements.length,
          'budgets': backup.budgets.length,
        },
      );
    } on FormatException {
      return BackupValidationResult(
        isValid: false,
        error: 'Invalid JSON format',
      );
    } catch (e) {
      return BackupValidationResult(
        isValid: false,
        error: 'Invalid backup file: ${e.toString()}',
      );
    }
  }

  /// Restore from backup data (replaces all existing data).
  Future<void> restoreFromBackup(BackupData backup) async {
    await _db.clearEverything();

    await _db.runTransaction((txn) async {
      for (final user in backup.users) {
        await txn.insert('users', user.toMap());
      }
      for (final group in backup.groups) {
        await txn.insert('expense_groups', group.toMap());
      }
      for (final member in backup.members) {
        await txn.insert('group_members', member.toMap());
      }
      for (final expense in backup.expenses) {
        await txn.insert('expenses', expense.toMap());
      }
      for (final split in backup.splits) {
        await txn.insert('group_splits', split.toMap());
      }
      for (final settlement in backup.settlements) {
        await txn.insert('settlements', settlement.toMap());
      }
      for (final budget in backup.budgets) {
        await txn.insert('budgets', budget.toMap());
      }
    });
  }

  /// Restore from JSON string.
  Future<void> restoreFromJson(String jsonString) async {
    final validation = validateBackup(jsonString);
    if (!validation.isValid) {
      throw Exception(validation.error);
    }
    await restoreFromBackup(validation.backup!);
  }
}

class BackupValidationResult {
  final bool isValid;
  final String? error;
  final BackupData? backup;
  final Map<String, int>? stats;

  BackupValidationResult({
    required this.isValid,
    this.error,
    this.backup,
    this.stats,
  });
}
