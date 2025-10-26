import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/routes.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'core/design_tokens/colors.dart';
import 'features/home/home_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/consent/consent_modal.dart';
import 'features/paywall/paywall_modal.dart';

/// Main router configuration for OSS app (Sprint 1).
///
/// Shell routes (with bottom nav): Home, Learn, Stats, Settings.
/// Modal routes (fullscreen, no bottom nav): Consent, Paywall.
/// Future routes (Sprint 5+): Technique, Step Player, Onboarding.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.homePath,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        final location = state.matchedLocation;
        final showNav = !AppRoutes.hideBottomNavRoutes
            .any((route) => location.startsWith(route));
        return Scaffold(
          body: child,
          bottomNavigationBar:
              showNav ? AppBottomNav(currentLocation: location) : null,
        );
      },
      routes: [
        GoRoute(
          path: AppRoutes.homePath,
          name: AppRoutes.homeName,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.learnPath,
          name: AppRoutes.learnName,
          builder: (context, state) => const LearnScreen(),
        ),
        GoRoute(
          path: AppRoutes.statsPath,
          name: AppRoutes.statsName,
          builder: (context, state) => const StatsScreen(),
        ),
        GoRoute(
          path: AppRoutes.settingsPath,
          name: AppRoutes.settingsName,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    // Modal routes (fullscreen)
    GoRoute(
      path: AppRoutes.consentPath,
      name: AppRoutes.consentName,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: ConsentModal(),
      ),
    ),
    GoRoute(
      path: AppRoutes.paywallPath,
      name: AppRoutes.paywallName,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: PaywallModal(),
      ),
    ),
    // Future routes (Sprint 5+) - stubs for hide-rule testing
    GoRoute(
      path: AppRoutes.techniquePath,
      name: AppRoutes.techniqueName,
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Technique (Sprint 5)',
      ),
    ),
    GoRoute(
      path: AppRoutes.stepPath,
      name: AppRoutes.stepName,
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Step Player (Sprint 5)',
      ),
    ),
    GoRoute(
      path: AppRoutes.onboardingPath,
      name: AppRoutes.onboardingName,
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Onboarding (Sprint 3)',
      ),
    ),
  ],
);

/// Minimal placeholder for future routes (Sprint 3+).
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: DsColors.bgSurface,
      ),
      body: Center(
        child: Text(
          '$title\n(Placeholder)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: DsColors.textSecondary),
        ),
      ),
    );
  }
}
