import 'package:flutter/material.dart';
import '../models/spending_insight.dart';
import '../models/recurring_expense.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _isLoading = false;
  AnalyticsResult? _currentMonthStats;
  List<SpendingInsight> _insights = [];
  List<SpendingInsight> _anomalies = [];
  List<RecurringExpense> _recurringExpenses = [];
  DateTime _selectedMonth = DateTime.now();

  bool get isLoading => _isLoading;
  AnalyticsResult? get currentMonthStats => _currentMonthStats;
  List<SpendingInsight> get insights => _insights;
  List<SpendingInsight> get anomalies => _anomalies;
  List<RecurringExpense> get recurringExpenses => _recurringExpenses;
  DateTime get selectedMonth => _selectedMonth;

  AnalyticsProvider() {
    loadAnalytics();
  }

  void setMonth(DateTime month) {
    _selectedMonth = month;
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentMonthStats = await _analyticsService.computeMonthlyStats(_selectedMonth);
      _insights = await _analyticsService.generateInsights(_selectedMonth);
      _anomalies = await _analyticsService.detectAnomalies(_selectedMonth);
      
      // Load recurring expenses only for the current month
      if (_selectedMonth.year == DateTime.now().year && _selectedMonth.month == DateTime.now().month) {
        _recurringExpenses = await _analyticsService.detectRecurringExpenses();
      }
    } catch (e) {
      debugPrint('Error loading analytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
