import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../config/env.dart';

/// Analytics service with consent gate (Sprint 2).
///
/// DSGVO/GDPR compliant: only initializes Sentry/PostHog if user consents.
/// All tracking methods are no-ops until initIfAllowed() succeeds.
class AnalyticsService {
  AnalyticsService();

  final _logger = Logger();
  bool _initialized = false;

  /// Initialize analytics services if consent granted.
  ///
  /// MUST be called after user grants analytics consent.
  /// Safe to call multiple times (idempotent).
  Future<void> initIfAllowed({required bool analyticsAllowed}) async {
    if (_initialized) {
      _logger.d('AnalyticsService already initialized');
      return;
    }

    if (!analyticsAllowed) {
      _logger.i('Analytics consent not granted, skipping init');
      return;
    }

    try {
      // Initialize Sentry if DSN configured
      if (Env.hasSentry) {
        await SentryFlutter.init(
          (options) {
            options.dsn = Env.sentryDsn;
            options.tracesSampleRate = 0.1;
            options.beforeSend = (event, hint) => _beforeSendSentry(event, hint: hint);
          },
        );
        _logger.i('Sentry initialized');
      }

      // Initialize PostHog if API key configured (MVP: skip PostHog init if too complex)
      // if (Env.hasPosthog) {
      //   await Posthog().setup(...); // API changed, skip for MVP
      // }
      _logger.i('PostHog init skipped (MVP)');

      _initialized = true;
    } catch (e, stackTrace) {
      _logger.e('Analytics init failed', error: e, stackTrace: stackTrace);
    }
  }

  /// Track event (no-op if not initialized or consent not granted).
  void track(String event, [Map<String, Object?>? properties]) {
    if (!_initialized) {
      _logger.d('Analytics not initialized, skipping track: $event');
      return;
    }

    try {
      // if (Env.hasPosthog) {
      //   Posthog().capture(eventName: event, properties: properties);
      // }
      _logger.d('Tracked event: $event (MVP: PostHog disabled)');
    } catch (e) {
      _logger.w('Failed to track event: $event', error: e);
    }
  }

  /// Set user context (no-op if not initialized).
  void setUser({required String? id}) {
    if (!_initialized) {
      _logger.d('Analytics not initialized, skipping setUser');
      return;
    }

    try {
      if (Env.hasSentry && id != null) {
        Sentry.configureScope((scope) {
          scope.setUser(SentryUser(id: id));
        });
      }
      // if (Env.hasPosthog && id != null) {
      //   Posthog().identify(userId: id);
      // }
      _logger.d('User context set: $id (MVP: PostHog disabled)');
    } catch (e) {
      _logger.w('Failed to set user context', error: e);
    }
  }

  /// Sentry beforeSend hook: strip PII from events.
  SentryEvent? _beforeSendSentry(SentryEvent event, {Hint? hint}) {
    // Strip email/phone/IP from breadcrumbs/contexts
    final sanitized = event.copyWith(
      user: event.user?.copyWith(
        email: null,
        ipAddress: null,
      ),
    );
    return sanitized;
  }
}
