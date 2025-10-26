/// Central route constants for OSS app navigation.
///
/// Sprint 1: Home, Learn, Stats, Settings + Modal stubs (Consent, Paywall).
/// Future sprints: Technique, Step Player, Onboarding, Auth.
class AppRoutes {
  AppRoutes._();

  // Main tabs (Shell routes with bottom nav)
  static const String homePath = '/';
  static const String homeName = 'home';

  static const String learnPath = '/learn';
  static const String learnName = 'learn';

  static const String statsPath = '/stats';
  static const String statsName = 'stats';

  static const String settingsPath = '/settings';
  static const String settingsName = 'settings';

  // Modal routes (fullscreen, no bottom nav)
  static const String consentPath = '/consent';
  static const String consentName = 'consent';

  static const String paywallPath = '/paywall';
  static const String paywallName = 'paywall';

  static const String onboardingPath = '/onboarding';
  static const String onboardingName = 'onboarding';

  // Detail routes (no bottom nav, Sprint 5+)
  static const String techniquePath = '/technique/:id';
  static const String techniqueName = 'technique';

  static const String stepPath = '/step/:id';
  static const String stepName = 'step';

  /// Routes where bottom nav should be hidden.
  static const Set<String> hideBottomNavRoutes = {
    '/technique/',
    '/step/',
    consentPath,
    paywallPath,
    onboardingPath,
  };

  /// Routes where bottom nav is visible (main tabs).
  static const Set<String> showBottomNavRoutes = {
    homePath,
    learnPath,
    statsPath,
    settingsPath,
  };
}
