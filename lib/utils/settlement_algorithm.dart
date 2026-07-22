// Settlement algorithm that minimizes the number of payments to settle group balances.

import '../constants/app_constants.dart';

class SettlementSuggestion {
  final String fromUserId;
  final String toUserId;
  final double amount;

  SettlementSuggestion({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  @override
  String toString() =>
      'SettlementSuggestion($fromUserId pays $toUserId: $amount)';
}

class SettlementAlgorithm {
  /// Calculate minimum number of transactions to settle all balances.
  ///
  /// Logic:
  /// 1. Calculate each member's net balance.
  /// 2. Separate creditors (positive balance) and debtors (negative balance).
  /// 3. Match the largest debtor with the largest creditor.
  /// 4. Transfer the smaller of the two absolute amounts.
  /// 5. Update balances.
  /// 6. Repeat until all balances are within tolerance.
  static List<SettlementSuggestion> calculateMinimumSettlements(
    Map<String, double> balances,
  ) {
    final suggestions = <SettlementSuggestion>[];
    final tolerance = AppConstants.settlementTolerance;

    // Create mutable copy
    final Map<String, double> remaining = Map.from(balances);

    // Remove zero-balance members
    remaining.removeWhere((_, v) => v.abs() < tolerance);

    while (remaining.isNotEmpty) {
      // Separate into debtors (negative) and creditors (positive)
      final debtors = <String, double>{};
      final creditors = <String, double>{};

      for (final entry in remaining.entries) {
        if (entry.value < -tolerance) {
          debtors[entry.key] = entry.value;
        } else if (entry.value > tolerance) {
          creditors[entry.key] = entry.value;
        }
      }

      if (debtors.isEmpty || creditors.isEmpty) break;

      // Find largest debtor (most negative) and largest creditor (most positive)
      String largestDebtor =
          debtors.entries.reduce((a, b) => a.value < b.value ? a : b).key;
      String largestCreditor =
          creditors.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final debtAmount = remaining[largestDebtor]!.abs();
      final creditAmount = remaining[largestCreditor]!;
      final transferAmount =
          debtAmount < creditAmount ? debtAmount : creditAmount;

      // Round to 2 decimal places
      final roundedAmount = double.parse(transferAmount.toStringAsFixed(2));

      if (roundedAmount > tolerance) {
        suggestions.add(SettlementSuggestion(
          fromUserId: largestDebtor,
          toUserId: largestCreditor,
          amount: roundedAmount,
        ));
      }

      // Update balances
      remaining[largestDebtor] = remaining[largestDebtor]! + roundedAmount;
      remaining[largestCreditor] = remaining[largestCreditor]! - roundedAmount;

      // Remove settled members
      remaining.removeWhere((_, v) => v.abs() < tolerance);
    }

    return suggestions;
  }

  /// Check if all members in a group are settled.
  static bool isGroupSettled(Map<String, double> balances) {
    return balances.values
        .every((v) => v.abs() < AppConstants.settlementTolerance);
  }
}
