import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/l10n/strings.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/progress_service.dart';

/// Continue card for Home screen (Sprint 3 MVP).
class ContinueCard extends StatelessWidget {
  const ContinueCard({
    super.key,
    required this.progressService,
  });

  final ProgressService progressService;

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return FutureBuilder<ContinueHint?>(
      future: progressService.loadLast(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final hint = snapshot.data;

        return Card(
          color: DsColors.bgSurface,
          margin: const EdgeInsets.all(DsSpacing.lg),
          child: Padding(
            padding: const EdgeInsets.all(DsSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.homeContinueTitle,
                  style: DsTypography.headlineMedium.copyWith(
                    color: DsColors.textPrimary,
                  ),
                ),
                const SizedBox(height: DsSpacing.md),
                if (hint != null)
                  Text(
                    hint.title,
                    style: DsTypography.bodyMedium.copyWith(
                      color: DsColors.textSecondary,
                    ),
                  )
                else
                  Text(
                    t.homeStartOnboarding,
                    style: DsTypography.bodyMedium.copyWith(
                      color: DsColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: DsSpacing.lg),
                ElevatedButton(
                  onPressed: () {
                    if (hint != null) {
                      // Future: navigate to step player with hint.stepId
                      context.go(AppRoutes.learnPath);
                    } else {
                      context.go(AppRoutes.onboardingPath);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DsColors.brandRed,
                    foregroundColor: DsColors.textPrimary,
                  ),
                  child: Text(t.ctaContinue),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
