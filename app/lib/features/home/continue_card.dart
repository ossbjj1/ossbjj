import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/l10n/strings.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/progress_service.dart'
    show ProgressService, NextStepResult;
import '../../core/services/gating_service.dart';

/// Continue card for Home screen (Sprint 3 MVP + Sprint 4).
class ContinueCard extends StatefulWidget {
  const ContinueCard({
    super.key,
    required this.progressService,
    required this.gatingService,
  });

  final ProgressService progressService;
  final GatingService gatingService;

  @override
  State<ContinueCard> createState() => _ContinueCardState();
}

class _ContinueCardState extends State<ContinueCard> {
  late Future<NextStepResult?> _nextStepFuture;

  @override
  void initState() {
    super.initState();
    // Cache the future once to avoid recreating on every rebuild
    _nextStepFuture = widget.progressService.getNextStep();
  }

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return FutureBuilder<NextStepResult?>(
      future: _nextStepFuture,
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return Card(
            color: DsColors.bgSurface,
            margin: const EdgeInsets.all(DsSpacing.lg),
            child: Padding(
              padding: const EdgeInsets.all(DsSpacing.lg),
              child: Center(
                child: Text(
                  t.unableToLoadContinueHint,
                  style: DsTypography.bodyMedium.copyWith(
                    color: DsColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show sized loading placeholder instead of full-screen spinner
          return Card(
            color: DsColors.bgSurface,
            margin: const EdgeInsets.all(DsSpacing.lg),
            child: SizedBox(
              height: 120,
              child: Center(
                child: CircularProgressIndicator(
                  key: const Key('continue_card_loading'),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
          );
        }

        final nextStep = snapshot.data;
        final locale = Localizations.localeOf(context).languageCode;

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
                if (nextStep != null)
                  Text(
                    locale == 'de' ? nextStep.titleDe : nextStep.titleEn,
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
                  key: nextStep != null
                      ? const Key('continue_card_continue_button')
                      : const Key('continue_card_onboarding_button'),
                  onPressed: nextStep != null
                      ? () => _handleContinue(nextStep)
                      : () => context.go(AppRoutes.onboardingPath),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(
                    nextStep != null ? t.ctaContinue : t.onboardingSave,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handle continue button press (Sprint 4: gating idx>=3 + navigation).
  /// Uses State's context property to avoid use_build_context_synchronously warnings.
  Future<void> _handleContinue(NextStepResult nextStep) async {
    try {
      // Gating: Steps 1-2 free, idx>=3 requires premium
      if (nextStep.idx >= 3) {
        final access =
            await widget.gatingService.checkStepAccess(nextStep.stepId);

        if (!mounted) return;

        if (!access.allowed) {
          // Navigate to paywall
          context.go(AppRoutes.paywallPath);
          return;
        }
      }

      if (!mounted) return;

      // Navigate to step player
      context.go('/step/${nextStep.stepId}');
    } catch (e) {
      if (!mounted) return;
      final t = StringsScope.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.errorGeneric), // Gating access check failed
          backgroundColor: DsColors.stateError,
        ),
      );
    }
  }
}
