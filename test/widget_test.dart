import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spendmate/app.dart';

void main() {
  setUpAll(() {
    // Initialize SQLite for Flutter widget tests.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets(
    'SpendMate app launches successfully',
        (WidgetTester tester) async {
      await tester.pumpWidget(const SpendMateApp());

      // Allow the app and database operations to initialize.
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      // Confirm that the main app widget exists.
      expect(find.byType(SpendMateApp), findsOneWidget);
    },
  );
}