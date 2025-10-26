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
  Future<bool> load() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_keyAudio) ?? false;
    audioEnabled.value = _enabled;
    notifyListeners();
    return _enabled;
  }

  /// Set audio enabled/disabled, persist, and notify listeners.
  Future<void> setEnabled(bool value) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    _enabled = value;
    audioEnabled.value = value;
    await prefs.setBool(_keyAudio, value);
    notifyListeners();
  }

  @override
  void dispose() {
    audioEnabled.dispose();
    super.dispose();
  }
}
