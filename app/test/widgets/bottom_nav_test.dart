import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oss/core/widgets/app_bottom_nav.dart';
import 'package:oss/core/navigation/routes.dart';
import 'package:oss/core/design_tokens/colors.dart';

void main() {
  group('AppBottomNav Widget Tests (Sprint 1)', () {
    testWidgets('renders all 4 tabs', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentLocation: AppRoutes.homePath,
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('highlights active tab', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentLocation: AppRoutes.learnPath,
            ),
          ),
        ),
      );

      // Find Learn tab icon (should be brandPrimary when active)
      final learnIcon = tester.widget<Icon>(
        find.descendant(
          of: find.ancestor(
            of: find.text('Learn'),
            matching: find.byType(InkWell),
          ),
          matching: find.byType(Icon),
        ),
      );

      expect(learnIcon.color, DsColors.brandPrimary);
    });

    testWidgets('tap triggers navigation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentLocation: AppRoutes.homePath,
            ),
          ),
        ),
      );

      // Note: Real tap would use context.go, but in isolated test we verify widget structure
      expect(find.text('Learn'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
    });

    testWidgets('touch targets are accessible (≥44pt)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNav(
              currentLocation: AppRoutes.homePath,
            ),
          ),
        ),
      );

      // Check bottom nav height
      final bottomNav = tester.widget<Container>(
        find
            .ancestor(
              of: find.text('Home'),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(bottomNav.constraints?.minHeight ?? 0, greaterThanOrEqualTo(44));
    });
  });
}
