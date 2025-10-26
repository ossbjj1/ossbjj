import 'package:shared_preferences/shared_preferences.dart';

/// Consent management service (Sprint 2).
///
/// Handles user consent for analytics and media processing.
/// DSGVO/GDPR compliant: opt-in required, stored locally.
class ConsentService {
  ConsentService();

  static const _keyAnalytics = 'consent.analytics';
  static const _keyMedia = 'consent.media';
  static const _keyShown = 'consent.shown';

  bool _analytics = false;
  bool _media = false;
  bool _shown = false;

  /// Has consent modal been shown to user?
  bool get shown => _shown;

  /// Analytics consent granted?
  bool get analytics => _analytics;

  /// Media consent granted?
  bool get media => _media;

  /// Load consent state from persistent storage.
  Future<ConsentState> load() async {
    final prefs = await SharedPreferences.getInstance();
    _analytics = prefs.getBool(_keyAnalytics) ?? false;
    _media = prefs.getBool(_keyMedia) ?? false;
    _shown = prefs.getBool(_keyShown) ?? false;
    return ConsentState(
      analytics: _analytics,
      media: _media,
      shown: _shown,
    );
  }

  /// Update analytics consent.
  Future<void> setAnalytics(bool value) async {
    _analytics = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAnalytics, value);
  }

  /// Update media consent.
  Future<void> setMedia(bool value) async {
    _media = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMedia, value);
  }

  /// Mark consent modal as shown.
  Future<void> markShown() async {
    _shown = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShown, true);
  }
}

/// Immutable consent state snapshot.
class ConsentState {
  const ConsentState({
    required this.analytics,
    required this.media,
    required this.shown,
  });

  final bool analytics;
  final bool media;
  final bool shown;
}
