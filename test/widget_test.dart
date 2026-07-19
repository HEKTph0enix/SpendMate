import 'package:flutter_test/flutter_test.dart';
import 'package:spendmate/app.dart';

void main() {
  testWidgets('SpendMate app launches successfully',
          (WidgetTester tester) async {
        await tester.pumpWidget(const SpendMateApp());

        // Wait for the app UI to finish loading.
        await tester.pumpAndSettle();

        // Confirm that the main app widget exists.
        expect(find.byType(SpendMateApp), findsOneWidget);
      });
}