import 'package:flutter_test/flutter_test.dart';
import 'package:app_voyage/main.dart';

void main() {
  testWidgets('App Voyage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AppVoyage());

    // Verify that the app title is displayed.
    expect(find.text('App Voyage'), findsWidgets);
  });
}
