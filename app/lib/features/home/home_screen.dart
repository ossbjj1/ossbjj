import 'package:flutter/material.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/strings.dart';
import '../../core/services/progress_service.dart';
import 'continue_card.dart';

/// Home Screen (Sprint 3).
///
/// MVP: Continue card.
/// Future: Content Roadmap, Testimonials.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.progressService,
  });

  final ProgressService progressService;

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navTitleHome),
        backgroundColor: DsColors.bgSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ContinueCard(progressService: progressService),
          ],
        ),
      ),
    );
  }
}
