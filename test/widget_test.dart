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

    // Verify that the app title is displayed.
    expect(find.text('App Voyage'), findsWidgets);
  });

  testWidgets('Onboarding s\'affiche au premier lancement', (tester) async {
    await tester.pumpWidget(
      AppVoyage(router: createAppRouter(initialLocation: '/onboarding')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Explore librement'), findsOneWidget);
    expect(find.text('Passer'), findsOneWidget);

    // Naviguer jusqu'au dernier écran
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Suivant'));
    await tester.pumpAndSettle();
    expect(find.text('C’est parti !'), findsOneWidget);
  });
}
