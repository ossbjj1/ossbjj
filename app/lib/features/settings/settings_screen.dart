import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/strings.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/locale_service.dart';
import '../../core/services/audio_service.dart';

/// Settings Screen (Sprint 3).
///
/// MVP: Language, Audio, Privacy, Legal, Logout, Delete account (UI only).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.authService,
    required this.localeService,
    required this.audioService,
  });

  final AuthService authService;
  final LocaleService localeService;
  final AudioService audioService;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _settingsUpdateError;

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
        return Container(
          color: DsColors.bgSurface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text(
                  'Deutsch',
                  style: TextStyle(
                    color: DsColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  await widget.localeService.setLocale(const Locale('de'));
                  if (mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text(
                  'English',
                  style: TextStyle(
                    color: DsColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  await widget.localeService.setLocale(const Locale('en'));
                  if (mounted) Navigator.pop(context);
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
                    if (mounted) {
                      setState(() => _settingsUpdateError = null);
                    }
                  } catch (e) {
                    // Revert on failure
                    await widget.audioService.setEnabled(priorValue);
                    if (mounted) {
                      setState(() {
                        _settingsUpdateError =
                            'Failed to update audio setting: $e';
                      });
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_settingsUpdateError!),
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
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(t.settingsPrivacy),
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
