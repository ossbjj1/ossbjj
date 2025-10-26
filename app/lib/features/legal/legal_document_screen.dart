import 'package:flutter/material.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';

/// Reusable widget for legal document screens (Privacy, Terms).
/// Eliminates duplication between PrivacyScreen and TermsScreen.
class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: DsColors.bgSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(DsSpacing.md),
        child: Text(
          body,
          style: const TextStyle(
            fontSize: 16,
            color: DsColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
