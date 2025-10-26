import 'package:flutter/material.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/app_strings.dart';

/// Consent Modal (Sprint 1 stub).
///
/// Future (Sprint 2): Toggles for Analytics/Media, Privacy/TOS links.
class ConsentModal extends StatelessWidget {
  const ConsentModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.consentTitle),
        backgroundColor: DsColors.bgSurface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: const Center(
        child: Text(
          'Consent Modal\n(Sprint 1 stub)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: DsColors.textSecondary),
        ),
      ),
    );
  }
}
