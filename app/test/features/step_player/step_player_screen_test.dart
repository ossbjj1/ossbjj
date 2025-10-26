import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:oss/core/services/gating_service.dart';
import 'package:oss/features/step_player/step_player_screen.dart';
import 'package:oss/core/l10n/strings.dart';

import 'step_player_screen_test.mocks.dart';

@GenerateMocks([GatingService])
void main() {
  group('StepPlayerScreen Widget Tests', () {
    late MockGatingService mockGatingService;

    setUp(() {
      mockGatingService = MockGatingService();
    });

    Widget createTestWidget() {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => StepPlayerScreen(
              stepId: 'step-123',
              gatingService: mockGatingService,
            ),
          ),
        ],
      );

      return StringsScope(
        localeNotifier: ValueNotifier(const Locale('en')),
        child: MaterialApp.router(
          routerConfig: router,
        ),
      );
    }

    testWidgets('displays step ID and complete button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Step Player MVP'), findsOneWidget);
      expect(find.text('Step ID: step-123'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows loading spinner while completing step', (tester) async {
      when(mockGatingService.completeStep('step-123')).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return const CompleteResult(
            success: true,
            idempotent: false,
            message: 'Step completed',
          );
        },
      );

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows success snackbar on completion', (tester) async {
      when(mockGatingService.completeStep('step-123')).thenAnswer(
        (_) async => const CompleteResult(
          success: true,
          idempotent: false,
          message: 'Step completed',
        ),
      );

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Step completed!'), findsOneWidget);

      verify(mockGatingService.completeStep('step-123')).called(1);
    });

    testWidgets('shows error snackbar on failure', (tester) async {
      when(mockGatingService.completeStep('step-123')).thenAnswer(
        (_) async => const CompleteResult(
          success: false,
          idempotent: false,
          message: 'Access denied: premiumRequired',
        ),
      );

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Access denied: premiumRequired'), findsOneWidget);
    });

    testWidgets('shows generic error on exception', (tester) async {
      when(mockGatingService.completeStep('step-123'))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('button re-enables after error', (tester) async {
      when(mockGatingService.completeStep('step-123'))
          .thenThrow(Exception('Error'));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Button should be enabled again
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });
}
