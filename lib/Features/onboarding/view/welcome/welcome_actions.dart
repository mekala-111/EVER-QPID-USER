import 'package:everqpidapp/Features/onboarding/view/email_login_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/onboarding_1.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_login_dialog.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Shared welcome navigation / business actions — used by mobile + web views.
abstract final class WelcomeActions {
  /// Primary CTA — web desktop opens login modal; mobile opens auth screen.
  static void openLogin(BuildContext context) {
    final wide =
        MediaQuery.sizeOf(context).width >= WelcomeTheme.desktopBreakpoint;

    if (kIsWeb && wide) {
      WelcomeLoginDialog.show(context);
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 320),
        pageBuilder: (_, __, ___) => const Onboarding1(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  /// Alias kept for older call sites.
  static void openPhoneLogin(BuildContext context) => openLogin(context);

  static void openEmailLogin(BuildContext context) {
    if (kIsWeb &&
        MediaQuery.sizeOf(context).width >= WelcomeTheme.desktopBreakpoint) {
      WelcomeLoginDialog.show(context);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
    );
  }
}
