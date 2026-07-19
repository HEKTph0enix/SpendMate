// Budget provider managing monthly budget limits and tracking usage.

import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../repositories/budget_repository.dart';
import '../repositories/expense_repository.dart';
import '../utils/date_formatter.dart';
import '../constants/app_constants.dart';
import '../providers/settings_provider.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetRepository _budgetRepo = BudgetRepository();
  final ExpenseRepository _expenseRepo = ExpenseRepository();
  final SettingsProvider _settingsProvider;

  Budget? _currentBudget;
  double _currentUsage = 0.0;
  bool _isLoading = false;

  Budget? get currentBudget => _currentBudget;
  double get currentUsage => _currentUsage;
  bool get isLoading => _isLoading;

  bool get hasBudget => _currentBudget != null;
  double get limitAmount => _currentBudget?.limitAmount ?? 0.0;
  double get remainingAmount => limitAmount - _currentUsage > 0 ? limitAmount - _currentUsage : 0.0;
  
  double get usagePercentage {
    if (!hasBudget || limitAmount == 0) return 0.0;
    return _currentUsage / limitAmount;
  }

  bool get isSafe => usagePercentage < AppConstants.budgetSafeThreshold;
  bool get isWarning => usagePercentage >= AppConstants.budgetSafeThreshold && usagePercentage < AppConstants.budgetWarningThreshold;
  bool get isOverBudget => usagePercentage >= AppConstants.budgetWarningThreshold;

  BudgetProvider(this._settingsProvider) {
    loadCurrentBudget();
  }

  Future<void> loadCurrentBudget() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    _currentBudget = await _budgetRepo.getBudgetForMonth(now.month, now.year);

    if (_currentBudget != null) {
      final start = DateFormatter.startOfMonth(now);
      final end = DateFormatter.endOfMonth(now);
      _currentUsage = await _expenseRepo.getPersonalSpendingTotal(start, end, _settingsProvider.currentUserId);
    } else {
      _currentUsage = 0.0;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setBudget(double amount) async {
    final now = DateTime.now();
    await _budgetRepo.setOrUpdateBudget(now.month, now.year, amount);
    await loadCurrentBudget();
  }
}
