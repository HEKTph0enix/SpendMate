// App constants: categories, payment methods, split types, budget thresholds.

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'SpendMate';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Offline-first personal expense tracker and group expense splitter for Indian users.';

  // Currency
  static const String defaultCurrency = 'INR';
  static const String currencySymbol = '₹';

  // Categories
  static const List<String> categories = [
    'Food',
    'Travel',
    'Rent',
    'Shopping',
    'Bills',
    'Entertainment',
    'Education',
    'Health',
    'Groceries',
    'Other',
  ];

  // Payment methods
  static const List<String> paymentMethods = [
    'Cash',
    'UPI',
    'Card',
  ];

  // Split types
  static const String splitEqual = 'equal';
  static const String splitCustom = 'custom';
  static const String splitPercentage = 'percentage';

  static const List<String> splitTypes = [
    splitEqual,
    splitCustom,
    splitPercentage,
  ];

  // Budget thresholds
  static const double budgetSafeThreshold = 0.70;
  static const double budgetWarningThreshold = 0.90;

  // Filter periods
  static const String filterToday = 'Today';
  static const String filterWeek = 'Week';
  static const String filterMonth = 'Month';

  // Database
  static const String dbName = 'spendmate.db';
  static const int dbVersion = 1;

  // Rounding tolerance for settlements
  static const double settlementTolerance = 0.01;
}
