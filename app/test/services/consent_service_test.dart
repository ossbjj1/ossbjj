import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oss/core/services/consent_service.dart';

void main() {
  group('ConsentService', () {
    late ConsentService service;

    setUp(() {
      service = ConsentService();
    });

    test('load returns defaults when no data stored', () async {
      SharedPreferences.setMockInitialValues({});
      final state = await service.load();
      expect(state.analytics, false);
      expect(state.media, false);
      expect(state.shown, false);
    });

    test('setAnalytics persists value', () async {
      SharedPreferences.setMockInitialValues({});
      await service.load();
      await service.setAnalytics(true);
      expect(service.analytics, true);

      // Verify persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('consent.analytics'), true);
    });

    test('setMedia persists value', () async {
      SharedPreferences.setMockInitialValues({});
      await service.load();
      await service.setMedia(true);
      expect(service.media, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('consent.media'), true);
    });

    test('markShown persists value', () async {
      SharedPreferences.setMockInitialValues({});
      await service.load();
      await service.markShown();
      expect(service.shown, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('consent.shown'), true);
    });

    test('load reads persisted values', () async {
      SharedPreferences.setMockInitialValues({
        'consent.analytics': true,
        'consent.media': false,
        'consent.shown': true,
      });
      final state = await service.load();
      expect(state.analytics, true);
      expect(state.media, false);
      expect(state.shown, true);
    });
  });
}
