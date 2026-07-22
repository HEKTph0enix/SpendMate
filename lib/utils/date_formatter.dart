// Date formatting utilities with relative dates and Indian formatting.

import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _fullFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final _dateOnly = DateFormat('dd MMM yyyy');
  static final _shortDate = DateFormat('dd MMM');
  static final _timeOnly = DateFormat('hh:mm a');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _shortMonthYear = DateFormat('MMM yyyy');

  static String formatFull(DateTime date) => _fullFormat.format(date);

  static String formatDateOnly(DateTime date) => _dateOnly.format(date);

  static String formatShort(DateTime date) => _shortDate.format(date);

  static String formatTime(DateTime date) => _timeOnly.format(date);

  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  static String formatShortMonthYear(DateTime date) =>
      _shortMonthYear.format(date);

  /// Returns relative date string: "Today", "Yesterday", or formatted date.
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '${diff} days ago';

    return formatDateOnly(date);
  }

  /// Returns date with time for expense cards.
  static String formatExpenseDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Today, ${formatTime(date)}';
    if (diff == 1) return 'Yesterday, ${formatTime(date)}';

    return formatFull(date);
  }

  // ─── Date Range Helpers ────────────────────────────────────────────

  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    // Week starts on Monday
    final weekday = date.weekday; // Monday = 1, Sunday = 7
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  static DateTime endOfWeek(DateTime date) {
    final weekday = date.weekday;
    return endOfDay(date.add(Duration(days: 7 - weekday)));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  static int daysSoFarInMonth(DateTime date) {
    return date.day;
  }
}
