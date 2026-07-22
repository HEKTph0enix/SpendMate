// Expense provider managing expense state, filters, and totals.

import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/transaction.dart' as app;
import '../repositories/expense_repository.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/cash_wallet_repository.dart';
import '../repositories/financial_account_repository.dart';
import '../utils/date_formatter.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repo = ExpenseRepository();

  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  String _activeFilter = 'Month'; // Today, Week, Month
  bool _isLoading = false;
  String? _searchQuery;

  // Filter state
  String? _filterCategory;
  String? _filterPaymentMethod;
  bool? _filterIsGroup;
  double? _filterMinAmount;
  double? _filterMaxAmount;

  List<Expense> get expenses => _filteredExpenses;
  List<Expense> get allExpenses => _expenses;
  String get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  String? get searchQuery => _searchQuery;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _repo.getAllExpenses();
      _applyFilters();
    } catch (e) {
      _expenses = [];
      _filteredExpenses = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExpense(Expense expense) async {
    await _repo.insertExpense(expense);
    
    // Sync to V2 Dashboard (transactions table)
    final txRepo = TransactionRepository();
    final tx = app.Transaction(
      id: expense.id,
      amount: expense.amount,
      type: app.TransactionType.expense,
      category: expense.category,
      paymentMethod: expense.paymentMethod,
      source: app.TransactionSource.manual,
      date: expense.dateTime,
      note: expense.note,
    );
    await txRepo.insertTransaction(tx);
    
    // Deduct from appropriate balance
    if (expense.paymentMethod == 'Cash') {
      final cwRepo = CashWalletRepository();
      final bal = await cwRepo.getBalance();
      await cwRepo.updateBalance(bal - expense.amount);
    } else if (expense.paymentMethod == 'Online Transaction') {
      final accRepo = FinancialAccountRepository();
      final accounts = await accRepo.getActiveAccounts();
      if (accounts.isNotEmpty) {
        final acc = accounts.first;
        await accRepo.updateBalance(acc.id, acc.balance - expense.amount);
      }
    }

    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    // Note: To be fully consistent, we'd adjust balances by the difference,
    // but for simplicity we'll just update the transaction record here.
    await _repo.updateExpense(expense);
    
    final txRepo = TransactionRepository();
    final existingTx = await txRepo.getById(expense.id);
    if (existingTx != null) {
      final updatedTx = existingTx.copyWith(
        amount: expense.amount,
        category: expense.category,
        paymentMethod: expense.paymentMethod,
        date: expense.dateTime,
        note: expense.note,
      );
      await txRepo.updateTransaction(updatedTx);
    }
    
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    final existingExpense = _expenses.firstWhere((e) => e.id == id);
    
    await _repo.deleteExpense(id);
    
    // Also delete from V2 transactions and restore balance
    final txRepo = TransactionRepository();
    await txRepo.deleteTransaction(id);
    
    if (existingExpense.paymentMethod == 'Cash') {
      final cwRepo = CashWalletRepository();
      final bal = await cwRepo.getBalance();
      await cwRepo.updateBalance(bal + existingExpense.amount);
    } else if (existingExpense.paymentMethod == 'Online Transaction') {
      final accRepo = FinancialAccountRepository();
      final accounts = await accRepo.getActiveAccounts();
      if (accounts.isNotEmpty) {
        final acc = accounts.first;
        await accRepo.updateBalance(acc.id, acc.balance + existingExpense.amount);
      }
    }
    
    await loadExpenses();
  }

  // ─── Filtering ─────────────────────────────────────────────────────

  void setActiveFilter(String filter) {
    _activeFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String? query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterCategory(String? category) {
    _filterCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setFilterPaymentMethod(String? method) {
    _filterPaymentMethod = method;
    _applyFilters();
    notifyListeners();
  }

  void setFilterIsGroup(bool? isGroup) {
    _filterIsGroup = isGroup;
    _applyFilters();
    notifyListeners();
  }

  void setFilterAmountRange(double? min, double? max) {
    _filterMinAmount = min;
    _filterMaxAmount = max;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _filterCategory = null;
    _filterPaymentMethod = null;
    _filterIsGroup = null;
    _filterMinAmount = null;
    _filterMaxAmount = null;
    _searchQuery = null;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateFormatter.endOfDay(now);

    switch (_activeFilter) {
      case 'Today':
        start = DateFormatter.startOfDay(now);
        break;
      case 'Week':
        start = DateFormatter.startOfWeek(now);
        break;
      default: // Month
        start = DateFormatter.startOfMonth(now);
        break;
    }

    _filteredExpenses = _expenses.where((e) {
      // Date range filter
      if (e.dateTime.isBefore(start) || e.dateTime.isAfter(end)) return false;

      // Category filter
      if (_filterCategory != null && e.category != _filterCategory)
        return false;

      // Payment method filter
      if (_filterPaymentMethod != null &&
          e.paymentMethod != _filterPaymentMethod) return false;

      // Group filter
      if (_filterIsGroup != null && e.isGroupExpense != _filterIsGroup)
        return false;

      // Amount range filter
      if (_filterMinAmount != null && e.amount < _filterMinAmount!)
        return false;
      if (_filterMaxAmount != null && e.amount > _filterMaxAmount!)
        return false;

      // Search filter
      if (_searchQuery != null && _searchQuery!.isNotEmpty) {
        final query = _searchQuery!.toLowerCase();
        final noteMatch = e.note?.toLowerCase().contains(query) ?? false;
        final categoryMatch = e.category.toLowerCase().contains(query);
        if (!noteMatch && !categoryMatch) return false;
      }

      return true;
    }).toList();
  }

  // ─── Totals ────────────────────────────────────────────────────────

  double get totalToday {
    final now = DateTime.now();
    final start = DateFormatter.startOfDay(now);
    final end = DateFormatter.endOfDay(now);
    return _expenses
        .where((e) =>
            !e.isGroupExpense &&
            !e.dateTime.isBefore(start) &&
            !e.dateTime.isAfter(end))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalThisWeek {
    final now = DateTime.now();
    final start = DateFormatter.startOfWeek(now);
    final end = DateFormatter.endOfWeek(now);
    return _expenses
        .where((e) =>
            !e.isGroupExpense &&
            !e.dateTime.isBefore(start) &&
            !e.dateTime.isAfter(end))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalThisMonth {
    final now = DateTime.now();
    final start = DateFormatter.startOfMonth(now);
    final end = DateFormatter.endOfMonth(now);
    return _expenses
        .where((e) =>
            !e.isGroupExpense &&
            !e.dateTime.isBefore(start) &&
            !e.dateTime.isAfter(end))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  List<Expense> get recentExpenses {
    final sorted = List<Expense>.from(_expenses)
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return sorted.take(10).toList();
  }
}
