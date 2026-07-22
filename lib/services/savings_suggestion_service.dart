// Savings suggestion service — rule-based engine for practical savings tips.
// Analyzes spending patterns and generates actionable suggestions.
// NEVER provides investment advice or guaranteed financial-return claims.

import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';
import '../models/savings_suggestion.dart';
import '../models/budget.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/recurring_expense_repository.dart';
import '../utils/date_formatter.dart';

class SavingsSuggestionService {
  final TransactionRepository _transactionRepo;
  final BudgetRepository _budgetRepo;
  final RecurringExpenseRepository _recurringRepo;
  static const _uuid = Uuid();

  SavingsSuggestionService({
    TransactionRepository? transactionRepo,
    BudgetRepository? budgetRepo,
    RecurringExpenseRepository? recurringRepo,
  })  : _transactionRepo = transactionRepo ?? TransactionRepository(),
        _budgetRepo = budgetRepo ?? BudgetRepository(),
        _recurringRepo = recurringRepo ?? RecurringExpenseRepository();

  /// Generate all applicable savings suggestions for the current month.
  Future<List<SavingsSuggestion>> generateSuggestions() async {
    final now = DateTime.now();
    final currentStart = DateFormatter.startOfMonth(now);
    final currentEnd = DateFormatter.endOfMonth(now);
    final prevMonth = DateTime(now.year, now.month - 1);
    final prevStart = DateFormatter.startOfMonth(prevMonth);
    final prevEnd = DateFormatter.endOfMonth(prevMonth);

    final List<SavingsSuggestion> suggestions = [];

    // ─── Rule 1: Category spending increased >20% vs last month ─────

    final currentCategoryTotals =
        await _transactionRepo.getCategoryTotals(currentStart, currentEnd);
    final prevCategoryTotals =
        await _transactionRepo.getCategoryTotals(prevStart, prevEnd);

    for (final entry in currentCategoryTotals.entries) {
      final prevAmount = prevCategoryTotals[entry.key] ?? 0;
      if (prevAmount > 0) {
        final increase = (entry.value - prevAmount) / prevAmount;
        if (increase > AppConstants.categoryIncreaseThreshold) {
          final savings = entry.value - prevAmount;
          suggestions.add(SavingsSuggestion(
            id: _uuid.v4(),
            reason:
                '${entry.key} spending increased by ${(increase * 100).toStringAsFixed(0)}% '
                'this month compared to last month.',
            estimatedSavings: savings,
            recommendedAction:
                'Try to reduce ${entry.key} spending back to last month\'s level '
                'of ₹${prevAmount.toStringAsFixed(0)}.',
            priority: increase > 0.5
                ? SuggestionPriority.high
                : SuggestionPriority.medium,
            category: entry.key,
          ));
        }
      }
    }

    // ─── Rule 2: No budget set for top spending categories ──────────

    final budget = await _budgetRepo.getBudgetForMonth(now.month, now.year);
    if (budget == null && currentCategoryTotals.isNotEmpty) {
      final topCategory = currentCategoryTotals.entries.first;
      suggestions.add(SavingsSuggestion(
        id: _uuid.v4(),
        reason: 'No monthly budget is set. Your top expense category is '
            '${topCategory.key} at ₹${topCategory.value.toStringAsFixed(0)}.',
        estimatedSavings: topCategory.value * 0.1, // Conservative 10% estimate
        recommendedAction:
            'Set a monthly budget to track and limit your spending.',
        priority: SuggestionPriority.high,
        category: topCategory.key,
      ));
    }

    // ─── Rule 3: Recurring subscriptions detected ───────────────────

    final recurring = await _recurringRepo.getActive();
    if (recurring.length >= 3) {
      final totalRecurring = recurring.fold(0.0, (sum, r) => sum + r.amount);
      suggestions.add(SavingsSuggestion(
        id: _uuid.v4(),
        reason: 'You have ${recurring.length} recurring expenses totaling '
            '₹${totalRecurring.toStringAsFixed(0)}/month.',
        estimatedSavings: totalRecurring * 0.15, // Assume 15% could be cut
        recommendedAction:
            'Review your recurring subscriptions and cancel any you no longer use.',
        priority: SuggestionPriority.medium,
      ));
    }

    // ─── Rule 4: Spending pace will exceed budget ───────────────────

    if (budget != null) {
      final currentSpending =
          await _transactionRepo.getExpenseTotal(currentStart, currentEnd);
      final daysPassed = now.day;
      final totalDays = DateFormatter.daysInMonth(now.year, now.month);
      final projectedSpending = (currentSpending / daysPassed) * totalDays;

      if (projectedSpending > budget.limitAmount) {
        final excess = projectedSpending - budget.limitAmount;
        suggestions.add(SavingsSuggestion(
          id: _uuid.v4(),
          reason:
              'At your current pace, you\'ll spend ₹${projectedSpending.toStringAsFixed(0)} '
              'this month, exceeding your budget of ₹${budget.limitAmount.toStringAsFixed(0)}.',
          estimatedSavings: excess,
          recommendedAction:
              'Reduce daily spending to ₹${((budget.limitAmount - currentSpending) / (totalDays - daysPassed)).toStringAsFixed(0)} '
              'for the remaining ${totalDays - daysPassed} days.',
          priority: SuggestionPriority.high,
        ));
      }
    }

    // ─── Rule 5: Unused budget with few days left ───────────────────

    if (budget != null &&
        now.day >= DateFormatter.daysInMonth(now.year, now.month) - 5) {
      final currentSpending =
          await _transactionRepo.getExpenseTotal(currentStart, currentEnd);
      final remaining = budget.limitAmount - currentSpending;
      if (remaining > 0) {
        suggestions.add(SavingsSuggestion(
          id: _uuid.v4(),
          reason:
              'You have ₹${remaining.toStringAsFixed(0)} remaining in your budget with '
              '${DateFormatter.daysInMonth(now.year, now.month) - now.day} days left.',
          estimatedSavings: remaining,
          recommendedAction:
              'Consider moving ₹${remaining.toStringAsFixed(0)} into savings before the month ends.',
          priority: SuggestionPriority.low,
        ));
      }
    }

    // ─── Rule 6: Weekend spending >40% of weekly total ──────────────

    final weekStart = DateFormatter.startOfWeek(now);
    final weekEnd = DateFormatter.endOfWeek(now);
    final weekTransactions = await _transactionRepo
        .getByDateRange(weekStart, weekEnd, type: 'expense');

    double weekdayTotal = 0;
    double weekendTotal = 0;
    for (final tx in weekTransactions) {
      if (tx.date.weekday == DateTime.saturday ||
          tx.date.weekday == DateTime.sunday) {
        weekendTotal += tx.amount;
      } else {
        weekdayTotal += tx.amount;
      }
    }

    final weekTotal = weekdayTotal + weekendTotal;
    if (weekTotal > 0 &&
        weekendTotal / weekTotal > AppConstants.weekendSpendingThreshold) {
      suggestions.add(SavingsSuggestion(
        id: _uuid.v4(),
        reason:
            'Weekend spending accounts for ${(weekendTotal / weekTotal * 100).toStringAsFixed(0)}% '
            'of your weekly expenses (₹${weekendTotal.toStringAsFixed(0)} of ₹${weekTotal.toStringAsFixed(0)}).',
        estimatedSavings: weekendTotal * 0.25, // Suggest reducing by 25%
        recommendedAction:
            'Set a weekend spending limit to control discretionary expenses.',
        priority: SuggestionPriority.medium,
      ));
    }

    // Sort by priority (high first)
    suggestions.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return suggestions;
  }

  /// Get the total potential monthly savings across all suggestions.
  double totalPotentialSavings(List<SavingsSuggestion> suggestions) {
    return suggestions
        .where((s) => !s.isActioned)
        .fold(0.0, (sum, s) => sum + s.estimatedSavings);
  }
}
