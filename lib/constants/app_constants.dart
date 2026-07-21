// App constants: categories, payment methods, split types, budget thresholds,
// transaction types, and financial dashboard configuration.

class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'SpendMate';
  static const String appVersion = '2.0.0';
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

  // Income categories
  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Interest',
    'Refund',
    'Gift',
    'Other Income',
  ];

  // Payment methods (original 3 kept at top for backward compatibility)
  static const List<String> paymentMethods = [
    'Cash',
    'UPI',
    'Card',
    'UPI - Google Pay',
    'UPI - PhonePe',
    'UPI - Paytm',
    'Net Banking',
    'Bank Transfer',
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

  // Analytics periods
  static const String periodDaily = 'Daily';
  static const String periodWeekly = 'Weekly';
  static const String periodMonthly = 'Monthly';

  // Transaction types
  static const String txTypeIncome = 'income';
  static const String txTypeExpense = 'expense';
  static const String txTypeTransfer = 'transfer';

  // Transaction sources
  static const String txSourceManual = 'manual';
  static const String txSourceSms = 'sms';
  static const String txSourceImport = 'import';
  static const String txSourceBankSync = 'bankSync';
  static const String txSourceUpiIntent = 'upi_intent';

  // Recurring expense detection thresholds
  static const double recurringAmountTolerance = 0.05; // ±5%
  static const int recurringMinOccurrences = 2;

  // Anomaly detection: flag transactions > 2x category average
  static const double anomalyMultiplier = 2.0;

  // Savings suggestion thresholds
  static const double categoryIncreaseThreshold = 0.20; // 20% increase triggers suggestion
  static const double weekendSpendingThreshold = 0.40; // 40% of weekly total

  // Database
  static const String dbName = 'spendmate.db';
  static const int dbVersion = 3;

  // Rounding tolerance for settlements
  static const double settlementTolerance = 0.01;
}
