import 'package:flutter_test/flutter_test.dart';
import 'package:noor_fashion/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NoorApp());

    // Verify that the splash screen text is present
    expect(find.text('NOOR FASHION'), findsOneWidget);
  });
}
