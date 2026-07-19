import 'package:flutter_test/flutter_test.dart';
import 'package:spendmate/utils/settlement_algorithm.dart';

void main() {
  group('SettlementAlgorithm', () {
    test('calculateMinimumSettlements resolves simple triangle debt', () {
      // A owes B 100
      // B owes C 100
      // C owes A 100
      // Net balances: A: 0, B: 0, C: 0
      final balances = {
        'A': 0.0,
        'B': 0.0,
        'C': 0.0,
      };

      final settlements = SettlementAlgorithm.calculateMinimumSettlements(balances);
      expect(settlements, isEmpty);
    });

    test('calculateMinimumSettlements minimizes transactions', () {
      // A pays 300 for A, B, C
      // Balances: A: +200, B: -100, C: -100
      // Expected: B pays A 100, C pays A 100
      final balances = {
        'A': 200.0,
        'B': -100.0,
        'C': -100.0,
      };

      final settlements = SettlementAlgorithm.calculateMinimumSettlements(balances);
      expect(settlements.length, 2);
      
      final toA = settlements.where((s) => s.toUserId == 'A').toList();
      expect(toA.length, 2);
      expect(toA.map((s) => s.amount).reduce((a, b) => a + b), 200.0);
    });

    test('isGroupSettled returns true for zero balances', () {
      final balances = {
        'A': 0.001,
        'B': -0.001,
      };
      
      expect(SettlementAlgorithm.isGroupSettled(balances), isTrue);
    });
    
    test('isGroupSettled returns false for non-zero balances', () {
      final balances = {
        'A': 50.0,
        'B': -50.0,
      };
      
      expect(SettlementAlgorithm.isGroupSettled(balances), isFalse);
    });
  });
}
