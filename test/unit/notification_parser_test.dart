import 'package:flutter_test/flutter_test.dart';
import 'package:spendmate/services/notification_parser_service.dart';

void main() {
  late NotificationParserService parser;

  setUp(() {
    parser = NotificationParserService();
  });

  group('NotificationParserService - Credit parsing', () {
    test('Parses standard UPI credit with ₹ symbol', () {
      final tx = parser.parseNotification(
        packageName: 'com.google.android.apps.nbu.paisa.user',
        title: 'Payment Received',
        text: '₹1,000 credited to your account through UPI',
        timestamp: DateTime.now(),
        notificationId: '123',
      );
      
      expect(tx, isNotNull);
      expect(tx!.amount, 1000.0);
    });

    test('Parses credit with Rs symbol', () {
      final tx = parser.parseNotification(
        packageName: 'com.phonepe.app',
        title: 'Money Received',
        text: 'Rs. 500.50 credited to A/C XX1234',
        timestamp: DateTime.now(),
        notificationId: '124',
      );
      
      expect(tx, isNotNull);
      expect(tx!.amount, 500.50);
    });

    test('Parses credit with INR', () {
      final tx = parser.parseNotification(
        packageName: 'net.one97.paytm',
        title: 'Deposit Successful',
        text: 'INR 2,500 has been deposited to your account',
        timestamp: DateTime.now(),
        notificationId: '125',
      );
      
      expect(tx, isNotNull);
      expect(tx!.amount, 2500.0);
    });

    test('Extracts sender name correctly', () {
      final tx = parser.parseNotification(
        packageName: 'com.google.android.apps.nbu.paisa.user',
        title: 'Google Pay',
        text: 'You received ₹500 from Arun via UPI',
        timestamp: DateTime.now(),
        notificationId: '126',
      );
      
      expect(tx, isNotNull);
      expect(tx!.amount, 500.0);
      expect(tx.senderName, 'Arun');
    });
  });

  group('NotificationParserService - Debit and ignores', () {
    test('Ignores debit notifications', () {
      final tx = parser.parseNotification(
        packageName: 'com.google.android.apps.nbu.paisa.user',
        title: 'Payment Sent',
        text: '₹1,000 debited from your account',
        timestamp: DateTime.now(),
        notificationId: '223',
      );
      
      expect(tx, isNull);
    });

    test('Ignores OTP notifications', () {
      final tx = parser.parseNotification(
        packageName: 'com.bank.app',
        title: 'OTP for transaction',
        text: 'Your OTP for payment of ₹1,000 is 123456',
        timestamp: DateTime.now(),
        notificationId: '224',
      );
      
      expect(tx, isNull);
    });

    test('Ignores requests for money', () {
      final tx = parser.parseNotification(
        packageName: 'com.google.android.apps.nbu.paisa.user',
        title: 'Money Requested',
        text: 'Arun requested ₹500 from you',
        timestamp: DateTime.now(),
        notificationId: '225',
      );
      
      expect(tx, isNull);
    });
  });
}
