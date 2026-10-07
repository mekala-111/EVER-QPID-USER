import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:flutter/material.dart';

/// Horizontal page insets that scale above mobile.
///
/// On mobile, prefer keeping each screen's existing padding (16/20/24) to avoid
/// visual regression. Use [page] when introducing new shared chrome or when a
/// screen is already being refactored.
abstract final class AppSpacing {
  static EdgeInsets page(BuildContext context) {
    switch (context.bp) {
      case AppBreakpoint.mobile:
        return const EdgeInsets.symmetric(horizontal: 16);
      case AppBreakpoint.tablet:
        return const EdgeInsets.symmetric(horizontal: 24);
      case AppBreakpoint.desktop:
        return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static double pageHorizontal(BuildContext context) {
    return page(context).horizontal / 2;
  }
}
