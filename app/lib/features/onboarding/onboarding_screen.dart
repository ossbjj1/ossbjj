import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_tokens/colors.dart';
import '../../core/design_tokens/spacing.dart';
import '../../core/design_tokens/typography.dart';
import '../../core/l10n/strings.dart';
import '../../core/navigation/routes.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/consent_service.dart';

/// Onboarding Screen (Sprint 3).
///
/// Collects user profile: belt, experience, weekly goal, goal type, age group.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.profileService,
    required this.analyticsService,
    required this.consentService,
  });

  final ProfileService profileService;
  final AnalyticsService analyticsService;
  final ConsentService consentService;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _belt;
  String? _expRange;
  int _weeklyGoal = 3;
  String? _goalType;
  String? _ageGroup;
  bool _saving = false;

  // Timer state (Sprint 4)
  Timer? _timer;
  DateTime? _firstInputAt;
  int _elapsedSeconds = 0;
  bool _autosaved = false;
  static const _autosaveThresholdSec = 60;

  bool get _canSave => _belt != null && _expRange != null && _goalType != null;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Start timer on first user input (Sprint 4).
  void _startTimerIfNeeded() {
    if (_firstInputAt != null) return; // Already started

    _firstInputAt = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _elapsedSeconds = DateTime.now().difference(_firstInputAt!).inSeconds;
      });

      // Autosave at 60s (once)
      if (_elapsedSeconds >= _autosaveThresholdSec && !_autosaved) {
        _autosave();
      }
    });
  }

  /// Autosave draft profile at 60s (Sprint 4).
  Future<void> _autosave() async {
    if (_autosaved) return;
    _autosaved = true;

    try {
      final profile = UserProfile(
        belt: _belt,
        expRange: _expRange,
        weeklyGoal: _weeklyGoal,
        goalType: _goalType,
        ageGroup: _ageGroup,
      );

      await widget.profileService.upsert(profile, draft: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsScope.of(context).onboardingAutosaved),
            backgroundColor: DsColors.stateInfo,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // Telemetry (if consent granted)
      if (widget.consentService.analytics) {
        widget.analyticsService.track('onboarding_autosave', {
          'elapsed_seconds': _elapsedSeconds,
        });
      }
    } catch (e) {
      debugPrint('Onboarding autosave error: $e');
      // Non-critical: don't show error to user, just log
    }
  }

  Future<void> _save() async {
    if (!_canSave) return;

    setState(() => _saving = true);

    try {
      final profile = UserProfile(
        belt: _belt,
        expRange: _expRange,
        weeklyGoal: _weeklyGoal,
        goalType: _goalType,
        ageGroup: _ageGroup,
      );

      await widget.profileService.upsert(profile); // draft=false (default)

      // Telemetry (if consent granted)
      if (widget.consentService.analytics) {
        widget.analyticsService.track('onboarding_complete', {
          'duration_seconds': _elapsedSeconds,
          'autosaved': _autosaved,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsScope.of(context).onboardingSuccess),
            backgroundColor: Colors.green,
          ),
        );
        context.go(AppRoutes.homePath);
      }
    } catch (e) {
      if (mounted) {
        debugPrint('Onboarding save error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(StringsScope.of(context).errorGeneric),
            backgroundColor: Colors.red,
          ),
        );
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
    final showCountdown = _elapsedSeconds >= 45 && !_autosaved;
    final secondsLeft = _autosaveThresholdSec - _elapsedSeconds;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: DsColors.bgSurface,
        actions: [
          // Countdown badge (visible from 45s until autosave)
          if (showCountdown)
            Padding(
              padding: const EdgeInsets.only(right: DsSpacing.md),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DsSpacing.sm,
                    vertical: DsSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: DsColors.brandRed,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    t.onboardingTimeLeft(secondsLeft),
                    style: DsTypography.bodyMedium.copyWith(
                      fontSize: 12,
                      color: DsColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DsSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.onboardingHeadline,
                style: DsTypography.headlineLarge.copyWith(
                  color: DsColors.textPrimary,
                ),
              ),
              const SizedBox(height: DsSpacing.xl),
              _buildDropdown(
                label: t.onboardingBelt,
                value: _belt,
                items: [
                  ('white', t.beltWhite),
                  ('blue', t.beltBlue),
                  ('purple', t.beltPurple),
                  ('brown', t.beltBrown),
                  ('black', t.beltBlack),
                ],
                onChanged: (v) {
                  _startTimerIfNeeded();
                  setState(() => _belt = v);
                },
              ),
              const SizedBox(height: DsSpacing.md),
              _buildDropdown(
                label: t.onboardingExperience,
                value: _expRange,
                items: [
                  ('beginner', t.expBeginner),
                  ('intermediate', t.expIntermediate),
                  ('advanced', t.expAdvanced),
                ],
                onChanged: (v) {
                  _startTimerIfNeeded();
                  setState(() => _expRange = v);
                },
              ),
              const SizedBox(height: DsSpacing.md),
              Text(
                '${t.onboardingWeeklyGoal} $_weeklyGoal',
                style: DsTypography.bodyMedium.copyWith(
                  color: DsColors.textPrimary,
                ),
              ),
              Slider(
                value: _weeklyGoal.toDouble(),
                min: 1,
                max: 7,
                divisions: 6,
                label: '$_weeklyGoal',
                onChanged: (v) {
                  _startTimerIfNeeded();
                  setState(() => _weeklyGoal = v.toInt());
                },
                activeColor: DsColors.brandRed,
              ),
              const SizedBox(height: DsSpacing.md),
              _buildDropdown(
                label: t.onboardingGoalType,
                value: _goalType,
                items: [
                  ('fundamentals', t.goalFundamentals),
                  ('technique', t.goalTechnique),
                  ('strength', t.goalStrength),
                  ('flexibility', t.goalFlexibility),
                ],
                onChanged: (v) {
                  _startTimerIfNeeded();
                  setState(() => _goalType = v);
                },
              ),
              const SizedBox(height: DsSpacing.md),
              _buildDropdown(
                label: t.onboardingAgeGroup,
                value: _ageGroup,
                items: [
                  ('u18', t.ageU18),
                  ('18-30', t.age1830),
                  ('30-40', t.age3040),
                  ('40+', t.age40Plus),
                ],
                onChanged: (v) {
                  _startTimerIfNeeded();
                  setState(() => _ageGroup = v);
                },
              ),
              const SizedBox(height: DsSpacing.xl),
              ElevatedButton(
                onPressed: _canSave && !_saving ? _save : null,
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
                    : Text(t.onboardingSave),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<(String, String)> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DsTypography.bodyMedium.copyWith(
            color: DsColors.textSecondary,
          ),
        ),
        const SizedBox(height: DsSpacing.xs),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: DsColors.bgTertiary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: DsColors.borderDefault),
            ),
          ),
          dropdownColor: DsColors.bgTertiary,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item.$1,
                    child: Text(
                      item.$2,
                      style: const TextStyle(color: DsColors.textPrimary),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
