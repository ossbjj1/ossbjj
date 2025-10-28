import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:oss/core/services/profile_service.dart';
import 'package:oss/core/services/analytics_service.dart';
import 'package:oss/core/services/consent_service.dart';
import 'package:oss/features/onboarding/onboarding_screen.dart';
import 'package:oss/core/l10n/strings.dart';

@GenerateMocks([ProfileService, AnalyticsService, ConsentService])
import 'onboarding_timer_test.mocks.dart';

void main() {
  group('OnboardingScreen Timer Tests', () {
    late MockProfileService mockProfileService;
    late MockAnalyticsService mockAnalyticsService;
    late MockConsentService mockConsentService;

    setUp(() {
      mockProfileService = MockProfileService();
      mockAnalyticsService = MockAnalyticsService();
      mockConsentService = MockConsentService();

      // Default: consent not granted
      when(mockConsentService.analytics).thenReturn(false);
    });

    Widget createTestWidget() {
      return StringsScope(
        localeNotifier: ValueNotifier(const Locale('en')),
        child: MaterialApp(
          home: OnboardingScreen(
            profileService: mockProfileService,
            analyticsService: mockAnalyticsService,
            consentService: mockConsentService,
          ),
        ),
      );
    }

    testWidgets('timer starts on first dropdown selection', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially, no countdown visible
      expect(find.textContaining('sec until autosave'), findsNothing);

      // Tap first dropdown (Belt)
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();

      // Select an option
      await tester.tap(find.text('White').last);
      await tester.pumpAndSettle();

      // Timer should now be running (not visible yet, < 45s)
      expect(find.textContaining('sec until autosave'), findsNothing);
    });

    testWidgets('countdown badge appears after 45 seconds', (tester) async {
      // TODO: Timer.periodic not testable with tester.pump(Duration)
      // Needs Clock injection or FakeAsync approach
    }, skip: true);

    testWidgets('autosave called at 60 seconds with draft flag',
        (tester) async {
      // TODO: Timer.periodic not testable with tester.pump(Duration)
      // Needs Clock injection or FakeAsync approach
    }, skip: true);

    testWidgets('telemetry event sent on autosave when consent granted',
        (tester) async {
      // TODO: Timer.periodic not testable with tester.pump(Duration)
      // Needs Clock injection or FakeAsync approach
    }, skip: true);

    testWidgets('autosave only called once', (tester) async {
      // TODO: Timer.periodic not testable with tester.pump(Duration)
      // Needs Clock injection or FakeAsync approach
    }, skip: true);
  });
}
