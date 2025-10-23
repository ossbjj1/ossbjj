import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main router configuration for OSS app.
///
/// Routes:
/// - `/` → HomeScreen (S1)
/// - `/learn` → LearnScreen (S1)
/// - `/stats` → StatsScreen (S1)
/// - `/settings` → SettingsScreen (S1)
/// - `/technique/:id` → TechniqueScreen (S5)
/// - `/step/:id` → StepPlayerScreen (S5)
/// - `/paywall` → PaywallScreen (S8, full-screen modal)
/// - `/consent` → ConsentScreen (S2, full-screen modal)
/// - `/onboarding` → OnboardingScreen (S3, full-screen modal)
final GoRouter appRouter = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => Scaffold(
        body: child,
        bottomNavigationBar: _buildBottomNav(context),
      ),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const _HomeScreenStub(),
        ),
        GoRoute(
          path: '/learn',
          name: 'learn',
          builder: (context, state) => const _LearnScreenStub(),
        ),
        GoRoute(
          path: '/stats',
          name: 'stats',
          builder: (context, state) => const _StatsScreenStub(),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const _SettingsScreenStub(),
        ),
      ],
    ),
    GoRoute(
      path: '/technique/:id',
      name: 'technique',
      builder: (context, state) => const _TechniqueScreenStub(),
    ),
    GoRoute(
      path: '/step/:id',
      name: 'step',
      builder: (context, state) => const _StepPlayerScreenStub(),
    ),
    GoRoute(
      path: '/paywall',
      name: 'paywall',
      builder: (context, state) => const _PaywallScreenStub(),
    ),
    GoRoute(
      path: '/consent',
      name: 'consent',
      builder: (context, state) => const _ConsentScreenStub(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const _OnboardingScreenStub(),
    ),
  ],
);

Widget? _buildBottomNav(BuildContext context) {
  final location = GoRouterState.of(context).uri.path;
  // Hide bottom nav on detail/modal routes
  if (location.contains('/technique/') ||
      location.contains('/step/') ||
      location.contains('/paywall') ||
      location.contains('/consent') ||
      location.contains('/onboarding')) {
    return null;
  }
  return Container(
    color: Colors.grey[900],
    child: Row(
      children: [
        _NavItem(label: 'Home', route: '/', currentLocation: location),
        _NavItem(label: 'Learn', route: '/learn', currentLocation: location),
        _NavItem(label: 'Stats', route: '/stats', currentLocation: location),
        _NavItem(
            label: 'Settings', route: '/settings', currentLocation: location),
      ],
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.route,
    required this.currentLocation,
  });

  final String label;
  final String route;
  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final isActive = currentLocation == route;
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: isActive ? Colors.red : transparent,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

const transparent = Color.fromARGB(0, 0, 0, 0);

// Sprint 1 Stubs
class _HomeScreenStub extends StatelessWidget {
  const _HomeScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Home (Sprint 1)')),
      );
}

class _LearnScreenStub extends StatelessWidget {
  const _LearnScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Learn (Sprint 1)')),
      );
}

class _StatsScreenStub extends StatelessWidget {
  const _StatsScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Stats (Sprint 1)')),
      );
}

class _SettingsScreenStub extends StatelessWidget {
  const _SettingsScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Settings (Sprint 1)')),
      );
}

// Sprint 5+ Stubs
class _TechniqueScreenStub extends StatelessWidget {
  const _TechniqueScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Technique (Sprint 5)')),
      );
}

class _StepPlayerScreenStub extends StatelessWidget {
  const _StepPlayerScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Step Player (Sprint 5)')),
      );
}

// Sprint 2+ Stubs
class _ConsentScreenStub extends StatelessWidget {
  const _ConsentScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Consent (Sprint 2)')),
      );
}

// Sprint 3+ Stubs
class _OnboardingScreenStub extends StatelessWidget {
  const _OnboardingScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Onboarding (Sprint 3)')),
      );
}

// Sprint 8 Stubs
class _PaywallScreenStub extends StatelessWidget {
  const _PaywallScreenStub();
  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('Paywall (Sprint 8)')),
      );
}
