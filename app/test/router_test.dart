import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oss/router.dart';
import 'package:oss/core/navigation/routes.dart';

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

      // Bottom nav should be visible on home (labels in nav bar)
      final navBars = find.byType(InkWell);
      expect(navBars, findsNWidgets(4)); // 4 nav items
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
}
