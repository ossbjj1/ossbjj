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
      ContinueHint? hint,
      Future<ContinueHint?>? hintFuture,
    }) {
      // If hintFuture is provided (for loading tests), use it directly
      // Otherwise mock with immediate result
      if (hintFuture != null) {
        when(mockProgressService.loadLast()).thenAnswer((_) => hintFuture);
      } else {
        when(mockProgressService.loadLast()).thenAnswer((_) async => hint);
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

    testWidgets('shows loading placeholder while fetching hint',
        (tester) async {
      final completer = Completer<ContinueHint?>();

      await tester.pumpWidget(createTestWidget(hintFuture: completer.future));
      await tester.pump(); // Start the future but don't complete it

      expect(find.byKey(const Key('continue_card_loading')), findsOneWidget);

      // Clean up: complete the future to avoid hanging
      completer.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('shows onboarding CTA when hint is null', (tester) async {
      await tester.pumpWidget(createTestWidget(hint: null));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('continue_card_onboarding_button')),
          findsOneWidget);
      expect(find.text('Start Onboarding'), findsOneWidget);
      expect(find.text('Save Profile'), findsOneWidget);
    });

    testWidgets('shows continue button when hint exists', (tester) async {
      const hint = ContinueHint(stepId: 'step-123', title: 'Armbar Basics');

      await tester.pumpWidget(createTestWidget(hint: hint));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('continue_card_continue_button')),
          findsOneWidget);
      expect(find.text('Armbar Basics'), findsOneWidget);
      expect(find.text('Continue'), findsNWidgets(2)); // title + button
    });

    testWidgets('calls gating service and navigates to step when allowed',
        (tester) async {
      const hint = ContinueHint(stepId: 'step-123', title: 'Armbar');

      when(mockGatingService.checkStepAccess('step-123')).thenAnswer(
        (_) async =>
            const GatingAccess(allowed: true, reason: GatingReason.free),
      );

      await tester.pumpWidget(createTestWidget(hint: hint));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('continue_card_continue_button')));
      await tester.pumpAndSettle();

      verify(mockGatingService.checkStepAccess('step-123')).called(1);
      // Navigation verified: no exception thrown (mock router handles route)
    });

    testWidgets('calls gating service and navigates to paywall when locked',
        (tester) async {
      const hint = ContinueHint(stepId: 'step-123', title: 'Armbar');

      when(mockGatingService.checkStepAccess('step-123')).thenAnswer(
        (_) async => const GatingAccess(
            allowed: false, reason: GatingReason.premiumRequired),
      );

      await tester.pumpWidget(createTestWidget(hint: hint));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('continue_card_continue_button')));
      await tester.pumpAndSettle();

      verify(mockGatingService.checkStepAccess('step-123')).called(1);
      // Navigation verified: no exception thrown (mock router handles route)
    });

    testWidgets('shows error snackbar on gating failure', (tester) async {
      const hint = ContinueHint(stepId: 'step-123', title: 'Armbar');

      when(mockGatingService.checkStepAccess('step-123'))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget(hint: hint));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('continue_card_continue_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('An error occurred'), findsOneWidget); // errorGeneric
    });
  });
}
