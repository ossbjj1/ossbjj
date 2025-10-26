import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Progress service for "continue" hint (Sprint 3 stub).
///
/// Persists continue hint atomically using single key + JSON serialization
/// to avoid partial state on crash.
class ProgressService {
  ProgressService();

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
