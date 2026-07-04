import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_voyage/services/favorite_poi_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('FavoritePoiService — toggle bascule et persiste', () async {
    SharedPreferences.setMockInitialValues({});
    final service = FavoritePoiService();
    await service.init();

    expect(service.isFavorite('poi-1'), isFalse);

    expect(await service.toggle('poi-1'), isTrue);
    expect(service.isFavorite('poi-1'), isTrue);
    expect(service.count, 1);

    // Persisté dans SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('favorite_poi_ids'), ['poi-1']);

    expect(await service.toggle('poi-1'), isFalse);
    expect(service.isFavorite('poi-1'), isFalse);
    expect(prefs.getStringList('favorite_poi_ids'), isEmpty);
  });
}
