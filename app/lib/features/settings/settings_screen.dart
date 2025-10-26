import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/auth_service.dart';

/// Settings Screen (Sprint 2).
///
/// MVP: Privacy Settings, Legal links, Logout.
/// Future (Sprint 3): Language, Audio feedback, Delete account.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.authService,
  });

  final AuthService authService;

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await authService.signOut();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navTitleSettings),
        backgroundColor: DsColors.bgSurface,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text(AppStrings.settingsPrivacy),
            onTap: () => context.go(AppRoutes.consentPath),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.policy_outlined),
            title: const Text(AppStrings.legalPrivacy),
            onTap: () => context.go(AppRoutes.privacyPath),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text(AppStrings.legalTerms),
            onTap: () => context.go(AppRoutes.termsPath),
          ),
          const Divider(),
          if (authService.currentUser != null)
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text(AppStrings.settingsLogout),
              onTap: () => _handleLogout(context),
            ),
        ],
      ),
    );
  }
}
