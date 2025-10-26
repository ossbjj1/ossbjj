import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale (language) service (Sprint 3).
///
/// Manages language preference with persistence. Defaults to platform locale
/// on first run instead of hardcoded 'en'. Preserves full language tags
/// (e.g., en-GB, zh-Hant-TW) via toLanguageTag() for region awareness.
class LocaleService {
  LocaleService();

  static const _keyLocale = 'app.locale';
  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale('en'));

  /// Load saved locale from storage or default to platform locale.
  Future<Locale> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_keyLocale);

    late Locale locale;
    if (code != null) {
      // Reconstruct locale from saved language tag (e.g., 'en-GB')
      locale = _parseLocaleTag(code);
    } else {
      // Default to device platform locale on first run
      locale = WidgetsBinding.instance.platformDispatcher.locale;
    }

    localeNotifier.value = locale;
    return locale;
  }

  /// Set locale and persist as full language tag.
  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    // Save full language tag to preserve region/script info (e.g., 'en-GB')
    final tag = locale.toLanguageTag();
    await prefs.setString(_keyLocale, tag);
    localeNotifier.value = locale;
  }

  /// Parse a language tag (e.g., 'en-GB') into Locale with region support.
  static Locale _parseLocaleTag(String tag) {
    final parts = tag.split('-');
    if (parts.length == 1) {
      return Locale(parts[0]);
    } else if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    } else if (parts.length == 3) {
      // Handle script tags: lang-Script-Region (e.g., 'zh-Hant-TW')
      return Locale.fromSubtags(
        languageCode: parts[0],
        scriptCode: parts[1],
        countryCode: parts[2],
      );
    }
    return const Locale('en');
  }

  /// Current locale.
  Locale get currentLocale => localeNotifier.value;
}
