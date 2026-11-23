import 'package:flutter_test/flutter_test.dart';
import 'package:app_voyage/services/update_service.dart';

void main() {
  group('UpdateService.isNewer', () {
    test('version plus récente', () {
      expect(UpdateService.isNewer('0.7.5', 'v0.7.6'), isTrue);
      expect(UpdateService.isNewer('0.7.9', 'v0.8.0'), isTrue);
      expect(UpdateService.isNewer('0.7.10', 'v1.0.0'), isTrue);
      expect(UpdateService.isNewer('0.7.9', 'v0.7.10'), isTrue);
    });
    test('même version ou plus ancienne', () {
      expect(UpdateService.isNewer('0.7.6', 'v0.7.6'), isFalse);
      expect(UpdateService.isNewer('0.7.6', 'v0.7.5'), isFalse);
      expect(UpdateService.isNewer('0.8.0', 'v0.7.99'), isFalse);
    });
    test('suffixes et formats inattendus', () {
      expect(UpdateService.isNewer('0.7.6', 'v0.7.6-beta'), isFalse);
      expect(UpdateService.isNewer('0.7.6+10', '0.7.7'), isTrue);
      expect(UpdateService.isNewer('0.7.6', ''), isFalse);
      expect(UpdateService.isNewer('0.7.6', 'n\'importe quoi'), isFalse);
    });
  });
}
