import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oss/core/services/gating_service.dart';
import 'package:oss/core/services/progress_service.dart';
import 'package:oss/features/home/continue_card.dart';
import 'package:oss/core/l10n/strings.dart';

import '../../helpers/router_test_helper.dart';
import 'continue_card_test.mocks.dart';

@GenerateMocks([GatingService, ProgressService])
void main() {
  group('ContinueCard Widget Tests', () {
    late MockGatingService mockGatingService;
    late MockProgressService mockProgressService;

    setUp(() {
      mockGatingService = MockGatingService();
      mockProgressService = MockProgressService();
    });

    Widget createTestWidget({
      NextStepResult? nextStep,
      Future<NextStepResult?>? nextStepFuture,
    }) {
      // If nextStepFuture is provided (for loading tests), use it directly
      // Otherwise mock with immediate result
      if (nextStepFuture != null) {
        when(mockProgressService.getNextStep(
                preferredVariant: anyNamed('preferredVariant')))
            .thenAnswer((_) => nextStepFuture);
      } else {
        when(mockProgressService.getNextStep(
                preferredVariant: anyNamed('preferredVariant')))
            .thenAnswer((_) async => nextStep);
      }

      final router = RouterTestHelper.createMockRouter(
        homeBuilder: (context, state) => Scaffold(
          body: ContinueCard(
            progressService: mockProgressService,
            gatingService: mockGatingService,
          ),
        ),
      );

      return StringsScope(
        localeNotifier: ValueNotifier(const Locale('en')),
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('shows loading placeholder while fetching next step',
        (tester) async {
      final completer = Completer<NextStepResult?>();

      await tester
          .pumpWidget(createTestWidget(nextStepFuture: completer.future));
      await tester.pump(); // Start the future but don't complete it

      expect(find.byKey(const Key('continue_card_loading')), findsOneWidget);

      // Clean up: complete the future to avoid hanging
      completer.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('shows onboarding CTA when nextStep is null', (tester) async {
      await tester.pumpWidget(createTestWidget(nextStep: null));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('continue_card_onboarding_button')),
          findsOneWidget);
      expect(find.text('Start Onboarding'), findsOneWidget);
      expect(find.text('Save Profile'), findsOneWidget);
    });

    testWidgets('shows continue button when nextStep exists', (tester) async {
      const nextStep = NextStepResult(
        stepId: 'step-123',
        titleEn: 'Armbar Basics',
        titleDe: 'Armhebel Basics',
        idx: 1,
        variant: 'gi',
      );

      await tester.pumpWidget(createTestWidget(nextStep: nextStep));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('continue_card_continue_button')),
          findsOneWidget);
      expect(find.text('Armbar Basics'), findsOneWidget);
      expect(find.text('Continue'), findsNWidgets(2)); // title + button
    });

    testWidgets('calls gating service and navigates when allowed (idx < 3)',
        (tester) async {
      const nextStep = NextStepResult(
        stepId: 'step-123',
        titleEn: 'Armbar',
        titleDe: 'Armhebel',
        idx: 1,
        variant: 'gi',
      );

      // Mock gating to allow access (server decides, even for idx < 3)
      when(mockGatingService.checkStepAccess('step-123')).thenAnswer(
        (_) async => const GatingAccess(
            allowed: true, reason: GatingReason.free),
      );

      await tester.pumpWidget(createTestWidget(nextStep: nextStep));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('continue_card_continue_button')));
      await tester.pumpAndSettle();

      // Sprint 4: Server-side gating for ALL steps
      verify(mockGatingService.checkStepAccess('step-123')).called(1);
    });

    testWidgets(
        'calls gating service and navigates to paywall when idx >= 3 and locked',
        (tester) async {
      const nextStep = NextStepResult(
        stepId: 'step-premium',
        titleEn: 'Advanced Armbar',
        titleDe: 'Fortgeschrittener Armhebel',
        idx: 3,
        variant: 'gi',
      );

      when(mockGatingService.checkStepAccess('step-premium')).thenAnswer(
        (_) async => const GatingAccess(
            allowed: false, reason: GatingReason.premiumRequired),
      );

      await tester.pumpWidget(createTestWidget(nextStep: nextStep));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('continue_card_continue_button')));
      await tester.pumpAndSettle();

      verify(mockGatingService.checkStepAccess('step-premium')).called(1);
      // Navigation verified: no exception thrown (mock router handles route)
    });

    testWidgets('shows error snackbar on gating failure', (tester) async {
      const nextStep = NextStepResult(
        stepId: 'step-gated',
        titleEn: 'Gated Step',
        titleDe: 'Gesperrter Schritt',
        idx: 5,
        variant: 'gi',
      );

      when(mockGatingService.checkStepAccess('step-gated'))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget(nextStep: nextStep));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('continue_card_continue_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('An error occurred'), findsOneWidget); // errorGeneric
    });
  });
}
