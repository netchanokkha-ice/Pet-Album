import 'package:flutter/material.dart';

abstract final class PawlumTypography {
  static const displayFamily = 'PawlumJua';
  static const bodyFamily = 'PawlumItim';
  static const accentFamily = 'PawlumCaveat';

  static const thaiFallback = <String>[
    bodyFamily,
    'Noto Sans Thai',
    'Thonburi',
    'sans-serif',
  ];

  static const systemFallback = <String>[
    'Noto Sans',
    'Roboto',
    'SF Pro Text',
    'sans-serif',
  ];

  static TextTheme textTheme(ColorScheme colors) {
    return TextTheme(
      displayLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: displayFamily,
        fontFamilyFallback: thaiFallback,
        fontSize: 44,
        height: 1.12,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.8,
      ),
      displayMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: displayFamily,
        fontFamilyFallback: thaiFallback,
        fontSize: 36,
        height: 1.16,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.5,
      ),
      headlineLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: displayFamily,
        fontFamilyFallback: thaiFallback,
        fontSize: 30,
        height: 1.2,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: displayFamily,
        fontFamilyFallback: thaiFallback,
        fontSize: 24,
        height: 1.25,
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: TextStyle(
        color: colors.onSurface,
        fontFamily: displayFamily,
        fontFamilyFallback: thaiFallback,
        fontSize: 22,
        height: 1.28,
        fontWeight: FontWeight.w400,
      ),
      titleLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: displayFamily,
        fontFamilyFallback: thaiFallback,
        fontSize: 20,
        height: 1.3,
        fontWeight: FontWeight.w400,
      ),
      titleMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: bodyFamily,
        fontFamilyFallback: systemFallback,
        fontSize: 18,
        height: 1.35,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: bodyFamily,
        fontFamilyFallback: systemFallback,
        fontSize: 17,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: colors.onSurface,
        fontFamily: bodyFamily,
        fontFamilyFallback: systemFallback,
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: bodyFamily,
        fontFamilyFallback: systemFallback,
        fontSize: 13,
        height: 1.45,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: colors.onSurface,
        fontFamily: displayFamily,
        fontFamilyFallback: thaiFallback,
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w400,
      ),
      labelMedium: TextStyle(
        color: colors.onSurfaceVariant,
        fontFamily: bodyFamily,
        fontFamilyFallback: systemFallback,
        fontSize: 13,
        height: 1.3,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  static TextStyle handwritten({
    double fontSize = 20,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return TextStyle(
      color: color,
      fontFamily: accentFamily,
      fontFamilyFallback: thaiFallback,
      fontSize: fontSize,
      height: 1.25,
      fontWeight: fontWeight,
    );
  }
}
