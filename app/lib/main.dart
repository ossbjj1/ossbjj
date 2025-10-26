import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import 'core/services/consent_service.dart';
import 'core/services/analytics_service.dart';
import 'core/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services (Sprint 2)
  final consentService = ConsentService();
  final analyticsService = AnalyticsService();
  final authService = AuthService();

  // Load consent state
  final consentState = await consentService.load();

  // Init Auth (Supabase)
  await authService.init();

  // Init Analytics only if consent granted
  await analyticsService.initIfAllowed(
    analyticsAllowed: consentState.analytics,
  );

  // Create router with consent redirect
  final router = createRouter(
    forceConsent: !consentState.shown,
    consentService: consentService,
    analyticsService: analyticsService,
    authService: authService,
  );

  runApp(OssApp(router: router));
}

/// OSS App entry point.
class OssApp extends StatelessWidget {
  const OssApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OSS',
      theme: AppTheme.buildDarkTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
