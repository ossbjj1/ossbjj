import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/l10n/strings.dart';
import '../../core/services/gating_service.dart';

/// Step Player Screen (Sprint 4 MVP).
///
/// Minimal placeholder: displays stepId, "Complete" button.
/// Future: Video player, controls, hints.
class StepPlayerScreen extends StatefulWidget {
  const StepPlayerScreen({
    super.key,
    required this.stepId,
    required this.gatingService,
  });

  final String stepId;
  final GatingService gatingService;

  @override
  State<StepPlayerScreen> createState() => _StepPlayerScreenState();
}

class _StepPlayerScreenState extends State<StepPlayerScreen> {
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DsColors.bgSurface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(DsSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Step Player MVP',
              key: const Key('step_player_title'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: DsSpacing.md),
            Text(
              'Step ID: ${widget.stepId}',
              key: const Key('step_player_step_id'),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: DsSpacing.xxl),
            ElevatedButton(
              key: const Key('step_player_complete_button'),
              onPressed: _isCompleting ? null : _handleComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _isCompleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.ctaContinue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleComplete() async {
    setState(() => _isCompleting = true);

    try {
      final result = await widget.gatingService.completeStep(widget.stepId);

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Step completed!')),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: DsColors.stateError,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final t = StringsScope.of(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.errorGeneric),
          backgroundColor: DsColors.stateError,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }
}
