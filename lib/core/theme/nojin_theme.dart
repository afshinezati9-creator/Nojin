import 'package:flutter/material.dart';

import 'nojin_tokens.dart';

class NojinTheme {
  static const Color background = NojinColors.background;
  static const Color surface = NojinColors.surface;
  static const Color text = NojinColors.text;
  static const Color darkBackground = NojinColors.darkBackground;
  static const Color darkSurface = NojinColors.darkSurface;
  static const LinearGradient primaryGradient = NojinGradients.primary;

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: NojinColors.background,
        surface: NojinColors.surface,
        foreground: NojinColors.text,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: NojinColors.darkBackground,
        surface: NojinColors.darkSurface,
        foreground: NojinColors.darkText,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color foreground,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: NojinColors.indigo,
      brightness: brightness,
      surface: surface,
    );

    final baseText = ThemeData(
      brightness: brightness,
      fontFamily: NojinTypography.fontFamily,
    ).textTheme;

    final textTheme = baseText.copyWith(
      displayLarge: baseText.displayLarge?.copyWith(color: foreground, fontWeight: FontWeight.w800),
      headlineMedium: baseText.headlineMedium?.copyWith(color: foreground, fontWeight: FontWeight.w700),
      titleLarge: baseText.titleLarge?.copyWith(color: foreground, fontWeight: FontWeight.w700),
      titleMedium: baseText.titleMedium?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      bodyLarge: baseText.bodyLarge?.copyWith(color: foreground),
      bodyMedium: baseText.bodyMedium?.copyWith(color: foreground),
      bodySmall: baseText.bodySmall?.copyWith(color: isDark ? NojinColors.text3 : NojinColors.text2),
      labelLarge: baseText.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: NojinTypography.fontFamily,
      fontFamilyFallback: NojinTypography.fontFallback,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: NojinElevation.none,
        scrolledUnderElevation: NojinElevation.none,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: NojinElevation.none,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(NojinRadii.lg),
          side: BorderSide(color: isDark ? NojinColors.darkBorder : NojinColors.border),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? NojinColors.darkBorder : NojinColors.border,
        space: 1,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? NojinColors.darkBackground : NojinColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NojinRadii.md),
          borderSide: BorderSide(color: isDark ? NojinColors.darkBorder : NojinColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NojinRadii.md),
          borderSide: BorderSide(color: isDark ? NojinColors.darkBorder : NojinColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(NojinRadii.md),
          borderSide: const BorderSide(color: NojinColors.indigo, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: NojinSpacing.lg, vertical: NojinSpacing.md),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NojinRadii.pill)),
        side: BorderSide(color: isDark ? NojinColors.darkBorder : NojinColors.border),
        padding: const EdgeInsets.symmetric(horizontal: NojinSpacing.sm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: NojinSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NojinRadii.md)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: NojinSpacing.lg),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(NojinRadii.md)),
        ),
      ),
    );
  }
}
