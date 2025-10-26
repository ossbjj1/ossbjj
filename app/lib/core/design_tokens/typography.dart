import 'package:flutter/material.dart';

/// Typography tokens for OSS.
class TypographyTokens {
  const TypographyTokens._();

  // Font sizes (px)
  static const double size12 = 12.0;
  static const double size14 = 14.0;
  static const double size16 = 16.0;
  static const double size18 = 18.0;
  static const double size20 = 20.0;
  static const double size24 = 24.0;
  static const double size28 = 28.0;
  static const double size32 = 32.0;
  static const double size40 = 40.0;
  static const double size48 = 48.0;

  // Line height ratios
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  // Letter spacing (em)
  static const double letterSpacingTight = -0.02;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.05;
}

/// Font family identifiers (used with GoogleFonts).
class FontFamilies {
  const FontFamilies._();

  // Note: These are not Flutter fontFamily strings, but references for GoogleFonts.
  // Use GoogleFonts.inter() / GoogleFonts.oswald() / GoogleFonts.robotoMono() in theme.
  static const String primary = 'Inter';
  static const String display = 'Oswald';
  static const String monospace = 'RobotoMono';
}

/// Quick TextStyle presets for MVP (Sprint 2).
class DsTypography {
  const DsTypography._();

  static const headlineLarge = TextStyle(
    fontSize: TypographyTokens.size32,
    fontWeight: FontWeight.bold,
    height: TypographyTokens.lineHeightTight,
  );

  static const headlineMedium = TextStyle(
    fontSize: TypographyTokens.size24,
    fontWeight: FontWeight.w600,
    height: TypographyTokens.lineHeightNormal,
  );

  static const bodyMedium = TextStyle(
    fontSize: TypographyTokens.size16,
    fontWeight: FontWeight.normal,
    height: TypographyTokens.lineHeightNormal,
  );
}
