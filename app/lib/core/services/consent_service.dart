import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Consent management service (Sprint 2 + Sprint 4).
///
/// Handles user consent for analytics and media processing.
/// DSGVO/GDPR compliant: opt-in required, stored locally + server-synced.
/// Sprint 4: Server as Single Source of Truth for analytics consent.
class ConsentService {
  ConsentService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

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

  /// Revoke all consent (DSGVO right to withdraw).
  Future<void> revokeConsent() async {
    _analytics = false;
    _media = false;
    _shown = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAnalytics);
    await prefs.remove(_keyMedia);
    await prefs.remove(_keyShown);
  }

  /// Fetch analytics consent from server (user_profile.consent_analytics).
  /// Sprint 4: Server as SoT.
  Future<bool> fetchServerAnalytics() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot fetch server consent: user not logged in');
    }

    try {
      final response = await Supabase.instance.client
          .from('user_profile')
          .select('consent_analytics')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        return false; // No profile row yet
      }

      return response['consent_analytics'] as bool? ?? false;
    } catch (e, stackTrace) {
      _logger.e('Fetch server consent failed',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Set analytics consent on server (UPDATE user_profile).
  /// Sprint 4: Write to server, then sync local.
  /// Ensures profile row exists first, validates response, mirrors locally on success.
  Future<void> setServerAnalytics(bool value) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot set server consent: user not logged in');
    }

    try {
      // Ensure profile row exists first (idempotent)
      await _ensureUserProfile();

      // Update and check response (expect ≥1 row affected)
      final response = await Supabase.instance.client
          .from('user_profile')
          .update({'consent_analytics': value})
          .eq('user_id', user.id)
          .select();

      // Validate: response should contain the updated row
      if (response.isEmpty) {
        throw Exception(
            'Server consent UPDATE affected no rows (row may have been deleted)');
      }

      _logger.i('Server consent updated: $value');
      // Mirror locally only after confirmed server write
      await setAnalytics(value);
    } catch (e, stackTrace) {
      _logger.e('Set server consent failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Sync analytics consent from server to local (login hook).
  /// Server is SoT; local is mirror.
  /// Sprint 4: Call on app start after auth.
  /// Auth guard: returns early if user not authenticated.
  Future<void> syncAnalyticsFromServer() async {
    // Auth guard: only sync if user is logged in
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _logger.w('Consent sync skipped: user not authenticated');
      return; // No-op; local value remains as fallback
    }

    try {
      // Ensure profile row exists (idempotent)
      await _ensureUserProfile();

      final serverValue = await fetchServerAnalytics();
      await setAnalytics(serverValue);
      _logger.i('Consent synced from server: $serverValue');
    } catch (e, stackTrace) {
      _logger.e('Consent sync failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Ensure user_profile row exists (idempotent insert).
  Future<void> _ensureUserProfile() async {
    try {
      await Supabase.instance.client.rpc('ensure_user_profile');
    } catch (e, stackTrace) {
      _logger.e('ensure_user_profile RPC failed',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
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
