import 'package:flutter/widgets.dart';

/// Central responsive rules for NOJÎN.
///
/// Widths are based on the available content width, not device names, so the
/// same rules work for phones, tablets, desktop windows and web resizing.
abstract final class NojinBreakpoints {
  static const compact = 600.0;
  static const medium = 840.0;
  static const expanded = 1200.0;

  static bool isCompact(double width) => width < compact;
  static bool isMedium(double width) => width >= compact && width < medium;
  static bool isExpanded(double width) => width >= medium;
  static bool isWide(double width) => width >= expanded;

  static EdgeInsets pagePadding(double width) {
    if (isCompact(width)) {
      return const EdgeInsets.fromLTRB(16, 16, 16, 24);
    }
    if (isMedium(width)) {
      return const EdgeInsets.fromLTRB(24, 20, 24, 28);
    }
    return const EdgeInsets.fromLTRB(32, 24, 32, 32);
  }

  static double contentMaxWidth(double width) {
    if (isWide(width)) return 1180;
    if (isExpanded(width)) return 1040;
    return double.infinity;
  }

  static int gridColumns(double width) {
    if (width < compact) return 1;
    if (width < medium) return 2;
    if (width < expanded) return 3;
    return 4;
  }
}
