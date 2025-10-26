import 'package:flutter/material.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/l10n/strings.dart';

/// Stats Screen (Sprint 1 stub).
///
/// Future (Sprint 7): Streak, completed steps/techniques, achievements.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navTitleStats),
        backgroundColor: DsColors.bgSurface,
      ),
      body: const Center(
        child: Text(
          'Stats Screen\n(Sprint 1 stub)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: DsColors.textSecondary),
        ),
      ),
    );
  }
}
