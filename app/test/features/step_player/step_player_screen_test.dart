import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/widgets.dart';
import 'package:oss/core/services/gating_service.dart';
import 'package:oss/features/step_player/step_player_screen.dart';
import 'package:oss/core/l10n/strings.dart';

import '../../helpers/router_test_helper.dart';
import 'step_player_screen_test.mocks.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

@GenerateMocks([GatingService])
void main() {
  group('StepPlayerScreen Widget Tests', () {
    late MockGatingService mockGatingService;
    late MockNavigatorObserver mockObserver;

    setUp(() {
      mockGatingService = MockGatingService();
      mockObserver = MockNavigatorObserver();
    });

    Widget createTestWidget() {
      final router = GoRouter(
        initialLocation: '/player',
        observers: [mockObserver],
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/player',
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

      expect(find.byKey(const Key('step_player_title')), findsOneWidget);
      expect(find.byKey(const Key('step_player_step_id')), findsOneWidget);
      expect(
          find.byKey(const Key('step_player_complete_button')), findsOneWidget);
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

      await tester.tap(find.byKey(const Key('step_player_complete_button')));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('shows success snackbar and pops on completion',
        (tester) async {
      when(mockGatingService.completeStep('step-123')).thenAnswer(
        (_) async => const CompleteResult(
          success: true,
          idempotent: false,
          message: 'Step completed',
        ),
      );

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('step_player_complete_button')));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byKey(const Key('step_player_snackbar_success')),
          findsOneWidget);
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

      await tester.tap(find.byKey(const Key('step_player_complete_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byKey(const Key('step_player_snackbar_failure')),
          findsOneWidget);
    });

    testWidgets('shows generic error on exception', (tester) async {
      when(mockGatingService.completeStep('step-123'))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('step_player_complete_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.byKey(const Key('step_player_snackbar_error')), findsOneWidget);
    });

    testWidgets('button re-enables after error', (tester) async {
      when(mockGatingService.completeStep('step-123'))
          .thenThrow(Exception('Error'));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('step_player_complete_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Button should be enabled again
      final button = tester.widget<ElevatedButton>(
          find.byKey(const Key('step_player_complete_button')));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('shows idempotent completion message', (tester) async {
      when(mockGatingService.completeStep('step-123')).thenAnswer(
        (_) async {
          await Future.delayed(const Duration(milliseconds: 50));
          return const CompleteResult(
            success: true,
            idempotent: true,
            message: 'Step completed',
          );
        },
      );

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(const Key('step_player_complete_button')));
      await tester.pump();

      // Loading indicator should show
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Success snackbar should appear (idempotent still shows success)
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.byKey(const Key('step_player_snackbar_success')),
          findsOneWidget);
    });
  });
}
