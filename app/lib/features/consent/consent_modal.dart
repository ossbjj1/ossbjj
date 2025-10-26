import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/l10n/strings.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/consent_service.dart';
import '../../core/services/analytics_service.dart';

/// Consent Modal (Sprint 2).
///
/// DSGVO-compliant: opt-in required for analytics/media.
class ConsentModal extends StatefulWidget {
  const ConsentModal({
    super.key,
    required this.consentService,
    required this.analyticsService,
  });

  final ConsentService consentService;
  final AnalyticsService analyticsService;

  @override
  State<ConsentModal> createState() => _ConsentModalState();
}

class _ConsentModalState extends State<ConsentModal> {
  late bool _analytics;
  late bool _media;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _analytics = widget.consentService.analytics;
    _media = widget.consentService.media;
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      await widget.consentService.setAnalytics(_analytics);
      await widget.consentService.setMedia(_media);
      await widget.consentService.markShown();

      // Re-initialize analytics if consent granted
      await widget.analyticsService.initIfAllowed(
        analyticsAllowed: _analytics,
      );

      if (mounted) {
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = StringsScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.consentTitle),
        backgroundColor: DsColors.bgSurface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.consentHeadline,
                style: DsTypography.headlineMedium.copyWith(
                  color: DsColors.textPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.xs),
              Text(
                t.consentSubhead,
                style: DsTypography.bodyMedium.copyWith(
                  color: DsColors.textSecondary,
                ),
              ),
              const SizedBox(height: DsSpacing.lg),
              SwitchListTile(
                value: _analytics,
                onChanged: (value) => setState(() => _analytics = value),
                title: Text(t.consentAnalyticsLabel),
                subtitle: Text(t.consentAnalyticsSub),
                activeTrackColor: DsColors.brandRed,
              ),
              SwitchListTile(
                value: _media,
                onChanged: (value) => setState(() => _media = value),
                title: Text(t.consentMediaLabel),
                subtitle: Text(t.consentMediaSub),
                activeTrackColor: DsColors.brandRed,
              ),
              const SizedBox(height: DsSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () => context.go(AppRoutes.privacyPath),
                    child: Text(t.legalPrivacy),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.termsPath),
                    child: Text(t.legalTerms),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DsColors.brandRed,
                    foregroundColor: DsColors.textPrimary,
                    padding: const EdgeInsets.symmetric(
                      vertical: DsSpacing.md,
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: DsColors.textPrimary,
                          ),
                        )
                      : Text(t.consentSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
