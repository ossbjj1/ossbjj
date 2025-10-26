import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Locale (language) service (Sprint 3).
///
/// Manages language preference with persistence. Defaults to platform locale
/// on first run instead of hardcoded 'en'. Preserves full language tags
/// (e.g., en-GB, zh-Hant-TW) via toLanguageTag() for region awareness.
/// Accepts optional SharedPreferences for testability.
class LocaleService {
  LocaleService({SharedPreferences? prefs}) : _prefs = prefs;

  static const _keyLocale = 'app.locale';
  SharedPreferences? _prefs;
  final ValueNotifier<Locale> localeNotifier =
      ValueNotifier(const Locale('en'));

  /// Load saved locale from storage or default to platform locale.
  Future<Locale> load() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
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
  /// Throws exception if persistence fails.
  Future<void> setLocale(Locale locale) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    // Save full language tag to preserve region/script info (e.g., 'en-GB')
    final tag = locale.toLanguageTag();
    // Persist first; only update state if successful
    final success = await prefs.setString(_keyLocale, tag);
    if (!success) {
      throw Exception('Failed to persist locale "$tag" to storage');
    }
    // Update notifier after successful persist
    localeNotifier.value = locale;
  }

  /// Parse a language tag (e.g., 'en-GB', 'zh-Hant', 'zh-Hant-TW') into Locale.
  /// Detects and handles script vs region subtags correctly.
  static Locale _parseLocaleTag(String tag) {
    final parts = tag.split('-');
    if (parts.length == 1) {
      return Locale(parts[0].toLowerCase());
    } else if (parts.length == 2) {
      final second = parts[1];
      // Detect script: 4-letter titlecase (e.g., 'Hant', 'Hans')
      if (second.length == 4 && second[0].toUpperCase() == second[0]) {
        // Script tag: lang-Script (e.g., 'zh-Hant')
        return Locale.fromSubtags(
          languageCode: parts[0].toLowerCase(),
          scriptCode: second,
        );
      } else if ((second.length == 2 && second.toUpperCase() == second) ||
          (second.length == 3 && int.tryParse(second) != null)) {
        // Region: 2 alpha (e.g., 'GB') or 3 digits (e.g., '001')
        return Locale(parts[0].toLowerCase(), second.toUpperCase());
      }
      // Ambiguous, treat as country
      return Locale(parts[0].toLowerCase(), second.toUpperCase());
    } else if (parts.length == 3) {
      // Handle script tags: lang-Script-Region (e.g., 'zh-Hant-TW')
      return Locale.fromSubtags(
        languageCode: parts[0].toLowerCase(),
        scriptCode: parts[1],
        countryCode: parts[2].toUpperCase(),
      );
    }
    return const Locale('en');
  }

  /// Current locale.
  Locale get currentLocale => localeNotifier.value;
}
