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
  static const String consentTitle = 'Privacy & Consent';
  static const String paywallTitle = 'Paywall';

  // Consent
  static const String consentHeadline = 'Control your data.';
  static const String consentSubhead =
      'Choose what you share. Change anytime in Settings.';
  static const String consentAnalyticsLabel = 'Allow analytics';
  static const String consentAnalyticsSub = 'Error reports & usage stats';
  static const String consentMediaLabel = 'Allow media';
  static const String consentMediaSub = 'Previews & offline downloads';
  static const String consentSave = 'Save Preferences';

  // Legal
  static const String legalPrivacy = 'Privacy Policy';
  static const String legalTerms = 'Terms of Service';
  static const String legalPrivacyBody =
      'This is a placeholder for the Privacy Policy.\n\nIn production, link to your hosted policy or embed full text here.';
  static const String legalTermsBody =
      'This is a placeholder for the Terms of Service.\n\nIn production, link to your hosted terms or embed full text here.';

  // Settings
  static const String settingsPrivacy = 'Privacy settings';
  static const String settingsLogout = 'Log out';

  // Reset password
  static const String resetErrorGeneric =
      'Could not send reset email. Please try again.';
}
