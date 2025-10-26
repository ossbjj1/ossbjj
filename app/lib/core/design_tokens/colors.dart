import 'package:flutter/material.dart';

/// Design system color tokens for OSS (Dark-only, Tatami, Red/Blue accents).
class DsColors {
  const DsColors._();

  // Grayscale
  static const Color black = Color(0xFF0A0A0A);
  static const Color gray900 = Color(0xFF1A1A1A);
  static const Color gray800 = Color(0xFF2A2A2A);
  static const Color gray700 = Color(0xFF3F3F3F);
  static const Color gray600 = Color(0xFF5F5F5F);
  static const Color gray500 = Color(0xFF7F7F7F);
  static const Color gray400 = Color(0xFF9F9F9F);
  static const Color gray300 = Color(0xFFBFBFBF);
  static const Color gray200 = Color(0xFFDFDFDF);
  static const Color gray100 = Color(0xFFF0F0F0);
  static const Color white = Color(0xFFFFFFFF);

  // Accent colors
  static const Color redBase = Color(0xFFD32F2F);
  static const Color redLight = Color(0xFFF44336);
  static const Color redDark = Color(0xFFB71C1C);

  static const Color blueBase = Color(0xFF1976D2);
  static const Color blueLight = Color(0xFF2196F3);
  static const Color blueDark = Color(0xFF0D47A1);

  // Tatami colors
  static const Color tatamiBeige = Color(0xFFE8DCC4);
  static const Color tatamiSand = Color(0xFFD4C5A9);
  static const Color tatamiBrown = Color(0xFF8B7355);

  // Semantic - Background
  static const Color bgPrimary = black;
  static const Color bgSecondary = gray900;
  static const Color bgTertiary = gray800;
  static const Color bgSurface = gray900;
  static const Color bgOverlay = Color(0x990A0A0A);

  // Semantic - Text
  static const Color textPrimary = white;
  static const Color textSecondary = gray300;
  static const Color textMuted = gray500;
  static const Color textInverse = black;

  // Semantic - Brand
  static const Color brandPrimary = redBase;
  static const Color brandRed = redBase;
  static const Color brandSecondary = blueBase;
  static const Color brandTatami = tatamiSand;

  // Semantic - State
  static const Color stateSuccess = Color(0xFF4CAF50);
  static const Color stateWarning = Color(0xFFFFC107);
  static const Color stateError = redBase;
  static const Color stateInfo = blueLight;
  static const Color stateLocked = gray500;

  // Semantic - Interactive
  static const Color interactivePrimary = redBase;
  static const Color interactivePrimaryHover = redLight;
  static const Color interactivePrimaryActive = redDark;
  static const Color interactiveSecondary = blueBase;
  static const Color interactiveSecondaryHover = blueLight;
  static const Color interactiveSecondaryActive = blueDark;
  static const Color interactiveDisabled = gray700;

  // Semantic - Border
  static const Color borderDefault = gray700;
  static const Color borderFocus = redBase;
  static const Color borderSubtle = gray800;
}
