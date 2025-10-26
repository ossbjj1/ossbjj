import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale (language) service (Sprint 3).
class LocaleService {
  LocaleService();

  static const _keyLocale = 'app.locale';
  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale('en'));

  /// Load saved locale from storage.
  Future<Locale> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocale) ?? 'en';
    final locale = Locale(code);
    localeNotifier.value = locale;
    return locale;
  }

  /// Set locale and persist.
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.languageCode);
    localeNotifier.value = locale;
  }

  /// Current locale.
  Locale get currentLocale => localeNotifier.value;
}
