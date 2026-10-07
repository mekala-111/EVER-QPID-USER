import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:flutter/material.dart';

/// Rare layout forks: mobile tree first, tablet/desktop optional overrides.
///
/// Prefer parametric changes (columns, maxWidth) over forking when possible.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder? tablet;
  final WidgetBuilder? desktop;

  @override
  Widget build(BuildContext context) {
    switch (context.bp) {
      case AppBreakpoint.desktop:
        return (desktop ?? tablet ?? mobile)(context);
      case AppBreakpoint.tablet:
        return (tablet ?? mobile)(context);
      case AppBreakpoint.mobile:
        return mobile(context);
    }
  }
}
