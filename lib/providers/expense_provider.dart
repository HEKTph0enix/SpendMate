// Expense provider managing expense state, filters, and totals.

import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
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
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repo.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(String id) async {
    await _repo.deleteExpense(id);
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
      if (_filterCategory != null && e.category != _filterCategory) return false;

      // Payment method filter
      if (_filterPaymentMethod != null && e.paymentMethod != _filterPaymentMethod) return false;

      // Group filter
      if (_filterIsGroup != null && e.isGroupExpense != _filterIsGroup) return false;

      // Amount range filter
      if (_filterMinAmount != null && e.amount < _filterMinAmount!) return false;
      if (_filterMaxAmount != null && e.amount > _filterMaxAmount!) return false;

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
