import 'package:flutter/material.dart';

import 'pawlum_tokens.dart';
import 'pawlum_typography.dart';

abstract final class PawlumTheme {
  static ThemeData lightForWidth(double width) {
    final layout = PawlumLayoutTheme.forWidth(width);
    const colors = ColorScheme(
      brightness: Brightness.light,
      primary: PawlumColors.pinkStrong,
      onPrimary: Colors.white,
      primaryContainer: PawlumColors.pinkSoft,
      onPrimaryContainer: PawlumColors.ink,
      secondary: PawlumColors.purpleStrong,
      onSecondary: Colors.white,
      secondaryContainer: PawlumColors.purple,
      onSecondaryContainer: PawlumColors.ink,
      tertiary: PawlumColors.yellow,
      onTertiary: PawlumColors.yellowStrong,
      tertiaryContainer: Color(0xFFFFF3C4),
      onTertiaryContainer: PawlumColors.yellowStrong,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF410E0B),
      surface: PawlumColors.paper,
      onSurface: PawlumColors.ink,
      surfaceContainerHighest: PawlumColors.paperMuted,
      onSurfaceVariant: PawlumColors.inkMuted,
      outline: PawlumColors.outline,
      outlineVariant: Color(0xFFECE4DD),
      shadow: Color(0x332D2424),
      scrim: Color(0x662D2424),
      inverseSurface: PawlumColors.ink,
      onInverseSurface: PawlumColors.paper,
      inversePrimary: PawlumColors.pink,
    );
    final textTheme = PawlumTypography.textTheme(colors);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: PawlumColors.canvas,
      canvasColor: PawlumColors.canvas,
      cardColor: PawlumColors.paper,
      shadowColor: colors.shadow,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      splashColor: PawlumColors.pink.withValues(alpha: 0.18),
      highlightColor: PawlumColors.pink.withValues(alpha: 0.1),
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      cardTheme: CardThemeData(
        color: PawlumColors.paper,
        surfaceTintColor: Colors.transparent,
        shadowColor: colors.shadow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(layout.cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PawlumColors.paper,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: PawlumSpacing.md,
          vertical: PawlumSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawlumRadii.control),
          borderSide: const BorderSide(color: PawlumColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawlumRadii.control),
          borderSide: const BorderSide(color: PawlumColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawlumRadii.control),
          borderSide: const BorderSide(
            color: PawlumColors.pinkStrong,
            width: 2,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: PawlumSpacing.lg,
            vertical: PawlumSpacing.sm,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PawlumRadii.control),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: PawlumColors.outline,
        thickness: 1,
        space: PawlumSpacing.lg,
      ),
      extensions: <ThemeExtension<dynamic>>[layout],
    );
  }
}
