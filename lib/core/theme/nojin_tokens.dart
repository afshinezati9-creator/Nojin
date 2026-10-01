import 'package:flutter/material.dart';

/// Central visual tokens extracted from the NOJÎN Golden Reference.
abstract final class NojinColors {
  static const blueSky = Color(0xFF38BDF8);
  static const blue = Color(0xFF3B82F6);
  static const indigo = Color(0xFF6366F1);
  static const violet = Color(0xFF8B5CF6);
  static const purple = Color(0xFFA855F7);

  static const background = Color(0xFFF4F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFFAFBFC);
  static const text = Color(0xFF0F172A);
  static const text2 = Color(0xFF475569);
  static const text3 = Color(0xFF94A3B8);
  static const border = Color(0xFFE5E9F0);

  static const darkBackground = Color(0xFF0A0F1C);
  static const darkSurface = Color(0xFF151E30);
  static const darkSurface2 = Color(0xFF1A2440);
  static const darkText = Color(0xFFF1F5F9);
  static const darkBorder = Color(0xFF243049);

  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const info = blue;
  static const warning = Color(0xFFF59E0B);
  static const pink = Color(0xFFEC4899);

  static const successSoft = Color(0xFFD1FAE5);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const infoSoft = Color(0xFFDBEAFE);
  static const purpleSoft = Color(0xFFEDE9FE);
  static const warningSoft = Color(0xFFFEF3C7);
  static const pinkSoft = Color(0xFFFCE7F3);

  static const darkSuccessSoft = Color(0xFF064E3B);
  static const darkDangerSoft = Color(0xFF7F1D1D);
  static const darkInfoSoft = Color(0xFF1E3A8A);
  static const darkPurpleSoft = Color(0xFF4C1D95);
  static const darkWarningSoft = Color(0xFF78350F);
  static const darkPinkSoft = Color(0xFF831843);
}

abstract final class NojinGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [NojinColors.blue, NojinColors.violet],
  );

  static const soft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [NojinColors.infoSoft, NojinColors.purpleSoft],
  );

  static const darkSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [NojinColors.darkInfoSoft, NojinColors.darkPurpleSoft],
  );
}

abstract final class NojinSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const section = 40.0;
}

abstract final class NojinRadii {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const pill = 999.0;
}

abstract final class NojinElevation {
  static const none = 0.0;
  static const sm = 1.0;
  static const md = 2.0;
}

abstract final class NojinTypography {
  static const fontFamily = 'Vazirmatn';
  static const fontFallback = <String>['Tahoma', 'Arial', 'sans-serif'];

  static const monoFontFamily = 'JetBrains Mono';
  static const monoFallback = <String>['Consolas', 'monospace'];
}
