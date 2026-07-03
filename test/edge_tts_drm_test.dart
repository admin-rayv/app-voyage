import 'package:flutter_test/flutter_test.dart';

import 'package:app_voyage/services/edge_tts_service_io.dart';

void main() {
  group('EdgeTtsDrm.secMsGec', () {
    // Vecteurs générés avec la librairie de référence edge-tts (Python,
    // v7.2.8) — même horodatage → même jeton, sinon l'API répond 403.
    const vectors = {
      1783116000:
          '98F50C4045FB5AA8F7A78C8CD8366D6852A79B01450FB81C0380DB3906A37A95',
      // Même fenêtre de 5 minutes → même jeton.
      1783116299:
          '98F50C4045FB5AA8F7A78C8CD8366D6852A79B01450FB81C0380DB3906A37A95',
      1700000000:
          '42301B335578FEFDAE2637DED1ABD614505D432559EC08032B82048483726AFF',
      2000000123:
          'A95FBFCC5170170E85C8DC08D889767D47AB0748B99F053B554E071E208F86BA',
    };

    setUp(() => EdgeTtsDrm.clockSkewSeconds = 0);

    test('reproduit exactement les jetons de la librairie de référence', () {
      vectors.forEach((unixSeconds, expected) {
        expect(
          EdgeTtsDrm.secMsGec(unixSeconds: unixSeconds),
          expected,
          reason: 'timestamp $unixSeconds',
        );
      });
    });

    test('le décalage d\'horloge corrige le timestamp', () {
      EdgeTtsDrm.clockSkewSeconds = 299;
      // 1783116000 + 299 reste dans la même fenêtre de 5 min.
      expect(
        EdgeTtsDrm.secMsGec(unixSeconds: 1783116000),
        vectors[1783116000],
      );
      EdgeTtsDrm.clockSkewSeconds = 300;
      // +300 change de fenêtre → jeton différent.
      expect(
        EdgeTtsDrm.secMsGec(unixSeconds: 1783116000),
        isNot(vectors[1783116000]),
      );
    });
  });
}
