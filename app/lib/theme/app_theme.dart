import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design_tokens/colors.dart';
import '../core/design_tokens/typography.dart';
import '../core/design_tokens/spacing.dart';
import '../core/design_tokens/sizes.dart';

/// OSS app theme (Dark-only).
class AppTheme {
  const AppTheme._();

  /// Build the dark theme for the app.
  static ThemeData buildDarkTheme() {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: DsColors.bgPrimary,
      colorScheme: _buildColorScheme(),
      textTheme: _buildTextTheme(baseTextTheme),
      appBarTheme: _buildAppBarTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      iconTheme: const IconThemeData(
        color: DsColors.textPrimary,
        size: Sizes.iconM,
      ),
    );
  }

  static ColorScheme _buildColorScheme() {
    return const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: DsColors.brandPrimary,
      onPrimary: DsColors.textPrimary,
      secondary: DsColors.brandSecondary,
      onSecondary: DsColors.textPrimary,
      error: DsColors.stateError,
      onError: DsColors.textPrimary,
      surface: DsColors.bgSurface,
      onSurface: DsColors.textPrimary,
      outline: DsColors.borderDefault,
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return TextTheme(
      // H1 (Display)
      displayLarge: GoogleFonts.oswald(
        fontWeight: FontWeight.w700,
        fontSize: TypographyTokens.size48,
        height: 1.2,
        letterSpacing: TypographyTokens.letterSpacingNormal,
        color: DsColors.textPrimary,
      ),
      // H2
      displayMedium: GoogleFonts.oswald(
        fontWeight: FontWeight.w700,
        fontSize: TypographyTokens.size40,
        height: 1.2,
        letterSpacing: TypographyTokens.letterSpacingNormal,
        color: DsColors.textPrimary,
      ),
      // H3
      displaySmall: GoogleFonts.oswald(
        fontWeight: FontWeight.w600,
        fontSize: TypographyTokens.size32,
        height: 1.5,
        letterSpacing: TypographyTokens.letterSpacingNormal,
        color: DsColors.textPrimary,
      ),
      // Body Large
      headlineSmall: base.headlineSmall?.copyWith(
        fontSize: TypographyTokens.size20,
        height: 1.5,
        letterSpacing: TypographyTokens.letterSpacingNormal,
        color: DsColors.textPrimary,
      ),
      // Body (default)
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: TypographyTokens.size16,
        height: 1.5,
        letterSpacing: TypographyTokens.letterSpacingNormal,
        color: DsColors.textPrimary,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: TypographyTokens.size14,
        height: 1.5,
        letterSpacing: TypographyTokens.letterSpacingNormal,
        color: DsColors.textSecondary,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: TypographyTokens.size12,
        height: 1.5,
        letterSpacing: TypographyTokens.letterSpacingNormal,
        color: DsColors.textMuted,
      ),
      // Label / Button
      labelLarge: base.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: TypographyTokens.size16,
        height: 1.2,
        letterSpacing: TypographyTokens.letterSpacingWide,
        color: DsColors.textPrimary,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: TypographyTokens.size14,
        height: 1.5,
        letterSpacing: TypographyTokens.letterSpacingWide,
        color: DsColors.textSecondary,
      ),
      labelSmall: base.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
        fontSize: TypographyTokens.size12,
        height: 1.5,
        letterSpacing: TypographyTokens.letterSpacingWide,
        color: DsColors.textMuted,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return AppBarTheme(
      backgroundColor: DsColors.bgSecondary,
      foregroundColor: DsColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.w600,
        fontSize: TypographyTokens.size20,
        color: DsColors.textPrimary,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DsColors.interactivePrimary,
        foregroundColor: DsColors.textPrimary,
        disabledBackgroundColor: DsColors.interactiveDisabled,
        disabledForegroundColor: DsColors.textMuted,
        minimumSize: const Size.fromHeight(Sizes.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusL),
        ),
        elevation: 0,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: TypographyTokens.size16,
          letterSpacing: TypographyTokens.letterSpacingWide,
        ),
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: DsColors.brandPrimary,
        disabledForegroundColor: DsColors.textMuted,
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: TypographyTokens.size14,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: DsColors.brandSecondary,
        side: const BorderSide(
          color: DsColors.borderDefault,
          width: 1.5,
        ),
        minimumSize: const Size.fromHeight(Sizes.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusL),
        ),
        textStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: TypographyTokens.size16,
        ),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: DsColors.bgTertiary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusL),
        borderSide: const BorderSide(
          color: DsColors.borderDefault,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusL),
        borderSide: const BorderSide(
          color: DsColors.borderDefault,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusL),
        borderSide: const BorderSide(
          color: DsColors.borderFocus,
          width: 2.0,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Sizes.radiusL),
        borderSide: const BorderSide(
          color: DsColors.stateError,
          width: 1.5,
        ),
      ),
      hintStyle: const TextStyle(
        color: DsColors.textMuted,
      ),
      labelStyle: const TextStyle(
        color: DsColors.textSecondary,
      ),
      errorStyle: const TextStyle(
        color: DsColors.stateError,
      ),
    );
  }
}
