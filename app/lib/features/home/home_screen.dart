import 'package:flutter/material.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/app_strings.dart';

/// Home Screen (Sprint 1 stub).
///
/// Future: Hero card "Continue", Content Roadmap, Testimonials.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.navTitleHome),
        backgroundColor: DsColors.bgSurface,
      ),
      body: const Center(
        child: Text(
          'Home Screen\n(Sprint 1 stub)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: DsColors.textSecondary),
        ),
      ),
    );
  }
}
