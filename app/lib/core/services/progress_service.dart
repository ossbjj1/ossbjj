import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Progress service for "continue" hint (Sprint 3 + Sprint 4).
///
/// Persists continue hint atomically using single key + JSON serialization
/// to avoid partial state on crash.
/// Sprint 4: getNextStep heuristic.
class ProgressService {
  ProgressService(this._supabase);

  final SupabaseClient _supabase;
  static const _keyHint = 'app.continue_hint';

  /// Load last step hint from atomic JSON storage.
  /// Returns null if no hint saved or JSON is malformed (tolerant read).
  Future<ContinueHint?> loadLast() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyHint);

    if (json == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      return ContinueHint.fromJson(decoded);
    } catch (e) {
      // Tolerate malformed JSON gracefully
      return null;
    }
  }

  /// Save last step hint atomically as single JSON-encoded key.
  Future<void> setLast(ContinueHint hint) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(hint.toJson());
    await prefs.setString(_keyHint, json);
  }

  /// Clear last step hint by removing the key.
  Future<void> clearLast() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHint);
  }

  /// Get next incomplete step for user (Sprint 4 variant-aware).
  /// 
  /// Logic:
  /// 1. Determine variant (preferredVariant or last completion, fallback 'gi')
  /// 2. Fetch first incomplete step for that variant via RPC
  /// 3. Return null if all complete or user not authenticated
  Future<NextStepResult?> getNextStep({String? preferredVariant}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return null;
    }

    try {
      // Determine variant
      String variant = preferredVariant ?? await _getLastVariant(user.id) ?? 'gi';

      // Fetch first incomplete step (RPC with variant filter)
      final response = await _supabase.rpc('get_next_step', params: {
        'p_user_id': user.id,
        'p_variant': variant,
      });

      if (response == null || (response as List).isEmpty) {
        return null;
      }

      final row = response.first as Map<String, dynamic>;
      return NextStepResult(
        stepId: row['step_id'] as String,
        titleEn: row['title_en'] as String,
        titleDe: row['title_de'] as String,
        idx: row['idx'] as int,
        variant: row['variant'] as String,
      );
    } catch (e) {
      // Tolerate errors (offline, RLS, missing RPC, etc.)
      return null;
    }
  }

  /// Get user's last used variant from most recent completed step.
  /// Returns null if no progress yet.
  Future<String?> _getLastVariant(String userId) async {
    try {
      final response = await _supabase
          .from('user_step_progress')
          .select('technique_step!inner(variant)')
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(1);

      if (response.isEmpty) {
        return null;
      }

      final row = response.first as Map<String, dynamic>;
      final stepData = row['technique_step'] as Map<String, dynamic>;
      return stepData['variant'] as String;
    } catch (e) {
      return null;
    }
  }
}

/// Continue hint data model.
class ContinueHint {
  const ContinueHint({
    required this.stepId,
    required this.title,
  });

  final String stepId;
  final String title;

  /// Serialize to JSON for atomic persistence.
  Map<String, dynamic> toJson() => {
        'stepId': stepId,
        'title': title,
      };

  /// Deserialize from JSON.
  factory ContinueHint.fromJson(Map<String, dynamic> json) {
    return ContinueHint(
      stepId: json['stepId'] as String,
      title: json['title'] as String,
    );
  }
}

/// Next step result (Sprint 4).
class NextStepResult {
  const NextStepResult({
    required this.stepId,
    required this.titleEn,
    required this.titleDe,
    required this.idx,
    required this.variant,
  });

  final String stepId;
  final String titleEn;
  final String titleDe;
  final int idx;
  final String variant;
}
