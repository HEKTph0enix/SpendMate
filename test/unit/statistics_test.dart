import 'package:flutter_test/flutter_test.dart';
import 'package:spendmate/utils/date_formatter.dart';

void main() {
  group('Statistics Logic', () {
    test('Date range helpers work correctly', () {
      final date = DateTime(2023, 5, 15, 14, 30); // May 15, 2023, 14:30
      
      final start = DateFormatter.startOfMonth(date);
      expect(start.year, 2023);
      expect(start.month, 5);
      expect(start.day, 1);
      
      final end = DateFormatter.endOfMonth(date);
      expect(end.year, 2023);
      expect(end.month, 5);
      expect(end.day, 31); // May has 31 days
      expect(end.hour, 23);
      expect(end.minute, 59);
      
      expect(DateFormatter.daysInMonth(2023, 2), 28); // Feb 2023
      expect(DateFormatter.daysInMonth(2024, 2), 29); // Feb 2024 (Leap year)
    });
  });
}
