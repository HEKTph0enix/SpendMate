// Indian currency formatting with lakh/crore grouping (₹1,25,000).

class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format amount in Indian currency style.
  /// Examples: ₹1,250  ₹12,500  ₹1,25,000  ₹333.33
  /// Does not show unnecessary decimals.
  static String format(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    // Check if we need decimals
    final hasDecimals = (absAmount * 100).round() % 100 != 0;

    String formatted;
    if (hasDecimals) {
      formatted = _formatWithDecimals(absAmount);
    } else {
      formatted = _formatWithoutDecimals(absAmount.round());
    }

    return isNegative ? '-₹$formatted' : '₹$formatted';
  }

  /// Format without the currency symbol (for input fields etc.)
  static String formatWithoutSymbol(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();

    final hasDecimals = (absAmount * 100).round() % 100 != 0;

    String formatted;
    if (hasDecimals) {
      formatted = _formatWithDecimals(absAmount);
    } else {
      formatted = _formatWithoutDecimals(absAmount.round());
    }

    return isNegative ? '-$formatted' : formatted;
  }

  static String _formatWithDecimals(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = _formatIndianGrouping(int.parse(parts[0]));
    return '$intPart.${parts[1]}';
  }

  static String _formatWithoutDecimals(int amount) {
    return _formatIndianGrouping(amount);
  }

  /// Apply Indian number grouping: first 3 digits from right, then groups of 2.
  /// 1234567 → 12,34,567
  static String _formatIndianGrouping(int number) {
    if (number < 1000) return number.toString();

    final str = number.toString();
    final len = str.length;

    // Last 3 digits
    final lastThree = str.substring(len - 3);
    final remaining = str.substring(0, len - 3);

    if (remaining.isEmpty) return lastThree;

    // Group remaining digits in pairs from right
    final buffer = StringBuffer();
    for (int i = 0; i < remaining.length; i++) {
      if (i > 0 && (remaining.length - i) % 2 == 0) {
        buffer.write(',');
      }
      buffer.write(remaining[i]);
    }
    buffer.write(',');
    buffer.write(lastThree);

    return buffer.toString();
  }

  /// Format a compact version for large amounts.
  static String formatCompact(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return format(amount);
  }

  /// Parse an Indian-formatted string back to double.
  static double? parse(String text) {
    try {
      final cleaned = text
          .replaceAll('₹', '')
          .replaceAll(',', '')
          .replaceAll(' ', '')
          .trim();
      if (cleaned.isEmpty) return null;
      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }
}
