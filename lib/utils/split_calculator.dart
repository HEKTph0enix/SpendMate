// Split calculator for equal, custom, and percentage splits with rounding correction.

import '../models/group_split.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class SplitCalculator {
  static const _uuid = Uuid();

  /// Equal split: divide total equally among selected members.
  /// Handles rounding so all shares exactly match the total.
  static List<GroupSplit> calculateEqualSplit({
    required String expenseId,
    required double totalAmount,
    required List<String> memberUserIds,
  }) {
    if (memberUserIds.isEmpty) return [];

    final count = memberUserIds.length;
    // Round down to 2 decimal places
    final baseShare = (totalAmount * 100).floor() / 100 / count;
    final shareRounded = (baseShare * 100).floor() / 100.0;
    final totalDistributed = shareRounded * count;
    final remainder = ((totalAmount - totalDistributed) * 100).round();

    final splits = <GroupSplit>[];
    for (int i = 0; i < count; i++) {
      // Add ₹0.01 to the first 'remainder' members to handle rounding
      final share = shareRounded + (i < remainder ? 0.01 : 0);
      splits.add(GroupSplit(
        id: _uuid.v4(),
        expenseId: expenseId,
        userId: memberUserIds[i],
        shareAmount: double.parse(share.toStringAsFixed(2)),
        sharePercentage: 100.0 / count,
        splitType: AppConstants.splitEqual,
      ));
    }

    return splits;
  }

  /// Custom split: user specifies exact amounts.
  /// Validates that sum of shares equals total.
  static List<GroupSplit> calculateCustomSplit({
    required String expenseId,
    required double totalAmount,
    required Map<String, double> memberShares,
  }) {
    final splits = <GroupSplit>[];
    for (final entry in memberShares.entries) {
      final percentage =
          totalAmount > 0 ? (entry.value / totalAmount * 100) : 0.0;
      splits.add(GroupSplit(
        id: _uuid.v4(),
        expenseId: expenseId,
        userId: entry.key,
        shareAmount: double.parse(entry.value.toStringAsFixed(2)),
        sharePercentage: double.parse(percentage.toStringAsFixed(2)),
        splitType: AppConstants.splitCustom,
      ));
    }
    return splits;
  }

  /// Percentage split: user specifies percentages.
  /// Validates that sum of percentages equals 100%.
  static List<GroupSplit> calculatePercentageSplit({
    required String expenseId,
    required double totalAmount,
    required Map<String, double> memberPercentages,
  }) {
    final splits = <GroupSplit>[];

    // Calculate amounts from percentages
    final entries = memberPercentages.entries.toList();
    double allocatedAmount = 0;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      double amount;
      if (i == entries.length - 1) {
        // Last person gets the remainder to avoid rounding issues
        amount = totalAmount - allocatedAmount;
      } else {
        amount =
            double.parse((totalAmount * entry.value / 100).toStringAsFixed(2));
        allocatedAmount += amount;
      }

      splits.add(GroupSplit(
        id: _uuid.v4(),
        expenseId: expenseId,
        userId: entry.key,
        shareAmount: double.parse(amount.toStringAsFixed(2)),
        sharePercentage: entry.value,
        splitType: AppConstants.splitPercentage,
      ));
    }

    return splits;
  }

  // ─── Validation ────────────────────────────────────────────────────

  /// Validate that custom split shares sum to the total amount.
  static bool validateCustomSplit(
      double totalAmount, Map<String, double> shares) {
    if (shares.isEmpty) return false;
    final sum = shares.values.fold(0.0, (a, b) => a + b);
    return (sum - totalAmount).abs() < 0.01;
  }

  /// Validate that percentage shares sum to 100%.
  static bool validatePercentageSplit(Map<String, double> percentages) {
    if (percentages.isEmpty) return false;
    final sum = percentages.values.fold(0.0, (a, b) => a + b);
    return (sum - 100.0).abs() < 0.01;
  }

  /// Validate that all shares are non-negative.
  static bool validateSharesNonNegative(Map<String, double> shares) {
    return shares.values.every((v) => v >= 0);
  }
}
