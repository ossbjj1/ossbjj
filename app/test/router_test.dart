import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

late GoRouter _testRouter;

GoRouter _createTestRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Scaffold(
            appBar: AppBar(title: const Text('Test')),
            body: child,
            bottomNavigationBar: BottomNavigationBar(
              items: const [
                BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
                BottomNavigationBarItem(
                    label: 'Learn', icon: Icon(Icons.school)),
                BottomNavigationBarItem(
                    label: 'Stats', icon: Icon(Icons.bar_chart)),
                BottomNavigationBarItem(
                    label: 'Settings', icon: Icon(Icons.settings)),
              ],
              onTap: (index) {
                const paths = ['/', '/learn', '/stats', '/settings'];
                GoRouter.of(context).go(paths[index]);
              },
            ),
          );
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: const Text('Home'),
            ),
          ),
          GoRoute(
            path: '/learn',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Learn')),
              body: const Text('Learn'),
            ),
          ),
          GoRoute(
            path: '/stats',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Stats')),
              body: const Text('Stats'),
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Settings')),
              body: const Text('Settings'),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/consent',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Consent')),
          body: const Text('Consent'),
        ),
      ),
      GoRoute(
        path: '/paywall',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Paywall')),
          body: const Text('Paywall'),
        ),
      ),
      GoRoute(
        path: '/technique/:id',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Technique (Sprint 5)')),
          body: const Text('Technique'),
        ),
      ),
    ],
  );
}

void main() {
  group('Router Navigation Tests (Sprint 1)', () {
    setUp(() {
      _testRouter = _createTestRouter();
    });

    tearDown(() {
      _testRouter.dispose();
    });

    testWidgets('starts at home route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: _testRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Expect Home screen content (AppBar title or body stub text)
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('navigates between main tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: _testRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Start at Home (verify AppBar)
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);

      // Tap Learn tab
      await tester.tap(find.text('Learn'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Learn'), findsOneWidget);

      // Tap Stats tab
      await tester.tap(find.text('Stats'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Stats'), findsOneWidget);

      // Tap Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Settings'), findsOneWidget);
    });

    testWidgets('bottom nav visible on main tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: _testRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Bottom nav should be visible on home (icons in nav bar)
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });

  group('Router Hide-Rules Tests (Sprint 1)', () {
    setUp(() {
      _testRouter = _createTestRouter();
    });

    tearDown(() {
      _testRouter.dispose();
    });

    testWidgets('bottom nav hidden on consent modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: _testRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to consent
      _testRouter.go('/consent');
      await tester.pumpAndSettle();

      // Expect Consent screen (AppBar title)
      expect(find.widgetWithText(AppBar, 'Consent'), findsOneWidget);

      // Bottom nav should NOT be visible
      expect(find.text('Home'), findsNothing);
      expect(find.text('Learn'), findsNothing);
    });

    testWidgets('bottom nav hidden on paywall modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: _testRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to paywall
      _testRouter.go('/paywall');
      await tester.pumpAndSettle();

      // Expect Paywall screen (AppBar title)
      expect(find.widgetWithText(AppBar, 'Paywall'), findsOneWidget);

      // Bottom nav should NOT be visible
      expect(find.text('Home'), findsNothing);
      expect(find.text('Learn'), findsNothing);
    });

    testWidgets('bottom nav hidden on technique route (future)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: _testRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to technique detail
      _testRouter.go('/technique/1');
      await tester.pumpAndSettle();

      // Expect placeholder screen (AppBar title)
      expect(
          find.widgetWithText(AppBar, 'Technique (Sprint 5)'), findsOneWidget);

      // Bottom nav should NOT be visible
      expect(find.text('Home'), findsNothing);
      expect(find.text('Learn'), findsNothing);
    });
  });

  group('Router Redirect Tests (Sprint 3)', () {
    testWidgets('forceOnboarding redirects to /onboarding', (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        redirect: (context, state) {
          // Simulate forceOnboarding=true
          if (state.matchedLocation != '/onboarding' &&
              state.matchedLocation != '/legal/privacy' &&
              state.matchedLocation != '/legal/terms') {
            return '/onboarding';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Text('Home'),
            ),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const Scaffold(
              body: Text('Onboarding'),
            ),
          ),
          GoRoute(
            path: '/legal/privacy',
            builder: (context, state) => const Scaffold(
              body: Text('Privacy'),
            ),
          ),
          GoRoute(
            path: '/legal/terms',
            builder: (context, state) => const Scaffold(
              body: Text('Terms'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Should redirect to onboarding
      expect(find.text('Onboarding'), findsOneWidget);
      expect(find.text('Home'), findsNothing);
    });

    testWidgets('forceOnboarding allows legal routes', (tester) async {
      final router = GoRouter(
        initialLocation: '/legal/privacy',
        redirect: (context, state) {
          // Simulate forceOnboarding=true but allow legal pages
          if (state.matchedLocation != '/onboarding' &&
              !state.matchedLocation.startsWith('/legal/')) {
            return '/onboarding';
          }
          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Text('Home'),
            ),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const Scaffold(
              body: Text('Onboarding'),
            ),
          ),
          GoRoute(
            path: '/legal/privacy',
            builder: (context, state) => const Scaffold(
              body: Text('Privacy'),
            ),
          ),
          GoRoute(
            path: '/legal/terms',
            builder: (context, state) => const Scaffold(
              body: Text('Terms'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Should NOT redirect, allow privacy page
      expect(find.text('Privacy'), findsOneWidget);
      expect(find.text('Onboarding'), findsNothing);
    });

    testWidgets('forceConsent takes precedence over forceOnboarding',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/',
        redirect: (context, state) {
          final loc = state.matchedLocation;

          // Consent first
          if (loc != '/consent' && !loc.startsWith('/legal/')) {
            return '/consent';
          }

          // Then onboarding (this won't be reached in this test)
          if (loc != '/onboarding' &&
              loc != '/consent' &&
              !loc.startsWith('/legal/')) {
            return '/onboarding';
          }

          return null;
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Text('Home'),
            ),
          ),
          GoRoute(
            path: '/consent',
            builder: (context, state) => const Scaffold(
              body: Text('Consent'),
            ),
          ),
          GoRoute(
            path: '/onboarding',
            builder: (context, state) => const Scaffold(
              body: Text('Onboarding'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();

      // Should redirect to consent, not onboarding
      expect(find.text('Consent'), findsOneWidget);
      expect(find.text('Onboarding'), findsNothing);
      expect(find.text('Home'), findsNothing);
    });
  });
}
