import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/navigation/routes.dart';
import 'core/widgets/app_bottom_nav.dart';
import 'core/design_tokens/colors.dart';
import 'core/services/consent_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/profile_service.dart';
import 'core/services/locale_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/progress_service.dart';
import 'core/services/gating_service.dart';
import 'features/home/home_screen.dart';
import 'features/learn/learn_screen.dart';
import 'features/learn/technique_list_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/consent/consent_modal.dart';
import 'features/paywall/paywall_modal.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/auth/reset_password_screen.dart';
import 'features/legal/privacy_screen.dart';
import 'features/legal/terms_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/step_player/step_player_screen.dart';
import 'features/splash/splash_screen.dart';

/// Main router configuration for OSS app (Sprint 3).
///
/// Shell routes (with bottom nav): Home, Learn, Stats, Settings.
/// Modal/Auth/Legal routes (fullscreen, no bottom nav): Consent, Paywall, Login, Signup, etc.
/// Onboarding (Sprint 3).
///
/// Factory pattern: createRouter accepts service instances and forced states.
GoRouter createRouter({
  required bool forceConsent,
  required bool forceOnboarding,
  required ConsentService consentService,
  required AnalyticsService analyticsService,
  required AuthService authService,
  required ProfileService profileService,
  required LocaleService localeService,
  required AudioService audioService,
  required ProgressService progressService,
  required GatingService gatingService,
}) {
  // Legal routes exempt from consent redirect (GDPR legal-page access).
  const legalRoutesWhitelist = {
    AppRoutes.privacyPath,
    AppRoutes.termsPath,
  };

  return GoRouter(
    initialLocation: AppRoutes.splashPath,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (loc == AppRoutes.splashPath) return null;

      // Force consent modal on first launch, but allow legal pages
      if (forceConsent &&
          loc != AppRoutes.consentPath &&
          !legalRoutesWhitelist.any((route) => loc.startsWith(route))) {
        return AppRoutes.consentPath;
      }

      // Force onboarding after consent, but allow legal pages
      if (forceOnboarding &&
          loc != AppRoutes.onboardingPath &&
          loc != AppRoutes.consentPath &&
          !legalRoutesWhitelist.any((route) => loc.startsWith(route))) {
        return AppRoutes.onboardingPath;
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
            builder: (context, state) => HomeScreen(
              progressService: progressService,
              gatingService: gatingService,
            ),
          ),
          GoRoute(
            path: AppRoutes.learnPath,
            name: AppRoutes.learnName,
            builder: (context, state) => const LearnScreen(),
            routes: [
              GoRoute(
                path: 'category/:category',
                builder: (context, state) {
                  final category = state.pathParameters['category']!;
                  return TechniqueListScreen(category: category);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.statsPath,
            name: AppRoutes.statsName,
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settingsPath,
            name: AppRoutes.settingsName,
            builder: (context, state) => SettingsScreen(
              authService: authService,
              localeService: localeService,
              audioService: audioService,
              consentService: consentService,
              analyticsService: analyticsService,
            ),
          ),
        ],
      ),
      // Splash route (initial)
      GoRoute(
        path: AppRoutes.splashPath,
        name: AppRoutes.splashName,
        builder: (context, state) => SplashScreen(
          consentService: consentService,
          authService: authService,
          forceOnboarding: forceOnboarding,
        ),
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
      // Sprint 4: Step Player MVP
      GoRoute(
        path: '${AppRoutes.stepPath}/:stepId',
        name: AppRoutes.stepName,
        builder: (context, state) {
          final stepId = state.pathParameters['stepId']!;
          return StepPlayerScreen(
            stepId: stepId,
            gatingService: gatingService,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.onboardingPath,
        name: AppRoutes.onboardingName,
        builder: (context, state) => OnboardingScreen(
          profileService: profileService,
          analyticsService: analyticsService,
          consentService: consentService,
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
