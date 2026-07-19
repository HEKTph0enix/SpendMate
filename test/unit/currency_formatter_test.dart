import 'package:flutter_test/flutter_test.dart';
import 'package:spendmate/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats hundreds correctly', () {
      expect(CurrencyFormatter.format(500), '₹500');
    });

    test('formats thousands with single comma', () {
      expect(CurrencyFormatter.format(1250), '₹1,250');
      expect(CurrencyFormatter.format(12500), '₹12,500');
    });

    test('formats lakhs with Indian grouping', () {
      expect(CurrencyFormatter.format(125000), '₹1,25,000');
      expect(CurrencyFormatter.format(1250000), '₹12,50,000');
    });

    test('formats crores with Indian grouping', () {
      expect(CurrencyFormatter.format(12500000), '₹1,25,00,000');
    });

    test('handles decimals correctly', () {
      expect(CurrencyFormatter.format(333.33), '₹333.33');
      expect(CurrencyFormatter.format(1250.50), '₹1,250.50');
    });

    test('ignores unnecessary decimals', () {
      expect(CurrencyFormatter.format(500.0), '₹500');
    });
    
    test('formats negative numbers correctly', () {
      expect(CurrencyFormatter.format(-1250), '-₹1,250');
    });

    test('parses formatted strings correctly', () {
      expect(CurrencyFormatter.parse('₹1,25,000'), 125000.0);
      expect(CurrencyFormatter.parse(' 1,250.50 '), 1250.50);
      expect(CurrencyFormatter.parse('invalid'), null);
    });
  });
}
