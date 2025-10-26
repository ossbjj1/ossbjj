import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import 'core/services/consent_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/profile_service.dart';
import 'core/services/locale_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/progress_service.dart';
import 'core/services/gating_service.dart';
import 'core/l10n/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger for startup errors
  final logger = Logger();

  // Initialize services (Sprint 3 + Sprint 4)
  final consentService = ConsentService();
  final analyticsService = AnalyticsService();
  final authService = AuthService();
  final profileService = ProfileService();
  final localeService = LocaleService();
  final audioService = AudioService();
  final progressService = ProgressService();
  final gatingService = GatingService();

  // Load local consent state (Sprint 2)
  await consentService.load();

  // Load locale
  await localeService.load();

  // Load audio preference
  await audioService.load();

  // Init Auth (Supabase)
  await authService.init();

  // Sprint 4: Sync consent from server (if logged in)
  if (authService.currentUser != null) {
    try {
      await consentService.syncAnalyticsFromServer();
    } catch (e, stackTrace) {
      // Log but continue; local value is fallback
      logger.e('Consent sync failed during startup',
          error: e, stackTrace: stackTrace);
    }
  }

  // Reload consent state after sync
  final consentStateFinal = await consentService.load();

  // Check if onboarding needed
  bool forceOnboarding = false;
  if (authService.currentUser != null) {
    final profile = await profileService.fetch();
    if (profile == null || !profile.isComplete) {
      forceOnboarding = true;
    }
  }
  // Init Analytics only if consent granted (after sync)
  await analyticsService.initIfAllowed(
    analyticsAllowed: consentStateFinal.analytics,
  );

  // Create router with consent + onboarding redirect
  final router = createRouter(
    forceConsent: !consentStateFinal.shown,
    forceOnboarding: forceOnboarding,
    consentService: consentService,
    analyticsService: analyticsService,
    authService: authService,
    profileService: profileService,
    localeService: localeService,
    audioService: audioService,
    progressService: progressService,
    gatingService: gatingService,
  );

  runApp(OssApp(
    router: router,
    localeService: localeService,
  ));
}

/// OSS App entry point (Sprint 3).
class OssApp extends StatelessWidget {
  const OssApp({
    super.key,
    required this.router,
    required this.localeService,
  });

  final GoRouter router;
  final LocaleService localeService;

  @override
  Widget build(BuildContext context) {
    return StringsScope(
      localeNotifier: localeService.localeNotifier,
      child: MaterialApp.router(
        title: 'OSS',
        theme: AppTheme.buildDarkTheme(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
