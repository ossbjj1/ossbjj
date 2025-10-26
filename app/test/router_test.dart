import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oss/router.dart';
import 'package:oss/core/navigation/routes.dart';

void main() {
  group('Router Navigation Tests (Sprint 1)', () {
    testWidgets('starts at home route', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Expect Home screen content (AppBar title or body stub text)
      expect(find.text('Home'), findsWidgets);
    });

    testWidgets('navigates between main tabs', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
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
          routerConfig: appRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Bottom nav should be visible on home (labels in nav bar)
      final navBars = find.byType(InkWell);
      expect(navBars, findsNWidgets(4)); // 4 nav items
    });
  });

  group('Router Hide-Rules Tests (Sprint 1)', () {
    testWidgets('bottom nav hidden on consent modal', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to consent
      appRouter.go(AppRoutes.consentPath);
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
          routerConfig: appRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to paywall
      appRouter.go(AppRoutes.paywallPath);
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
          routerConfig: appRouter,
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to technique detail
      appRouter.go('/technique/1');
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
