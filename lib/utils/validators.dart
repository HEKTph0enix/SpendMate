// Validation utilities for form fields, splits, and data integrity.

class Validators {
  Validators._();

  /// Validate that a string is not null or empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate that amount is a positive number.
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final cleaned = value.replaceAll(',', '').replaceAll('₹', '').trim();
    final parsed = double.tryParse(cleaned);
    if (parsed == null) {
      return 'Enter a valid amount';
    }
    if (parsed <= 0) {
      return 'Amount must be greater than zero';
    }
    return null;
  }

  /// Parse amount from string, handling commas and currency symbol.
  static double? parseAmount(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.replaceAll(',', '').replaceAll('₹', '').trim();
    return double.tryParse(cleaned);
  }

  /// Validate custom split: sum must equal total.
  static String? customSplit(double total, Map<String, double> shares) {
    if (shares.isEmpty) {
      return 'At least one member must be included';
    }
    final sum = shares.values.fold(0.0, (a, b) => a + b);
    if ((sum - total).abs() > 0.01) {
      return 'Shares must add up to the total amount (₹${total.toStringAsFixed(2)})';
    }
    if (shares.values.any((v) => v < 0)) {
      return 'Share amounts cannot be negative';
    }
    return null;
  }

  /// Validate percentage split: sum must equal 100%.
  static String? percentageSplit(Map<String, double> percentages) {
    if (percentages.isEmpty) {
      return 'At least one member must be included';
    }
    final sum = percentages.values.fold(0.0, (a, b) => a + b);
    if ((sum - 100.0).abs() > 0.01) {
      return 'Percentages must add up to 100%';
    }
    if (percentages.values.any((v) => v < 0)) {
      return 'Percentages cannot be negative';
    }
    return null;
  }

  /// Validate minimum number of members.
  static String? minimumMembers(List<String> members, {int minimum = 2}) {
    if (members.length < minimum) {
      return 'At least $minimum members are required';
    }
    return null;
  }

  /// Check for duplicate members.
  static String? duplicateMembers(List<String> memberNames) {
    final seen = <String>{};
    for (final name in memberNames) {
      if (!seen.add(name.trim().toLowerCase())) {
        return 'Duplicate member: $name';
      }
    }
    return null;
  }

  /// Validate group name.
  static String? groupName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Group name is required';
    }
    if (value.trim().length < 2) {
      return 'Group name must be at least 2 characters';
    }
    return null;
  }

  /// Validate user name.
  static String? userName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}
