import 'package:flutter_test/flutter_test.dart';
import 'package:spendmate/utils/split_calculator.dart';

void main() {
  group('SplitCalculator', () {
    test('calculateEqualSplit divides total exactly and handles rounding', () {
      final splits = SplitCalculator.calculateEqualSplit(
        expenseId: 'e1',
        totalAmount: 100.0,
        memberUserIds: ['u1', 'u2', 'u3'],
      );

      expect(splits.length, 3);
      // 100 / 3 = 33.33...
      // Should be: 33.34, 33.33, 33.33 to sum to exactly 100
      expect(splits[0].shareAmount, 33.34);
      expect(splits[1].shareAmount, 33.33);
      expect(splits[2].shareAmount, 33.33);
      
      final total = splits.fold<double>(0.0, (sum, s) => sum + s.shareAmount);
      expect(total, 100.0);
    });

    test('calculateCustomSplit creates splits based on exact amounts', () {
      final splits = SplitCalculator.calculateCustomSplit(
        expenseId: 'e1',
        totalAmount: 500.0,
        memberShares: {
          'u1': 200.0,
          'u2': 300.0,
        },
      );

      expect(splits.length, 2);
      expect(splits.firstWhere((s) => s.userId == 'u1').shareAmount, 200.0);
      expect(splits.firstWhere((s) => s.userId == 'u2').shareAmount, 300.0);
    });

    test('calculatePercentageSplit calculates amounts based on percentages', () {
      final splits = SplitCalculator.calculatePercentageSplit(
        expenseId: 'e1',
        totalAmount: 1000.0,
        memberPercentages: {
          'u1': 60.0,
          'u2': 40.0,
        },
      );

      expect(splits.length, 2);
      expect(splits.firstWhere((s) => s.userId == 'u1').shareAmount, 600.0);
      expect(splits.firstWhere((s) => s.userId == 'u2').shareAmount, 400.0);
    });

    test('validateCustomSplit returns true if sums match', () {
      final isValid = SplitCalculator.validateCustomSplit(
        100.0,
        {'u1': 50.0, 'u2': 50.0},
      );
      expect(isValid, isTrue);
    });

    test('validateCustomSplit returns false if sums do not match', () {
      final isValid = SplitCalculator.validateCustomSplit(
        100.0,
        {'u1': 50.0, 'u2': 49.0},
      );
      expect(isValid, isFalse);
    });
  });
}
