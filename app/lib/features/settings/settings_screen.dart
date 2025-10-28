import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/strings.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/locale_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/consent_service.dart';
import '../../core/services/analytics_service.dart';

/// Settings Screen (Sprint 3).
///
/// MVP: Language, Audio, Privacy, Legal, Logout, Delete account (UI only).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.authService,
    required this.localeService,
    required this.audioService,
    required this.consentService,
    required this.analyticsService,
  });

  final AuthService authService;
  final LocaleService localeService;
  final AudioService audioService;
  final ConsentService consentService;
  final AnalyticsService analyticsService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _analyticsConsent = false;
  bool _mediaConsent = false;
  bool _analyticsBusy = false;

  @override
  void initState() {
    super.initState();
    _loadConsent();
  }

  Future<void> _loadConsent() async {
    // Ensure UI reflects server-authoritative consent before showing toggles
    try {
      await widget.consentService.syncAnalyticsFromServer();
    } catch (e) {
      debugPrint('Consent sync failed (analytics): $e');
    }
    final analytics = widget.consentService.analytics;
    final media = widget.consentService.media;
    if (mounted) {
      setState(() {
        _analyticsConsent = analytics;
        _mediaConsent = media;
      });
    }
  }

  Future<void> _handleAnalyticsToggle(bool value) async {
    // Busy guard: prevent double-tap races
    if (_analyticsBusy) return;

    final priorValue = _analyticsConsent;
    setState(() => _analyticsBusy = true);

    // Optimistic update
    setState(() => _analyticsConsent = value);

    try {
      await widget.consentService.setServerAnalytics(value);

      // Live init/deinit analytics
      if (value) {
        await widget.analyticsService.initIfAllowed(analyticsAllowed: true);
      } else {
        // Active opt-out: close Sentry, disable tracking (GDPR)
        await widget.analyticsService.optOutAndDisable();
      }
    } catch (e) {
      debugPrint('Analytics toggle failed: $e');
      // Revert on failure
      if (mounted) {
        setState(() => _analyticsConsent = priorValue);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsScope.of(context).settingsUpdateError),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _analyticsBusy = false);
      }
    }
  }

  Future<void> _handleMediaToggle(bool value) async {
    final priorValue = _mediaConsent;

    // Optimistic update
    setState(() => _mediaConsent = value);

    try {
      await widget.consentService.setMedia(value);
    } catch (e) {
      debugPrint('Media toggle failed: $e');
      // Revert on failure
      if (mounted) {
        setState(() => _mediaConsent = priorValue);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsScope.of(context).settingsUpdateError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await widget.authService.signOut();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logged out')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Logout failed: $e')),
        );
      }
    }
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final t = StringsScope.of(ctx);
        return Container(
          color: DsColors.bgSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  t.settingsLanguageNameDe,
                  style: const TextStyle(
                    color: DsColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  try {
                    await widget.localeService.setLocale(const Locale('de'));
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    debugPrint('Failed to set locale: $e');
                  }
                },
              ),
              ListTile(
                title: Text(
                  t.settingsLanguageNameEn,
                  style: const TextStyle(
                    color: DsColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  try {
                    await widget.localeService.setLocale(const Locale('en'));
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    debugPrint('Failed to set locale: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);
    final locale = StringsScope.localeOf(context);
    final languageLabel = locale.languageCode == 'de' ? 'Deutsch' : 'English';

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navTitleSettings),
        backgroundColor: DsColors.bgSurface,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(t.settingsLanguage),
            subtitle: Text(languageLabel),
            onTap: _showLanguagePicker,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: widget.audioService.audioEnabled,
            builder: (ctx, audioEnabled, _) {
              return SwitchListTile(
                secondary: const Icon(Icons.volume_up_outlined),
                title: Text(t.settingsAudio),
                value: audioEnabled,
                onChanged: (value) async {
                  final priorValue = audioEnabled;
                  try {
                    await widget.audioService.setEnabled(value);
                    // Optimistically updated via audioEnabled notifier
                  } catch (e) {
                    // Revert on failure
                    try {
                      await widget.audioService.setEnabled(priorValue);
                    } catch (_) {
                      // Ignore revert errors
                    }
                    if (mounted) {
                      final errorMsg = t.settingsUpdateError;
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMsg),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              );
            },
          ),
          const Divider(),
          // Privacy & Consent Section (Sprint 4)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              t.consentHeadline,
              style: const TextStyle(
                color: DsColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.analytics_outlined),
            title: Text(t.consentAnalyticsLabel),
            subtitle: Text(t.consentAnalyticsSub),
            value: _analyticsConsent,
            onChanged: _handleAnalyticsToggle,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.video_library_outlined),
            title: Text(t.consentMediaLabel),
            subtitle: Text(t.consentMediaSub),
            value: _mediaConsent,
            onChanged: _handleMediaToggle,
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(t.settingsPrivacy),
            subtitle: const Text('View detailed privacy settings'),
            onTap: () => context.go(AppRoutes.consentPath),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: Text(t.legalPrivacy),
            onTap: () => context.go(AppRoutes.privacyPath),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(t.legalTerms),
            onTap: () => context.go(AppRoutes.termsPath),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined),
            title: Text(t.settingsDeleteAccount),
            subtitle: Text(t.settingsDeleteDisabledHint),
            enabled: false,
            onTap: null,
          ),
          if (widget.authService.currentUser != null)
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: Text(t.settingsLogout),
              onTap: () => _handleLogout(context),
            ),
        ],
      ),
    );
  }
}
