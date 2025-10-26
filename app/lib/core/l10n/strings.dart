import 'package:flutter/material.dart';

/// Runtime i18n strings (Sprint 3 MVP).
///
/// Supports DE/EN via Locale. Future: migrate to ARB + flutter_localizations.
/// TODO(i18n): Move all string literals to ARB files and use flutter_localizations
/// for compile-time safety and automatic pluralization/formatting.
///
/// String keys are defined as const to enable type-safe lookups during migration.
class Strings {
  const Strings._({required this.locale});

  final Locale locale;

  factory Strings.of(Locale locale) {
    return Strings._(locale: locale);
  }

  bool get isDe => locale.languageCode == 'de';

  // Tabs
  String get tabHome => isDe ? 'Home' : 'Home';
  String get tabLearn => isDe ? 'Lernen' : 'Learn';
  String get tabStats => isDe ? 'Statistik' : 'Stats';
  String get tabSettings => isDe ? 'Einstellungen' : 'Settings';

  // Nav titles
  String get navTitleHome => isDe ? 'Home' : 'Home';
  String get navTitleLearn => isDe ? 'Lernen' : 'Learn';
  String get navTitleStats => isDe ? 'Statistik' : 'Stats';
  String get navTitleSettings => isDe ? 'Einstellungen' : 'Settings';

  // CTAs
  String get ctaContinue => isDe ? 'Weiter' : 'Continue';
  String get ctaComplete => isDe ? 'Abschließen' : 'Complete';
  String get ctaSave => isDe ? 'Speichern' : 'Save';
  String get ctaCancel => isDe ? 'Abbrechen' : 'Cancel';
  String get ctaClose => isDe ? 'Schließen' : 'Close';

  // Consent
  String get consentTitle => isDe ? 'Deine Zustimmung' : 'Your consent';
  String get consentHeadline =>
      isDe ? 'Deine Daten. Deine Wahl.' : 'Your data. Your choice.';
  String get consentSubhead => isDe
      ? 'Wähle, was du teilst. Änderbar in Einstellungen.'
      : 'Choose what you share. Change anytime in Settings.';
  String get consentAnalyticsLabel =>
      isDe ? 'Analytics zulassen' : 'Allow analytics';
  String get consentAnalyticsSub => isDe
      ? 'Fehlerberichte & Nutzungsstatistik'
      : 'Error reports & usage stats';
  String get consentMediaLabel => isDe ? 'Medien zulassen' : 'Allow media';
  String get consentMediaSub =>
      isDe ? 'Vorschauen & Offline-Downloads' : 'Previews & offline downloads';
  String get consentSave => isDe ? 'Speichern' : 'Save Preferences';

  // Legal
  String get legalPrivacy => isDe ? 'Datenschutz' : 'Privacy Policy';
  String get legalTerms => isDe ? 'AGB' : 'Terms of Service';
  String get legalPrivacyBody => isDe
      ? 'Platzhalter für Datenschutzerklärung.\n\nIn Produktion: Link zu gehosteter Policy oder vollständiger Text.'
      : 'This is a placeholder for the Privacy Policy.\n\nIn production, link to your hosted policy or embed full text here.';
  String get legalTermsBody => isDe
      ? 'Platzhalter für AGB.\n\nIn Produktion: Link zu gehosteten AGB oder vollständiger Text.'
      : 'This is a placeholder for the Terms of Service.\n\nIn production, link to your hosted terms or embed full text here.';

  // Settings
  String get settingsPrivacy =>
      isDe ? 'Datenschutz-Einstellungen' : 'Privacy settings';
  String get settingsLanguage => isDe ? 'Sprache' : 'Language';
  String get settingsLanguageNameDe => 'Deutsch';
  String get settingsLanguageNameEn => 'English';
  String get settingsAudio => isDe ? 'Audio-Feedback' : 'Audio feedback';
  String get settingsUpdateError => isDe
      ? 'Einstellung konnte nicht gespeichert werden'
      : 'Failed to save setting';
  String get settingsDeleteAccount =>
      isDe ? 'Konto & Daten löschen' : 'Delete account & data';
  String get settingsLogout => isDe ? 'Abmelden' : 'Log out';
  String get settingsDeleteDisabledHint =>
      isDe ? 'Kommt in Sprint 6' : 'Coming in Sprint 6';

  // Onboarding
  String get onboardingHeadline =>
      isDe ? 'Zeit auf der Matte. Los.' : 'Time on the mat. Go.';
  String get onboardingBelt => isDe ? 'Dein Gürtel?' : 'Your belt?';
  String get onboardingExperience => isDe ? 'Erfahrung?' : 'Experience?';
  String get onboardingWeeklyGoal =>
      isDe ? 'Wochenziel (Tage)?' : 'Weekly goal (days)?';
  String get onboardingGoalType => isDe ? 'Trainingsziel?' : 'Training goal?';
  String get onboardingAgeGroup =>
      isDe ? 'Altersgruppe (optional)' : 'Age group (optional)';
  String get onboardingSave => isDe ? 'Profil speichern' : 'Save Profile';
  String get onboardingSuccess =>
      isDe ? 'Profil gespeichert!' : 'Profile saved!';

  // Belt options
  String get beltWhite => isDe ? 'Weißgurt' : 'White';
  String get beltBlue => isDe ? 'Blaugurt' : 'Blue';
  String get beltPurple => isDe ? 'Lila' : 'Purple';
  String get beltBrown => isDe ? 'Braun' : 'Brown';
  String get beltBlack => isDe ? 'Schwarzgurt' : 'Black';

  // Experience
  String get expBeginner => isDe ? 'Anfänger' : 'Beginner';
  String get expIntermediate => isDe ? 'Fortgeschritten' : 'Intermediate';
  String get expAdvanced => isDe ? 'Profi' : 'Advanced';

  // Goal types
  String get goalFundamentals => isDe ? 'Grundlagen' : 'Fundamentals';
  String get goalTechnique => isDe ? 'Technik' : 'Technique';
  String get goalStrength => isDe ? 'Kraft' : 'Strength';
  String get goalFlexibility => isDe ? 'Flexibilität' : 'Flexibility';

  // Age groups
  String get ageU18 => isDe ? 'Unter 18' : 'Under 18';
  String get age1830 => isDe ? '18-30' : '18-30';
  String get age3040 => isDe ? '30-40' : '30-40';
  String get age40Plus => isDe ? '40+' : '40+';

  // Home
  String get homeContinueTitle => isDe ? 'Weiter machen' : 'Continue';
  String get homeStartOnboarding =>
      isDe ? 'Onboarding starten' : 'Start Onboarding';
  String get unableToLoadContinueHint => isDe
      ? 'Weiter-Hinweis konnte nicht geladen werden'
      : 'Unable to load continue hint';

  // Paywall
  String get paywallTitle => isDe ? 'Paywall' : 'Paywall';

  // Step Player
  String get stepCompleted => isDe ? 'Schritt abgeschlossen!' : 'Step completed!';

  /// Error messages.
  String get errorGeneric =>
      isDe ? 'Ein Fehler ist aufgetreten' : 'An error occurred';
}

/// InheritedNotifier for Strings (live language switching).
class StringsScope extends InheritedNotifier<ValueNotifier<Locale>> {
  const StringsScope({
    super.key,
    required ValueNotifier<Locale> localeNotifier,
    required super.child,
  }) : super(notifier: localeNotifier);

  /// Access Strings for current locale.
  static Strings of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StringsScope>();
    if (scope == null) {
      throw FlutterError('StringsScope not found in widget tree');
    }
    return Strings.of(scope.notifier!.value);
  }

  /// Access Strings or return null if StringsScope is not in widget tree.
  /// Use this for safe access in tests or optional UI contexts.
  static Strings? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StringsScope>();
    if (scope == null) return null;
    return Strings.of(scope.notifier!.value);
  }

  /// Access Strings or fallback to English default.
  /// Useful for tests that don't wrap widgets in StringsScope.
  static Strings maybeOrDefault(BuildContext context) {
    return maybeOf(context) ?? Strings.of(const Locale('en'));
  }

  /// Access current Locale.
  static Locale localeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StringsScope>();
    if (scope == null) {
      throw FlutterError('StringsScope not found in widget tree');
    }
    return scope.notifier!.value;
  }

  /// Access current Locale or return null if StringsScope is not in widget tree.
  static Locale? maybeLocaleOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<StringsScope>();
    return scope?.notifier?.value;
  }
}
