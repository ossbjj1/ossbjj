import 'package:shared_preferences/shared_preferences.dart';

/// Progress service for "continue" hint (Sprint 3 stub).
class ProgressService {
  ProgressService();

  static const _keyStepId = 'last.step.id';
  static const _keyStepTitle = 'last.step.title';

  /// Load last step hint (MVP stub: uses SharedPreferences).
  Future<ContinueHint?> loadLast() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_keyStepId);
    final title = prefs.getString(_keyStepTitle);

    if (id == null || title == null) {
      return null;
    }

    return ContinueHint(stepId: id, title: title);
  }

  /// Save last step hint (MVP stub).
  Future<void> setLast(ContinueHint hint) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyStepId, hint.stepId);
    await prefs.setString(_keyStepTitle, hint.title);
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
}
