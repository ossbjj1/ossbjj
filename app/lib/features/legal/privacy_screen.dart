import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import 'legal_document_screen.dart';

/// Privacy Policy screen (Sprint 2).
/// Delegates to reusable LegalDocumentScreen.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: AppStrings.legalPrivacy,
      body: AppStrings.legalPrivacyBody,
    );
  }
}
