// Statistics provider for charts and aggregations.

import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../repositories/expense_repository.dart';
import '../utils/date_formatter.dart';
import '../providers/settings_provider.dart';

class StatisticsProvider extends ChangeNotifier {
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final SettingsProvider _settingsProvider;

  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  // Stats data
  double _totalSpending = 0.0;
  int _transactionCount = 0;
  double _averageDaily = 0.0;
  double _highestExpense = 0.0;
  Map<String, double> _categoryTotals = {};
  Map<String, double> _paymentMethodTotals = {};
  List<MapEntry<String, double>> _topCategories = [];
  String _mostUsedMethod = '';

  DateTime get selectedMonth => _selectedMonth;
  bool get isLoading => _isLoading;

  double get totalSpending => _totalSpending;
  int get transactionCount => _transactionCount;
  double get averageDaily => _averageDaily;
  double get highestExpense => _highestExpense;
  Map<String, double> get categoryTotals => _categoryTotals;
  Map<String, double> get paymentMethodTotals => _paymentMethodTotals;
  List<MapEntry<String, double>> get topCategories => _topCategories;
  String get mostUsedMethod => _mostUsedMethod;

  StatisticsProvider(this._settingsProvider) {
    loadStatistics();
  }

  void setMonth(DateTime month) {
    _selectedMonth = month;
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    _isLoading = true;
    notifyListeners();

    final start = DateFormatter.startOfMonth(_selectedMonth);
    final end = DateFormatter.endOfMonth(_selectedMonth);
    final userId = _settingsProvider.currentUserId;

    // Get personal spending total (including user's share of group expenses)
    _totalSpending =
        await _expenseRepo.getPersonalSpendingTotal(start, end, userId);

    // To calculate other stats accurately, we need the expenses.
    // For simplicity in UI, we fetch personal expenses. For full accuracy, we'd fetch all and map shares.
    final expenses = await _expenseRepo.getExpensesByDateRange(start, end,
        personalOnly: true);

    _transactionCount = expenses.length;

    // Group expenses count could be added here if needed

    int daysInMonth;
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      daysInMonth = now.day; // Use days so far if current month
    } else {
      daysInMonth =
          DateFormatter.daysInMonth(_selectedMonth.year, _selectedMonth.month);
    }

    _averageDaily = daysInMonth > 0 ? _totalSpending / daysInMonth : 0;

    _highestExpense = 0.0;
    _categoryTotals = {};
    _paymentMethodTotals = {};

    for (final expense in expenses) {
      if (expense.amount > _highestExpense) {
        _highestExpense = expense.amount;
      }

      // Category totals
      _categoryTotals[expense.category] =
          (_categoryTotals[expense.category] ?? 0) + expense.amount;

      // Payment method totals
      _paymentMethodTotals[expense.paymentMethod] =
          (_paymentMethodTotals[expense.paymentMethod] ?? 0) + expense.amount;
    }

    // Top categories
    final sortedCategories = _categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    _topCategories = sortedCategories.take(3).toList();

    // Most used method
    if (_paymentMethodTotals.isNotEmpty) {
      final sortedMethods = _paymentMethodTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      _mostUsedMethod = sortedMethods.first.key;
    } else {
      _mostUsedMethod = 'None';
    }

    _isLoading = false;
    notifyListeners();
  }
}
