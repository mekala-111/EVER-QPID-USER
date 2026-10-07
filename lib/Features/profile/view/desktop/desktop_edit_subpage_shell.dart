import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/mainscreen/view/widgets/desktop_sidebar.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:flutter/material.dart';

/// Shared authenticated shell for Profile edit subpages (About / Work / Goals).
///
/// No full-bleed [Images.bg] — decoding that asset on every push caused open/close
/// jank on Flutter Web. Solid dark fill matches the shell; MainScreen already
/// showed the decorative bg underneath the stack.
class DesktopEditSubpageShell extends StatefulWidget {
  const DesktopEditSubpageShell({
    super.key,
    required this.child,
    this.initiallyCollapsed = false,
    this.selectedIndex = 4,
    this.premiumSelected = false,
    this.onPremiumTap,
  });

  final Widget child;
  final bool initiallyCollapsed;
  final int selectedIndex;
  final bool premiumSelected;
  final VoidCallback? onPremiumTap;

  @override
  State<DesktopEditSubpageShell> createState() =>
      _DesktopEditSubpageShellState();
}

class _DesktopEditSubpageShellState extends State<DesktopEditSubpageShell> {
  late bool _collapsed;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.initiallyCollapsed;
  }

  void _leaveToTab(int index) {
    Navigator.of(context).popUntil((r) => r.isFirst);
    MainScreenBridge.navigateToTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090416),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RepaintBoundary(
            child: DesktopSidebar(
              selectedIndex: widget.selectedIndex,
              onSelect: _leaveToTab,
              collapsed: _collapsed,
              onToggleCollapse: widget.initiallyCollapsed
                  ? () => setState(() => _collapsed = !_collapsed)
                  : null,
              premiumSelected: widget.premiumSelected,
              onPremiumTap: widget.onPremiumTap,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const DesktopContentTopBar(),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile keeps [mobile]; tablet/desktop wrap [desktop] in the shared shell.
///
/// Uses [WidgetBuilder] so only the active layout is built (building both
/// mobile + desktop trees on every setState was a major open/close lag source).
class ProfileEditResponsive extends StatelessWidget {
  const ProfileEditResponsive({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  final WidgetBuilder mobile;
  final WidgetBuilder desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bp = breakpointOf(constraints.maxWidth);
        if (bp == AppBreakpoint.mobile) return mobile(context);
        return DesktopEditSubpageShell(
          initiallyCollapsed: bp == AppBreakpoint.tablet,
          child: desktop(context),
        );
      },
    );
  }
}

/// Snappy push for Profile section screens (avoids heavy Material slide + rebuild).
Route<T> profileSectionRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 140),
    reverseTransitionDuration: const Duration(milliseconds: 110),
  );
}
