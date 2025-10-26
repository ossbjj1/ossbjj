import 'package:flutter/material.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/l10n/app_strings.dart';

/// Terms of Service screen (Sprint 2).
///
/// MVP: Placeholder text. Production: link to hosted terms or embed full text.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.legalTerms),
        backgroundColor: DsColors.bgSurface,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(DsSpacing.md),
        child: Text(
          AppStrings.legalTermsBody,
          style: TextStyle(
            fontSize: 16,
            color: DsColors.textSecondary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
