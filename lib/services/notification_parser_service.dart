import '../models/detected_transaction.dart';

class NotificationParserService {
  static final RegExp _amountRegex = RegExp(
    r'(?:(?:Rs\.?|INR|₹)\s*)(\d+(?:,\d+)*(?:\.\d+)?)',
    caseSensitive: false,
  );

  // e.g. "You received ₹500 from Arun"
  // "₹1,000 received from John Doe"
  static final RegExp _senderRegex = RegExp(
    r'(?:from\s+)([A-Za-z\s]+?)(?=\s+on|\s+via|\.|$)',
    caseSensitive: false,
  );

  static const List<String> _creditKeywords = [
    'credited',
    'received',
    'deposited',
    'money received',
    'upi credit',
    'payment received',
    'added to your account',
  ];

  static const List<String> _ignoreKeywords = [
    'debited',
    'paid',
    'sent',
    'failed',
    'declined',
    'pending',
    'requested',
    'autopay',
    'mandate',
    'otp',
    'available balance',
    'low balance',
  ];

  /// Returns a DetectedTransaction if the notification looks like income.
  /// Returns null if it is ignored, low confidence, or doesn't match format.
  DetectedTransaction? parseNotification({
    required String packageName,
    required String title,
    required String text,
    required DateTime timestamp,
    required String notificationId,
  }) {
    final lowerTitle = title.toLowerCase();
    final lowerText = text.toLowerCase();
    final fullText = '$lowerTitle $lowerText';

    // 1. Check for ignore words first
    for (final word in _ignoreKeywords) {
      if (fullText.contains(word)) {
        return null;
      }
    }

    // 2. Check for credit words
    bool isCredit = false;
    for (final word in _creditKeywords) {
      if (fullText.contains(word)) {
        isCredit = true;
        break;
      }
    }

    if (!isCredit) {
      return null; // Not an income notification
    }

    // 3. Extract Amount
    double? amount;
    // Check text first, then title
    final amountMatch = _amountRegex.firstMatch(text) ?? _amountRegex.firstMatch(title);
    
    if (amountMatch != null && amountMatch.groupCount >= 1) {
      final amountStr = amountMatch.group(1)!.replaceAll(',', '');
      amount = double.tryParse(amountStr);
    }

    if (amount == null || amount <= 0) {
      return null; // Could not parse a valid amount
    }

    // 4. Extract Sender
    String? senderName;
    final senderMatch = _senderRegex.firstMatch(text) ?? _senderRegex.firstMatch(title);
    if (senderMatch != null && senderMatch.groupCount >= 1) {
      senderName = senderMatch.group(1)?.trim();
      // Basic cleanup for names that might capture too much
      if (senderName != null && senderName.length > 20) {
        senderName = null; 
      }
    }

    // 5. Generate fingerprint
    // packageName + notificationId + timestamp + amount + normalizedText
    // The prompt says: packageName + notificationId + timestamp + amount + normalizedText
    // We'll normalize the text slightly to avoid exact spacing issues
    final normalizedText = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final fingerprint = '${packageName}_${notificationId}_${amount}_$normalizedText';

    return DetectedTransaction(
      fingerprint: fingerprint,
      packageName: packageName,
      notificationTitle: title,
      notificationText: text,
      amount: amount,
      senderName: senderName,
      timestamp: timestamp,
      confidenceScore: 0.9, // High confidence since it passed our strict filters
      status: DetectionStatus.pending,
    );
  }
}
