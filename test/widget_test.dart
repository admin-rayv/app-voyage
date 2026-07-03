import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_voyage/config/routes.dart';
import 'package:app_voyage/main.dart';

void main() {
  setUpAll(() {
    // Pas de réseau dans les tests — les polices retombent sur le défaut.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App Voyage smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(AppVoyage(router: createAppRouter()));
    await tester.pump();

    // Verify that the app title is displayed.
    expect(find.text('App Voyage'), findsWidgets);
  });

  testWidgets('Onboarding: 4 pages, choix de langue, jusqu\'au bout',
      (tester) async {
    // La locale des tests est en_US → chaînes anglaises.
    await tester.pumpWidget(
      AppVoyage(router: createAppRouter(initialLocation: '/onboarding')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explore freely'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Turn on discovery mode'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    // Page de choix de langue (Sprint 8)
    expect(find.text("Marco's language"), findsOneWidget);
    expect(find.text('Français'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);

    // Choisir l'espagnol → persiste la préférence audio
    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('preferred_language'), 'es');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text("Let's go!"), findsOneWidget);
  });
}
