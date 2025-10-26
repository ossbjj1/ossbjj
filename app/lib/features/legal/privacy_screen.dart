import 'package:flutter/material.dart';
import '../../core/l10n/strings.dart';
import 'legal_document_screen.dart';

/// Privacy Policy screen (Sprint 2).
/// Delegates to reusable LegalDocumentScreen.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return LegalDocumentScreen(
      title: t.legalPrivacy,
      body: t.legalPrivacyBody,
    );
  }
}
