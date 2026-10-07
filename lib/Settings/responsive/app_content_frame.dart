import 'dart:math' as math;

import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:flutter/material.dart';

/// Centers and caps content width on tablet/desktop.
///
/// On mobile (`width < 600`), returns [child] unchanged so existing layouts
/// stay identical.
///
/// Uses parent [LayoutBuilder] constraints (not full window [MediaQuery]
/// width) so nested frames inside a desktop rail / shell do not over-pad
/// and collapse to zero width on wide monitors.
///
/// Safe as a *parent* of [IntrinsicHeight] (common in onboarding). Do not
/// place this *inside* an [IntrinsicHeight] — [LayoutBuilder] cannot be a
/// descendant of intrinsic measurement.
class AppContentFrame extends StatelessWidget {
  const AppContentFrame({
    super.key,
    required this.child,
    this.maxWidth = ContentMaxWidth.shell,
    this.alignment = Alignment.topCenter,
  });

  final Widget child;
  final double maxWidth;

  /// Kept for API compatibility; content is centered via equal side insets.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) return child;

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final maxAvailable = available.isFinite && available > 0
            ? available
            : MediaQuery.sizeOf(context).width;
        final targetWidth = math.min(maxWidth, maxAvailable);
        final inset = math.max(0.0, (maxAvailable - targetWidth) / 2);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: inset),
          child: child,
        );
      },
    );
  }
}
