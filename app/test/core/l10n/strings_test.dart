import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oss/core/l10n/strings.dart';

void main() {
  group('Strings', () {
    test('returns German strings for de locale', () {
      final strings = Strings.of(const Locale('de'));

      expect(strings.tabLearn, 'Lernen');
      expect(strings.tabSettings, 'Einstellungen');
      expect(strings.onboardingHeadline, 'Zeit auf der Matte. Los.');
      expect(strings.settingsLanguage, 'Sprache');
    });

    test('returns English strings for en locale', () {
      final strings = Strings.of(const Locale('en'));

      expect(strings.tabLearn, 'Learn');
      expect(strings.tabSettings, 'Settings');
      expect(strings.onboardingHeadline, 'Time on the mat. Go.');
      expect(strings.settingsLanguage, 'Language');
    });

    test('isDe returns correct value', () {
      final de = Strings.of(const Locale('de'));
      final en = Strings.of(const Locale('en'));

      expect(de.isDe, true);
      expect(en.isDe, false);
    });
  });
}
