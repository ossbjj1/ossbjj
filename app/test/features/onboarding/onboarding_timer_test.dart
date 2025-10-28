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
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start timer via first input
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('White').last);
      await tester.pumpAndSettle();

      // Fast-forward to 46 seconds
      await tester.pump(const Duration(seconds: 46));

      // Countdown badge should be visible
      expect(find.textContaining('sec until autosave'), findsOneWidget);
    });

    testWidgets('autosave called at 60 seconds with draft flag',
        (tester) async {
      when(mockProfileService.upsert(any, draft: anyNamed('draft')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start timer
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('White').last);
      await tester.pumpAndSettle();

      // Fast-forward to 61 seconds
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();

      // Verify autosave called with draft=true
      verify(mockProfileService.upsert(any, draft: true)).called(1);

      // Verify snackbar shown
      expect(find.text('Autosaved'), findsOneWidget);
    });

    testWidgets('telemetry event sent on autosave when consent granted',
        (tester) async {
      when(mockConsentService.analytics).thenReturn(true);
      when(mockProfileService.upsert(any, draft: anyNamed('draft')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start timer
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('White').last);
      await tester.pumpAndSettle();

      // Fast-forward to autosave
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();

      // Verify telemetry called
      verify(mockAnalyticsService.track('onboarding_autosave', any)).called(1);
    });

    testWidgets('autosave only called once', (tester) async {
      when(mockProfileService.upsert(any, draft: anyNamed('draft')))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Start timer
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('White').last);
      await tester.pumpAndSettle();

      // Fast-forward past 60s multiple times
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      // Verify autosave only called once
      verify(mockProfileService.upsert(any, draft: true)).called(1);
    });
  });
}
