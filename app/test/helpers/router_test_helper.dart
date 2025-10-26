import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Test helper for creating GoRouter mocks with standard routes.
///
/// Centralizes router setup to avoid duplication across widget tests
/// that need navigation (e.g., ContinueCard, StepPlayerScreen).
class RouterTestHelper {
  /// Creates a mock GoRouter with standard app routes for testing.
  ///
  /// [homeBuilder] is the widget builder for the home route ('/').
  /// All other routes (onboarding, step, paywall) use placeholder screens.
  static GoRouter createMockRouter({
    required Widget Function(BuildContext context, GoRouterState state)
        homeBuilder,
  }) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: homeBuilder,
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const Scaffold(body: Text('Onboarding')),
        ),
        GoRoute(
          path: '/step/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            return Scaffold(body: Text('Step $id'));
          },
        ),
        GoRoute(
          path: '/paywall',
          builder: (context, state) => const Scaffold(body: Text('Paywall')),
        ),
      ],
    );
  }
}
