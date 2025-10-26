/// Simple i18n strings helper (MVP Sprint 1).
///
/// Future: Replace with flutter_localizations + ARB files.
/// For now: Static English labels, aligned with docs/i18n_keys.json.
class AppStrings {
  const AppStrings._();

  // Tabs (bottom nav)
  static const String tabHome = 'Home';
  static const String tabLearn = 'Learn';
  static const String tabStats = 'Stats';
  static const String tabSettings = 'Settings';

  // Nav titles (AppBar)
  static const String navTitleHome = 'Home';
  static const String navTitleLearn = 'Learn';
  static const String navTitleStats = 'Stats';
  static const String navTitleSettings = 'Settings';

  // CTAs
  static const String ctaContinue = 'Continue';
  static const String ctaSave = 'Save';
  static const String ctaCancel = 'Cancel';
  static const String ctaClose = 'Close';

  // Modals
  static const String consentTitle = 'Consent';
  static const String paywallTitle = 'Paywall';
}
