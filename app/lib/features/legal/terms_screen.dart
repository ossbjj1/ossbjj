import 'package:flutter/material.dart';
import '../../core/l10n/strings.dart';
import 'legal_document_screen.dart';

/// Terms of Service screen (Sprint 2).
/// Delegates to reusable LegalDocumentScreen.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return LegalDocumentScreen(
      title: t.legalTerms,
      body: t.legalTermsBody,
    );
  }
}
