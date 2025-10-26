import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Step gating service (Sprint 4 MVP).
/// Checks access & completes steps.
/// MVP: Client-side logic; Edge Fn migration planned.
class GatingService {
  GatingService({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  /// Check if user can access step (server-authoritative).
  /// Sprint 4.1: Calls Edge Function for secure, server-side entitlement validation.
  /// Cannot be bypassed via app binary manipulation.
  Future<GatingAccess> checkStepAccess(String techniqueStepId) async {
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'gating_check_step_access',
        body: {'techniqueStepId': techniqueStepId},
      );

      if (response.status == 401) {
        return const GatingAccess(
            allowed: false, reason: GatingReason.authRequired);
      }

      if (response.status != 200) {
        throw Exception(
            'Edge Function failed: ${response.status} ${response.data}');
      }

      final raw = response.data;
      if (raw is! Map) {
        _logger.w('Malformed gating response: non-map payload');
        return const GatingAccess(
            allowed: false, reason: GatingReason.authRequired);
      }
      final data = Map<String, dynamic>.from(raw);

      final allowedVal = data['allowed'];
      final reasonVal = data['reason'];

      final bool allowed = allowedVal is bool ? allowedVal : false;
      final String reasonStr = reasonVal is String ? reasonVal : 'authRequired';

      final reason = _parseGatingReason(reasonStr);
      return GatingAccess(allowed: allowed, reason: reason);
    } catch (e, stackTrace) {
      _logger.e('checkStepAccess failed', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Parse gating reason string from Edge Function response.
  GatingReason _parseGatingReason(String reasonStr) {
    switch (reasonStr) {
      case 'free':
        return GatingReason.free;
      case 'premium':
        return GatingReason.premium;
      case 'premiumRequired':
        return GatingReason.premiumRequired;
      case 'authRequired':
        return GatingReason.authRequired;
      default:
        _logger
            .w('Unknown gating reason: $reasonStr, defaulting to authRequired');
        return GatingReason.authRequired;
    }
  }

  /// Complete step (idempotent).
  /// Sprint 4.1: Server-authoritative completion via RPC mark_step_complete.
  /// Prevents duplicate completions via PK conflict; returns {success,idempotent,message}.
  Future<CompleteResult> completeStep(String techniqueStepId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Cannot complete step: user not logged in');
    }

    try {
      // Check access first (server-side validation)
      final access = await checkStepAccess(techniqueStepId);
      if (!access.allowed) {
        return CompleteResult(
          success: false,
          idempotent: false,
          message: 'Access denied: ${access.reason}',
        );
      }

      // Call RPC mark_step_complete (idempotent via PK conflict)
      final response = await Supabase.instance.client
          .rpc('mark_step_complete', params: {
        'p_technique_step_id': techniqueStepId,
      }).single();

      final success = response['success'] as bool? ?? false;
      final idempotent = response['idempotent'] as bool? ?? false;
      final message = response['message'] as String? ?? 'unknown';

      _logger.i(
          'Step completed: $techniqueStepId (success: $success, idempotent: $idempotent)');

      return CompleteResult(
        success: success,
        idempotent: idempotent,
        message: message,
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
