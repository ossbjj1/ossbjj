import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
import 'core/config/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize shared logger for all services
  final logger = Logger();

  // Initialize Supabase as early as possible (fail-safe if not configured)
  if (Env.hasSupabase) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );
  } else {
    logger.w('Supabase not configured (SUPABASE_URL / SUPABASE_ANON_KEY missing).');
  }

  // Initialize services (Sprint 3 + Sprint 4) with shared logger
  final consentService = ConsentService(logger: logger);
  final analyticsService = AnalyticsService();
  final authService = AuthService();
  final profileService = ProfileService();
  final localeService = LocaleService();
  final audioService = AudioService();

  // Load local consent state (Sprint 2)
  await consentService.load();

  // Load locale
  await localeService.load();

  // Load audio preference
  await audioService.load();

  // Init Auth (Supabase) BEFORE using Supabase.instance anywhere
  await authService.init();

  // Now it's safe to create services depending on Supabase.instance
  final progressService =
      ProgressService(Supabase.instance.client, logger: logger);
  final gatingService = GatingService(logger: logger);

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

  // Use in-memory consent state after sync (avoid extra disk read)
  final consentStateFinal = ConsentState(
    analytics: consentService.analytics,
    media: consentService.media,
    shown: consentService.shown,
  );

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

  runApp(ProviderScope(
    child: OssApp(
      router: router,
      localeService: localeService,
    ),
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
