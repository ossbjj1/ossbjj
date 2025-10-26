import 'package:flutter/material.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/app_strings.dart';

/// Settings Screen (Sprint 1 stub).
///
/// Future (Sprint 3): Language, Consent toggles, Audio feedback, Logout, Delete account.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navTitleSettings),
        backgroundColor: DsColors.bgSurface,
      ),
      body: const Center(
        child: Text(
          'Settings Screen\n(Sprint 1 stub)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: DsColors.textSecondary),
        ),
      ),
    );
  }
}
