import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/routes.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'core/design_tokens/colors.dart';
import 'core/services/consent_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/auth_service.dart';
import 'features/home/home_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/consent/consent_modal.dart';
import 'features/paywall/paywall_modal.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/legal/privacy_screen.dart';
import 'features/legal/terms_screen.dart';

/// Main router configuration for OSS app (Sprint 2).
///
/// Shell routes (with bottom nav): Home, Learn, Stats, Settings.
/// Modal/Auth/Legal routes (fullscreen, no bottom nav): Consent, Paywall, Login, Signup, etc.
/// Future routes (Sprint 5+): Technique, Step Player, Onboarding.
///
/// Factory pattern: createRouter accepts service instances and consent state.
GoRouter createRouter({
  required bool forceConsent,
  required ConsentService consentService,
  required AnalyticsService analyticsService,
  required AuthService authService,
}) {
  return GoRouter(
    initialLocation: AppRoutes.homePath,
    redirect: (context, state) {
      // Force consent modal on first launch
      if (forceConsent && state.matchedLocation != AppRoutes.consentPath) {
        return AppRoutes.consentPath;
      }
      return null;
    },
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
            builder: (context, state) =>
                SettingsScreen(authService: authService),
          ),
        ],
      ),
      // Modal routes (fullscreen)
      GoRoute(
        path: AppRoutes.consentPath,
        name: AppRoutes.consentName,
        pageBuilder: (context, state) => MaterialPage(
          fullscreenDialog: true,
          child: ConsentModal(
            consentService: consentService,
            analyticsService: analyticsService,
          ),
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
      // Auth routes (Sprint 2)
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => LoginScreen(authService: authService),
      ),
      GoRoute(
        path: AppRoutes.signupPath,
        name: AppRoutes.signupName,
        builder: (context, state) => SignupScreen(authService: authService),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordPath,
        name: AppRoutes.resetPasswordName,
        builder: (context, state) =>
            ResetPasswordScreen(authService: authService),
      ),
      // Legal routes (Sprint 2)
      GoRoute(
        path: AppRoutes.privacyPath,
        name: AppRoutes.privacyName,
        builder: (context, state) => const PrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsPath,
        name: AppRoutes.termsName,
        builder: (context, state) => const TermsScreen(),
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
}

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
