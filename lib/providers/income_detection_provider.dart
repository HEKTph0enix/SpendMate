import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/detected_transaction.dart';
import '../repositories/detected_transaction_repository.dart';
import '../services/notification_parser_service.dart';

class IncomeDetectionProvider extends ChangeNotifier {
  static const MethodChannel _methodChannel = MethodChannel('spendmate.notification.methods');
  static const EventChannel _eventChannel = EventChannel('spendmate.notification.events');

  final DetectedTransactionRepository _repo = DetectedTransactionRepository();
  final NotificationParserService _parser = NotificationParserService();

  List<DetectedTransaction> _pendingTransactions = [];
  bool _isNotificationAccessEnabled = false;

  List<DetectedTransaction> get pendingTransactions => _pendingTransactions;
  bool get isNotificationAccessEnabled => _isNotificationAccessEnabled;

  IncomeDetectionProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      await checkNotificationPermission();
      await _loadPendingFromAndroid();
      await refreshPendingTransactions();

      _eventChannel.receiveBroadcastStream().listen(
        (event) {
          if (event is Map) {
            _handleNewNotification(Map<String, dynamic>.from(event));
          }
        },
        onError: (error) {
          debugPrint('EventChannel stream error: $error');
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint('IncomeDetectionProvider init failed (non-fatal): $e');
    }
  }

  Future<void> checkNotificationPermission() async {
    try {
      final bool isEnabled = await _methodChannel.invokeMethod('isNotificationListenerEnabled');
      _isNotificationAccessEnabled = isEnabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
    }
  }

  Future<void> openNotificationSettings() async {
    try {
      await _methodChannel.invokeMethod('openNotificationListenerSettings');
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  Future<void> _loadPendingFromAndroid() async {
    try {
      final String jsonStr = await _methodChannel.invokeMethod('getPendingNotifications');
      final List<dynamic> jsonList = jsonDecode(jsonStr);

      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          await _handleNewNotification(item);
        }
      }

      // Clear from Android side once loaded
      await _methodChannel.invokeMethod('clearPendingNotifications');
    } catch (e) {
      debugPrint('Error loading pending notifications: $e');
    }
  }

  Future<void> _handleNewNotification(Map<String, dynamic> data) async {
    try {
      final String packageName = data['packageName'] ?? '';
      final String title = data['title'] ?? '';
      final String text = data['text'] ?? '';
      final String notificationId = data['notificationId'] ?? '';
      final int timestampMs = data['timestamp'] ?? DateTime.now().millisecondsSinceEpoch;
      final DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMs);

      final detected = _parser.parseNotification(
        packageName: packageName,
        title: title,
        text: text,
        timestamp: timestamp,
        notificationId: notificationId,
      );

      if (detected != null) {
        // Check for duplicates
        final isDuplicate = await _repo.isDuplicate(detected.fingerprint, detected.timestamp);
        if (!isDuplicate) {
          await _repo.insertTransaction(detected);
          await refreshPendingTransactions();
        }
      }
    } catch (e) {
      debugPrint('Error handling new notification: $e');
    }
  }

  Future<void> refreshPendingTransactions() async {
    try {
      _pendingTransactions = await _repo.getPendingTransactions();
    } catch (e) {
      debugPrint('Error refreshing pending transactions: $e');
      _pendingTransactions = [];
    }
    notifyListeners();
  }

  Future<void> markAsConfirmed(String id) async {
    await _repo.updateStatus(id, DetectionStatus.confirmed);
    await refreshPendingTransactions();
  }

  Future<void> markAsIgnored(String id) async {
    await _repo.updateStatus(id, DetectionStatus.ignored);
    await refreshPendingTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.deleteTransaction(id);
    await refreshPendingTransactions();
  }

  Future<void> clearAllHistory() async {
    await _repo.clearAll();
    await refreshPendingTransactions();
  }
}
