// Analytics service — computes spending statistics, trends, recurring expenses, and anomalies.

import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../models/spending_insight.dart';
import '../models/recurring_expense.dart';
import '../models/transaction.dart' as app;
import '../repositories/transaction_repository.dart';
import '../repositories/recurring_expense_repository.dart';
import '../utils/date_formatter.dart';

class AnalyticsService {
  final TransactionRepository _transactionRepo;
  final RecurringExpenseRepository _recurringRepo;
  static const _uuid = Uuid();

  AnalyticsService({
    TransactionRepository? transactionRepo,
    RecurringExpenseRepository? recurringRepo,
  })  : _transactionRepo = transactionRepo ?? TransactionRepository(),
        _recurringRepo = recurringRepo ?? RecurringExpenseRepository();

  // ─── Core Statistics ──────────────────────────────────────────────

  Future<AnalyticsResult> computeMonthlyStats(DateTime month) async {
    final start = DateFormatter.startOfMonth(month);
    final end = DateFormatter.endOfMonth(month);

    final totalExpense = await _transactionRepo.getExpenseTotal(start, end);
    final totalIncome = await _transactionRepo.getIncomeTotal(start, end);
    final categoryTotals = await _transactionRepo.getCategoryTotals(start, end);
    final paymentMethodTotals = await _transactionRepo.getPaymentMethodTotals(start, end);
    final transactionCount = await _transactionRepo.getTransactionCount(start, end);
    final highestExpense = await _transactionRepo.getHighestTransaction(start, end);
    final dailyTotals = await _transactionRepo.getDailyTotals(start, end);

    // Average daily expense
    final now = DateTime.now();
    int daysCount;
    if (month.year == now.year && month.month == now.month) {
      daysCount = now.day;
    } else {
      daysCount = DateFormatter.daysInMonth(month.year, month.month);
    }
    final averageDaily = daysCount > 0 ? totalExpense / daysCount : 0.0;

    // Highest spending category
    String? highestCategory;
    if (categoryTotals.isNotEmpty) {
      highestCategory = categoryTotals.entries.first.key; // Already sorted DESC
    }

    return AnalyticsResult(
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      categoryTotals: categoryTotals,
      paymentMethodTotals: paymentMethodTotals,
      transactionCount: transactionCount,
      highestExpense: highestExpense,
      averageDaily: averageDaily,
      highestCategory: highestCategory,
      dailyTotals: dailyTotals,
    );
  }

  // ─── Period Comparison ────────────────────────────────────────────

  Future<List<SpendingInsight>> generateInsights(DateTime month) async {
    final current = await computeMonthlyStats(month);
    final prevMonth = DateTime(month.year, month.month - 1);
    final previous = await computeMonthlyStats(prevMonth);

    final List<SpendingInsight> insights = [];

    // Overall spending trend
    if (previous.totalExpense > 0) {
      final change = ((current.totalExpense - previous.totalExpense) / previous.totalExpense) * 100;
      insights.add(SpendingInsight(
        id: _uuid.v4(),
        type: InsightType.trend,
        title: 'Monthly Spending Trend',
        description: change >= 0
            ? 'Spending increased by ${change.abs().toStringAsFixed(1)}% compared to last month.'
            : 'Spending decreased by ${change.abs().toStringAsFixed(1)}% compared to last month.',
        value: current.totalExpense,
        previousValue: previous.totalExpense,
        changePercent: change,
        period: 'Monthly',
      ));
    }

    // Category-wise comparison
    for (final entry in current.categoryTotals.entries) {
      final prevAmount = previous.categoryTotals[entry.key] ?? 0;
      if (prevAmount > 0) {
        final change = ((entry.value - prevAmount) / prevAmount) * 100;
        if (change > 20) {
          insights.add(SpendingInsight(
            id: _uuid.v4(),
            type: InsightType.comparison,
            title: '${entry.key} spending increased',
            description: '${entry.key} spending rose by ${change.toStringAsFixed(0)}% '
                'from ₹${prevAmount.toStringAsFixed(0)} to ₹${entry.value.toStringAsFixed(0)}.',
            value: entry.value,
            previousValue: prevAmount,
            changePercent: change,
            period: 'Monthly',
          ));
        }
      }
    }

    return insights;
  }

  // ─── Recurring Expense Detection ──────────────────────────────────

  Future<List<RecurringExpense>> detectRecurringExpenses() async {
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
    final transactions = await _transactionRepo.getByDateRange(
      threeMonthsAgo,
      DateTime.now(),
      type: 'expense',
    );

    // Group by category + approximate amount
    final Map<String, List<app.Transaction>> groups = {};
    for (final tx in transactions) {
      // Key by category + rounded amount (to within tolerance)
      final amountBucket = (tx.amount / 10).round() * 10;
      final key = '${tx.category}_$amountBucket';
      groups.putIfAbsent(key, () => []).add(tx);
    }

    final List<RecurringExpense> recurring = [];
    for (final entry in groups.entries) {
      final txList = entry.value;
      if (txList.length >= AppConstants.recurringMinOccurrences) {
        // Check if amounts are within tolerance
        final avgAmount = txList.fold(0.0, (sum, tx) => sum + tx.amount) / txList.length;
        final withinTolerance = txList.every((tx) =>
            (tx.amount - avgAmount).abs() / avgAmount <= AppConstants.recurringAmountTolerance);

        if (withinTolerance || txList.length >= 3) {
          final sorted = List<app.Transaction>.from(txList)
            ..sort((a, b) => b.date.compareTo(a.date));

          recurring.add(RecurringExpense(
            id: _uuid.v4(),
            description: sorted.first.note ?? sorted.first.category,
            amount: avgAmount,
            category: sorted.first.category,
            frequency: _detectFrequency(sorted),
            lastOccurrence: sorted.first.date,
            nextExpected: _estimateNextOccurrence(sorted),
          ));
        }
      }
    }

    // Save detected recurring expenses
    for (final rec in recurring) {
      await _recurringRepo.insert(rec);
    }

    return recurring;
  }

  RecurrenceFrequency _detectFrequency(List<app.Transaction> sorted) {
    if (sorted.length < 2) return RecurrenceFrequency.monthly;

    final gaps = <int>[];
    for (int i = 0; i < sorted.length - 1; i++) {
      gaps.add(sorted[i].date.difference(sorted[i + 1].date).inDays);
    }
    final avgGap = gaps.fold(0, (sum, g) => sum + g) / gaps.length;

    if (avgGap <= 2) return RecurrenceFrequency.daily;
    if (avgGap <= 10) return RecurrenceFrequency.weekly;
    if (avgGap <= 45) return RecurrenceFrequency.monthly;
    return RecurrenceFrequency.yearly;
  }

  DateTime? _estimateNextOccurrence(List<app.Transaction> sorted) {
    if (sorted.length < 2) return null;
    final gap = sorted[0].date.difference(sorted[1].date);
    return sorted[0].date.add(gap);
  }

  // ─── Anomaly Detection ────────────────────────────────────────────

  Future<List<SpendingInsight>> detectAnomalies(DateTime month) async {
    final start = DateFormatter.startOfMonth(month);
    final end = DateFormatter.endOfMonth(month);

    final transactions = await _transactionRepo.getByDateRange(start, end, type: 'expense');
    final categoryTotals = await _transactionRepo.getCategoryTotals(start, end);

    // Calculate category averages
    final Map<String, double> categoryAverages = {};
    final Map<String, int> categoryCounts = {};
    for (final tx in transactions) {
      categoryCounts[tx.category] = (categoryCounts[tx.category] ?? 0) + 1;
    }
    for (final entry in categoryTotals.entries) {
      final count = categoryCounts[entry.key] ?? 1;
      categoryAverages[entry.key] = entry.value / count;
    }

    // Find anomalous transactions
    final List<SpendingInsight> anomalies = [];
    for (final tx in transactions) {
      final avg = categoryAverages[tx.category] ?? 0;
      if (avg > 0 && tx.amount > avg * AppConstants.anomalyMultiplier) {
        anomalies.add(SpendingInsight(
          id: _uuid.v4(),
          type: InsightType.highValue,
          title: 'High ${tx.category} expense',
          description: '₹${tx.amount.toStringAsFixed(0)} is ${(tx.amount / avg).toStringAsFixed(1)}× '
              'the average ${tx.category} expense of ₹${avg.toStringAsFixed(0)}.',
          value: tx.amount,
          previousValue: avg,
          changePercent: ((tx.amount - avg) / avg) * 100,
          period: 'Transaction',
        ));
      }
    }

    return anomalies;
  }
}

/// Result container for monthly analytics computation.
class AnalyticsResult {
  final double totalExpense;
  final double totalIncome;
  final Map<String, double> categoryTotals;
  final Map<String, double> paymentMethodTotals;
  final int transactionCount;
  final double highestExpense;
  final double averageDaily;
  final String? highestCategory;
  final Map<DateTime, double> dailyTotals;

  AnalyticsResult({
    this.totalExpense = 0,
    this.totalIncome = 0,
    this.categoryTotals = const {},
    this.paymentMethodTotals = const {},
    this.transactionCount = 0,
    this.highestExpense = 0,
    this.averageDaily = 0,
    this.highestCategory,
    this.dailyTotals = const {},
  });

  double get saved => totalIncome - totalExpense;
}
