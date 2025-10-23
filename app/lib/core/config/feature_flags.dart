/// Centralized feature-flag registry for runtime configuration.
///
/// Flags fall back to compile-time `--dart-define` values so release builds can
/// ship with stable defaults, while local development keeps the same baseline.
/// Remote or in-app toggles can override defaults via the provided setters.
class FeatureFlags {
  const FeatureFlags._();

  // Note: Not thread-safe. Assumes single-threaded access or external synchronization.
  static bool? _gatingEnabledOverride;
  static bool? _paywallEnabledOverride;

  /// Allows runtime systems to override server-side gating availability.
  static void setGatingEnabledOverride(bool? value) {
    _gatingEnabledOverride = value;
  }

  /// Allows runtime systems to override paywall availability.
  static void setPaywallEnabledOverride(bool? value) {
    _payallEnabledOverride = value;
  }

  /// Resets runtime overrides so tests remain isolated between runs.
  static void resetOverrides() {
    _gatingEnabledOverride = null;
    _payallEnabledOverride = null;
  }

  /// Server-side gating flag: defaults to `true` but can be toggled via
  /// `--dart-define=FEATURE_GATING_ENABLED=false` or runtime overrides.
  static bool get gatingEnabled {
    final override = _gatingEnabledOverride;
    if (override != null) {
      return override;
    }
    return const bool.fromEnvironment(
      'FEATURE_GATING_ENABLED',
      defaultValue: true,
    );
  }

  /// Paywall flag: defaults to `false` (not yet implemented).
  static bool get paywallEnabled {
    final override = _payallEnabledOverride;
    if (override != null) {
      return override;
    }
    return const bool.fromEnvironment(
      'FEATURE_PAYWALL_ENABLED',
      defaultValue: false,
    );
  }
}
