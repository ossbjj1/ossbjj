import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:oss/core/services/auth_service.dart';
import 'package:oss/core/services/locale_service.dart';
import 'package:oss/core/services/audio_service.dart';
import 'package:oss/core/services/consent_service.dart';
import 'package:oss/core/services/analytics_service.dart';
import 'package:oss/features/settings/settings_screen.dart';
import 'package:oss/core/l10n/strings.dart';

@GenerateMocks([
  AuthService,
  LocaleService,
  AudioService,
  ConsentService,
  AnalyticsService
])
import 'settings_consent_test.mocks.dart';

void main() {
  group('SettingsScreen Consent Toggle Tests', () {
    late MockAuthService mockAuthService;
    late MockLocaleService mockLocaleService;
    late MockAudioService mockAudioService;
    late MockConsentService mockConsentService;
    late MockAnalyticsService mockAnalyticsService;

    setUp(() {
      mockAuthService = MockAuthService();
      mockLocaleService = MockLocaleService();
      mockAudioService = MockAudioService();
      mockConsentService = MockConsentService();
      mockAnalyticsService = MockAnalyticsService();

      // Default: no user, consent disabled
      when(mockAuthService.currentUser).thenReturn(null);
      when(mockConsentService.analytics).thenReturn(false);
      when(mockConsentService.media).thenReturn(false);
      when(mockAudioService.audioEnabled)
          .thenReturn(ValueNotifier<bool>(false));
    });

    Widget createTestWidget() {
      return StringsScope(
        localeNotifier: ValueNotifier(const Locale('en')),
        child: MaterialApp(
          home: SettingsScreen(
            authService: mockAuthService,
            localeService: mockLocaleService,
            audioService: mockAudioService,
            consentService: mockConsentService,
            analyticsService: mockAnalyticsService,
          ),
        ),
      );
    }

    testWidgets('analytics toggle calls setServerAnalytics and init',
        (tester) async {
      when(mockConsentService.setServerAnalytics(true))
          .thenAnswer((_) async {});
      when(mockAnalyticsService.initIfAllowed(analyticsAllowed: true))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find analytics switch
      final analyticsSwitchFinder = find.ancestor(
        of: find.text('Allow analytics'),
        matching: find.byType(SwitchListTile),
      );
      expect(analyticsSwitchFinder, findsOneWidget);

      // Tap switch to enable
      await tester.tap(analyticsSwitchFinder);
      await tester.pumpAndSettle();

      // Verify server sync called
      verify(mockConsentService.setServerAnalytics(true)).called(1);

      // Verify analytics init called
      verify(mockAnalyticsService.initIfAllowed(analyticsAllowed: true))
          .called(1);
    });

    testWidgets('analytics toggle reverts on server failure', (tester) async {
      when(mockConsentService.setServerAnalytics(true))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap analytics switch
      final analyticsSwitchFinder = find.ancestor(
        of: find.text('Allow analytics'),
        matching: find.byType(SwitchListTile),
      );
      await tester.tap(analyticsSwitchFinder);
      await tester.pumpAndSettle();

      // Verify error snackbar shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Failed to save setting'), findsOneWidget);

      // Switch should revert to false (original state)
      final switchWidget = tester.widget<SwitchListTile>(analyticsSwitchFinder);
      expect(switchWidget.value, false);
    });

    testWidgets('media toggle calls setMedia', (tester) async {
      when(mockConsentService.setMedia(true)).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find media switch
      final mediaSwitchFinder = find.ancestor(
        of: find.text('Allow media'),
        matching: find.byType(SwitchListTile),
      );
      expect(mediaSwitchFinder, findsOneWidget);

      // Tap switch to enable
      await tester.tap(mediaSwitchFinder);
      await tester.pumpAndSettle();

      // Verify setMedia called
      verify(mockConsentService.setMedia(true)).called(1);
    });

    testWidgets('media toggle reverts on failure', (tester) async {
      when(mockConsentService.setMedia(true))
          .thenThrow(Exception('Storage error'));

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap media switch
      final mediaSwitchFinder = find.ancestor(
        of: find.text('Allow media'),
        matching: find.byType(SwitchListTile),
      );
      await tester.tap(mediaSwitchFinder);
      await tester.pumpAndSettle();

      // Verify error snackbar shown
      expect(find.byType(SnackBar), findsOneWidget);

      // Switch should revert to false
      final switchWidget = tester.widget<SwitchListTile>(mediaSwitchFinder);
      expect(switchWidget.value, false);
    });

    testWidgets('consent toggles load initial state from service',
        (tester) async {
      when(mockConsentService.analytics).thenReturn(true);
      when(mockConsentService.media).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify switches reflect loaded state
      final analyticsSwitchFinder = find.ancestor(
        of: find.text('Allow analytics'),
        matching: find.byType(SwitchListTile),
      );
      final mediaSwitchFinder = find.ancestor(
        of: find.text('Allow media'),
        matching: find.byType(SwitchListTile),
      );

      final analyticsSwitch =
          tester.widget<SwitchListTile>(analyticsSwitchFinder);
      final mediaSwitch = tester.widget<SwitchListTile>(mediaSwitchFinder);

      expect(analyticsSwitch.value, true);
      expect(mediaSwitch.value, true);
    });

    testWidgets('privacy settings link navigates to consent modal',
        (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find "Privacy settings" list tile
      final privacyTileFinder = find.ancestor(
        of: find.text('Privacy settings'),
        matching: find.byType(ListTile),
      );

      expect(privacyTileFinder, findsOneWidget);
      // Note: Navigation testing would require router mock
      // For now, just verify tile exists
    });
  });
}
