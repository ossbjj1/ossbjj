import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Step gating service (Sprint 4 MVP).
/// Checks access & completes steps.
/// MVP: Client-side logic; Edge Fn migration planned.
class GatingService {
  GatingService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  /// Check if user can access step.
  /// MVP: Steps 1-2 free; step 3+ requires premium.
  Future<GatingAccess> checkStepAccess(String techniqueStepId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const GatingAccess(
        allowed: false,
        reason: GatingReason.authRequired,
      );
    }

    try {
      // Fetch step index (0-based)
      final stepResponse = await Supabase.instance.client
          .from('technique_step')
          .select('idx')
          .eq('id', techniqueStepId)
          .single();

      final idx = stepResponse['idx'] as int;

      // Free: idx 0-1 (steps 1-2)
      if (idx <= 1) {
        return const GatingAccess(
          allowed: true,
          reason: GatingReason.free,
        );
      }

      // Premium required for idx >= 2 (step 3+)
      final profileResponse = await Supabase.instance.client
          .from('user_profile')
          .select('entitlement')
          .eq('user_id', user.id)
          .maybeSingle();

      final entitlement = profileResponse?['entitlement'] as String? ?? 'free';

      if (entitlement == 'premium') {
        return const GatingAccess(
          allowed: true,
          reason: GatingReason.premium,
        );
      }

      return const GatingAccess(
        allowed: false,
        reason: GatingReason.premiumRequired,
      );
    } catch (e, stackTrace) {
      _logger.e('checkStepAccess failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Complete step (idempotent).
  /// MVP: Direct DB insert; Edge Fn + rate-limit later.
  Future<CompleteResult> completeStep(String techniqueStepId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot complete step: user not logged in');
    }

    try {
      // Check access first
      final access = await checkStepAccess(techniqueStepId);
      if (!access.allowed) {
        return CompleteResult(
          success: false,
          idempotent: false,
          message: 'Access denied: ${access.reason}',
        );
      }

      // Insert progress (idempotent via PK)
      final response =
          await Supabase.instance.client.from('user_step_progress').upsert({
        'user_id': user.id,
        'technique_step_id': techniqueStepId,
        'done_at': DateTime.now().toUtc().toIso8601String(),
      }).select();

      _logger.i('Step completed: $techniqueStepId');

      return CompleteResult(
        success: true,
        idempotent: response.isEmpty, // Empty = conflict (already exists)
        message: 'Step completed',
      );
    } catch (e, stackTrace) {
      _logger.e('completeStep failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}

/// Gating access result.
class GatingAccess {
  const GatingAccess({
    required this.allowed,
    required this.reason,
  });

  final bool allowed;
  final GatingReason reason;
}

/// Gating reason enum.
enum GatingReason {
  free,
  premium,
  premiumRequired,
  authRequired,
}

/// Complete step result.
class CompleteResult {
  const CompleteResult({
    required this.success,
    required this.idempotent,
    required this.message,
  });

  final bool success;
  final bool idempotent; // True if already completed
  final String message;
}
