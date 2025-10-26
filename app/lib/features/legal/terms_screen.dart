import 'package:flutter/material.dart';
import '../../core/l10n/app_strings.dart';
import 'legal_document_screen.dart';

/// Terms of Service screen (Sprint 2).
/// Delegates to reusable LegalDocumentScreen.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalDocumentScreen(
      title: AppStrings.legalTerms,
      body: AppStrings.legalTermsBody,
    );
  }
}
