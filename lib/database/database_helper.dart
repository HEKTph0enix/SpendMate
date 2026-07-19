// SQLite database helper with all table definitions, CRUD operations, and transaction support.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // ─── V1 Tables (original) ───────────────────────────────────────

    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        is_current_user INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        date_time TEXT NOT NULL,
        category TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        note TEXT,
        is_group_expense INTEGER NOT NULL DEFAULT 0,
        group_id TEXT,
        payer_user_id TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES expense_groups (id) ON DELETE SET NULL,
        FOREIGN KEY (payer_user_id) REFERENCES users (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expense_groups (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_date TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE group_members (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        joined_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES expense_groups (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE group_splits (
        id TEXT PRIMARY KEY,
        expense_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        share_amount REAL NOT NULL,
        share_percentage REAL,
        split_type TEXT NOT NULL,
        FOREIGN KEY (expense_id) REFERENCES expenses (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE settlements (
        id TEXT PRIMARY KEY,
        group_id TEXT NOT NULL,
        paid_by_user_id TEXT NOT NULL,
        paid_to_user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        date_time TEXT NOT NULL,
        note TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (group_id) REFERENCES expense_groups (id) ON DELETE CASCADE,
        FOREIGN KEY (paid_by_user_id) REFERENCES users (id) ON DELETE CASCADE,
        FOREIGN KEY (paid_to_user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        limit_amount REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // V1 indexes
    await db.execute('CREATE INDEX idx_expenses_date ON expenses (date_time)');
    await db.execute('CREATE INDEX idx_expenses_category ON expenses (category)');
    await db.execute('CREATE INDEX idx_expenses_group ON expenses (group_id)');
    await db.execute('CREATE INDEX idx_group_members_group ON group_members (group_id)');
    await db.execute('CREATE INDEX idx_group_splits_expense ON group_splits (expense_id)');
    await db.execute('CREATE INDEX idx_settlements_group ON settlements (group_id)');
    await db.execute('CREATE UNIQUE INDEX idx_budgets_month_year ON budgets (month, year)');

    // ─── V2 Tables (financial dashboard) ────────────────────────────

    await _createV2Tables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createV2Tables(db);
    }
  }

  Future<void> _createV2Tables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS financial_accounts (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        bank_name TEXT,
        masked_account_number TEXT,
        balance REAL NOT NULL DEFAULT 0,
        last_synced_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cash_wallet (
        id TEXT PRIMARY KEY,
        balance REAL NOT NULL DEFAULT 0,
        last_updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        source TEXT NOT NULL DEFAULT 'manual',
        date TEXT NOT NULL,
        note TEXT,
        account_id TEXT,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (account_id) REFERENCES financial_accounts (id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS recurring_expenses (
        id TEXT PRIMARY KEY,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        frequency TEXT NOT NULL DEFAULT 'monthly',
        last_occurrence TEXT,
        next_expected TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // V2 indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_date ON transactions (date)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_account ON transactions (account_id)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_category ON transactions (category)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions (type)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_financial_accounts_active ON financial_accounts (is_active)');
  }

  // ─── Generic CRUD ──────────────────────────────────────────────────

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  // ─── Transaction Support ───────────────────────────────────────────

  Future<T> runTransaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  // ─── Batch insert for splits ───────────────────────────────────────

  Future<void> insertGroupExpenseWithSplits(
    Map<String, dynamic> expense,
    List<Map<String, dynamic>> splits,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('expenses', expense, conflictAlgorithm: ConflictAlgorithm.replace);
      for (final split in splits) {
        await txn.insert('group_splits', split, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  // ─── Bulk insert for imported transactions ─────────────────────────

  Future<void> insertBulkTransactions(List<Map<String, dynamic>> transactions) async {
    final db = await database;
    await db.transaction((txn) async {
      for (final tx in transactions) {
        await txn.insert('transactions', tx, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  // ─── Clear all data (original) ────────────────────────────────────

  Future<void> clearAllData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('group_splits');
      await txn.delete('settlements');
      await txn.delete('group_members');
      await txn.delete('expenses');
      await txn.delete('expense_groups');
      await txn.delete('budgets');
      // Keep current user, delete others
      await txn.delete('users', where: 'is_current_user = ?', whereArgs: [0]);
    });
  }

  // ─── Clear financial data only (new) ──────────────────────────────

  Future<void> clearFinancialData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('transactions');
      await txn.delete('recurring_expenses');
      await txn.delete('financial_accounts');
      await txn.delete('cash_wallet');
    });
  }

  // ─── Full clear including user ─────────────────────────────────────

  Future<void> clearEverything() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('group_splits');
      await txn.delete('settlements');
      await txn.delete('group_members');
      await txn.delete('expenses');
      await txn.delete('expense_groups');
      await txn.delete('budgets');
      await txn.delete('transactions');
      await txn.delete('recurring_expenses');
      await txn.delete('financial_accounts');
      await txn.delete('cash_wallet');
      await txn.delete('users');
    });
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

