import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Audio feedback service (Sprint 3).
///
/// Manages audio feedback preference with reactive updates via ValueNotifier.
/// Inject SharedPreferences for easier testing.
class AudioService extends ChangeNotifier {
  AudioService({SharedPreferences? prefs}) : _prefs = prefs;

  static const _keyAudio = 'app.audio';
  SharedPreferences? _prefs;
  bool _enabled = false;

  /// Observable audio preference for reactive UI updates.
  late final ValueNotifier<bool> audioEnabled = ValueNotifier(_enabled);

  bool get enabled => _enabled;

  /// Load audio preference from storage and update notifier.
  /// Only notifies if the loaded value differs from current state.
  Future<bool> load() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    final newEnabled = prefs.getBool(_keyAudio) ?? false;
    // Only update if value changed
    if (newEnabled != _enabled) {
      _enabled = newEnabled;
      audioEnabled.value = _enabled;
      notifyListeners();
    }
    return _enabled;
  }

  /// Set audio enabled/disabled, persist, and notify listeners.
  /// Throws exception if persistence fails.
  Future<void> setEnabled(bool value) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    // Persist first; only update state if successful
    final success = await prefs.setBool(_keyAudio, value);
    if (!success) {
      throw Exception('Failed to persist audio setting to storage');
    }
    // Update in-memory state and notifiers after successful persist
    _enabled = value;
    audioEnabled.value = value;
    notifyListeners();
  }

  @override
  void dispose() {
    audioEnabled.dispose();
    super.dispose();
  }
}
