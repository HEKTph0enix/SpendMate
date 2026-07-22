// SMS transaction parser for Indian bank SMS formats.
// Parses debit/credit messages from major banks (SBI, HDFC, ICICI, Axis, etc.)
// and UPI app references (Google Pay, PhonePe, Paytm).
//
// IMPORTANT: Requires explicit user permission before reading SMS.
// Never auto-reads SMS without consent.

import 'package:uuid/uuid.dart';
import '../models/transaction.dart' as app;

class SmsTransactionParser {
  static const _uuid = Uuid();

  // Common Indian bank SMS patterns
  static final List<RegExp> _debitPatterns = [
    // "Rs.500.00 debited from A/c XXXX1234"
    RegExp(r'Rs\.?\s?(\d+[\d,]*\.?\d*)\s*(?:has been\s+)?debited',
        caseSensitive: false),
    // "INR 500.00 withdrawn"
    RegExp(r'INR\s?(\d+[\d,]*\.?\d*)\s*(?:has been\s+)?(?:withdrawn|debited)',
        caseSensitive: false),
    // "Spent Rs 500"
    RegExp(r'(?:Spent|spent)\s+Rs\.?\s?(\d+[\d,]*\.?\d*)',
        caseSensitive: false),
    // "Txn of Rs 500.00"
    RegExp(r'(?:Txn|txn|transaction)\s+of\s+Rs\.?\s?(\d+[\d,]*\.?\d*)',
        caseSensitive: false),
  ];

  static final List<RegExp> _creditPatterns = [
    // "Rs.500.00 credited to A/c XXXX1234"
    RegExp(r'Rs\.?\s?(\d+[\d,]*\.?\d*)\s*(?:has been\s+)?credited',
        caseSensitive: false),
    // "INR 500.00 deposited"
    RegExp(
        r'INR\s?(\d+[\d,]*\.?\d*)\s*(?:has been\s+)?(?:deposited|credited|received)',
        caseSensitive: false),
    // "Received Rs 500"
    RegExp(r'(?:Received|received)\s+Rs\.?\s?(\d+[\d,]*\.?\d*)',
        caseSensitive: false),
  ];

  // Account number patterns
  static final RegExp _accountPattern = RegExp(
    r'(?:A/c|a/c|Acct|acct|account)\s*(?:no\.?\s*)?(?:XX+)?(\d{4})',
    caseSensitive: false,
  );

  // UPI reference patterns
  static final RegExp _upiPattern = RegExp(
    r'(?:UPI|upi)(?:\s*[-:]?\s*)?(?:Ref\.?\s*(?:No\.?\s*)?)?(\d+)?',
    caseSensitive: false,
  );

  // UPI app detection
  static final Map<RegExp, String> _upiAppPatterns = {
    RegExp(r'(?:Google\s*Pay|GPay|GOOGLEPAY)', caseSensitive: false):
        'UPI - Google Pay',
    RegExp(r'(?:PhonePe|PHONEPE)', caseSensitive: false): 'UPI - PhonePe',
    RegExp(r'(?:Paytm|PAYTM)', caseSensitive: false): 'UPI - Paytm',
  };

  // Bank name detection
  static final Map<RegExp, String> _bankPatterns = {
    RegExp(r'SBI|State Bank', caseSensitive: false): 'SBI',
    RegExp(r'HDFC', caseSensitive: false): 'HDFC Bank',
    RegExp(r'ICICI', caseSensitive: false): 'ICICI Bank',
    RegExp(r'Axis', caseSensitive: false): 'Axis Bank',
    RegExp(r'Kotak', caseSensitive: false): 'Kotak Bank',
    RegExp(r'PNB|Punjab National', caseSensitive: false): 'PNB',
    RegExp(r'BOB|Bank of Baroda', caseSensitive: false): 'Bank of Baroda',
    RegExp(r'Canara', caseSensitive: false): 'Canara Bank',
    RegExp(r'Union Bank', caseSensitive: false): 'Union Bank',
    RegExp(r'IndusInd', caseSensitive: false): 'IndusInd Bank',
    RegExp(r'Yes Bank', caseSensitive: false): 'Yes Bank',
    RegExp(r'IDBI', caseSensitive: false): 'IDBI Bank',
    RegExp(r'Federal Bank', caseSensitive: false): 'Federal Bank',
  };

  /// Parse a list of SMS messages into transactions.
  /// Each SMS should have a body and a date.
  List<app.Transaction> parseMessages(List<SmsMessage> messages) {
    final List<app.Transaction> transactions = [];

    for (final sms in messages) {
      final parsed = parseSingleMessage(sms.body, sms.date);
      if (parsed != null) {
        transactions.add(parsed);
      }
    }

    return transactions;
  }

  /// Parse a single SMS body into a transaction, or null if not a bank message.
  app.Transaction? parseSingleMessage(String body, DateTime date) {
    // Try debit patterns first
    for (final pattern in _debitPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final amount = _parseAmount(match.group(1) ?? '');
        if (amount != null && amount > 0) {
          return _buildTransaction(
            body: body,
            amount: amount,
            type: app.TransactionType.expense,
            date: date,
          );
        }
      }
    }

    // Try credit patterns
    for (final pattern in _creditPatterns) {
      final match = pattern.firstMatch(body);
      if (match != null) {
        final amount = _parseAmount(match.group(1) ?? '');
        if (amount != null && amount > 0) {
          return _buildTransaction(
            body: body,
            amount: amount,
            type: app.TransactionType.income,
            date: date,
          );
        }
      }
    }

    return null; // Not a recognized bank SMS
  }

  app.Transaction _buildTransaction({
    required String body,
    required double amount,
    required app.TransactionType type,
    required DateTime date,
  }) {
    return app.Transaction(
      id: _uuid.v4(),
      amount: amount,
      type: type,
      category: type == app.TransactionType.income ? 'Other Income' : 'Other',
      paymentMethod: _detectPaymentMethod(body),
      source: app.TransactionSource.sms,
      date: date,
      note: _truncateNote(body),
    );
  }

  String _detectPaymentMethod(String body) {
    // Check for specific UPI apps first
    for (final entry in _upiAppPatterns.entries) {
      if (entry.key.hasMatch(body)) return entry.value;
    }
    // Generic UPI detection
    if (_upiPattern.hasMatch(body)) return 'UPI';
    // Check for card
    if (RegExp(r'(?:card|debit\s*card|credit\s*card)', caseSensitive: false)
        .hasMatch(body)) {
      return 'Card';
    }
    // Check for net banking
    if (RegExp(r'(?:net\s*banking|NEFT|RTGS|IMPS)', caseSensitive: false)
        .hasMatch(body)) {
      return 'Net Banking';
    }
    return 'Bank Transfer';
  }

  /// Extract bank name from SMS body.
  String? detectBankName(String body) {
    for (final entry in _bankPatterns.entries) {
      if (entry.key.hasMatch(body)) return entry.value;
    }
    return null;
  }

  /// Extract masked account number from SMS body.
  String? extractAccountNumber(String body) {
    final match = _accountPattern.firstMatch(body);
    if (match != null) {
      final last4 = match.group(1);
      if (last4 != null) return 'XXXX-XXXX-$last4';
    }
    return null;
  }

  double? _parseAmount(String raw) {
    try {
      // Remove commas and extra spaces
      final cleaned = raw.replaceAll(',', '').trim();
      return double.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  String _truncateNote(String body) {
    if (body.length <= 100) return body;
    return '${body.substring(0, 97)}...';
  }
}

/// Simple SMS message data class for the parser.
class SmsMessage {
  final String body;
  final DateTime date;
  final String? sender;

  SmsMessage({
    required this.body,
    required this.date,
    this.sender,
  });
}
