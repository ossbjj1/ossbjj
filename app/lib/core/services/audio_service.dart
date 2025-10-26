import 'package:shared_preferences/shared_preferences.dart';

/// Audio feedback service (Sprint 3).
class AudioService {
  AudioService();

  static const _keyAudio = 'app.audio';
  bool _enabled = false;

  bool get enabled => _enabled;

  /// Load audio preference from storage.
  Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_keyAudio) ?? false;
    return _enabled;
  }

  /// Set audio enabled/disabled and persist.
  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAudio, value);
  }
}
