import 'package:flutter/material.dart';

/// Layout tiers driven by window width — not [kIsWeb].
enum AppBreakpoint { mobile, tablet, desktop }

/// Practical browser-oriented thresholds (logical pixels).
abstract final class Breakpoints {
  /// Mobile: width &lt; 768
  static const double mobileMax = 768;

  /// Tablet: 768–1199; Desktop: &gt;= 1200
  static const double tabletMax = 1200;
}

AppBreakpoint breakpointOf(double width) {
  if (width < Breakpoints.mobileMax) return AppBreakpoint.mobile;
  if (width < Breakpoints.tabletMax) return AppBreakpoint.tablet;
  return AppBreakpoint.desktop;
}

extension BreakpointContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  AppBreakpoint get bp => breakpointOf(screenSize.width);

  bool get isMobile => bp == AppBreakpoint.mobile;
  bool get isTablet => bp == AppBreakpoint.tablet;
  bool get isDesktop => bp == AppBreakpoint.desktop;
}

/// Profile / match style grids: 2 → 3 → 4 columns.
int profileGridColumns(BuildContext context) {
  switch (context.bp) {
    case AppBreakpoint.mobile:
      return 2;
    case AppBreakpoint.tablet:
      return 3;
    case AppBreakpoint.desktop:
      return 4;
  }
}

/// Fixed 4-slot photo pickers: keep 2×2 on phone/tablet; one row on desktop.
int photoSlotColumns(BuildContext context) {
  return context.isDesktop ? 4 : 2;
}
