import 'package:everqpidapp/Features/onboarding/view/profile_intro_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/email_auth_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/helper/permission_manager.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shared Google sign-in → backend session / onboarding navigation.
abstract final class GoogleAuthFlow {
  static Future<void> signIn(BuildContext context, {VoidCallback? onCloseHost}) async {
    final authVm = context.read<AuthViewModel>();
    final emailVm = context.read<EmailAuthViewModel>();

    _showStatus(context, signingIn: true);

    final outcome = await authVm.signInWithGoogle();

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    switch (outcome.status) {
      case GoogleSignInStatus.cancelled:
        return;
      case GoogleSignInStatus.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(outcome.message ?? 'Google sign-in failed'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      case GoogleSignInStatus.success:
        break;
    }

    final email = outcome.email!;
    final idToken = outcome.idToken!;

    _showStatus(context, signingIn: true);

    final loggedIn = await emailVm.googleLogin(idToken: idToken, email: email);

    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (loggedIn) {
      onCloseHost?.call();
      _showStatus(context, signingIn: false);
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pushNamedAndRemoveUntil(
        context,
        PPages.mainScreen,
        (route) => false,
      );
      PermissionManager.showAfterLogin();
      return;
    }

    emailVm.setVerifiedEmail(email);
    final exists = await emailVm.checkUserExists();
    if (!context.mounted) return;

    onCloseHost?.call();

    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailVm.errorMessage ??
                'Could not complete Google login. Try phone login, or ask support to enable google-login.',
          ),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UnifiedOnboardingScreen(isPhone: false),
      ),
    );
  }

  static void _showStatus(BuildContext context, {required bool signingIn}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => _GoogleStatusDialog(signingIn: signingIn),
    );
  }
}

class _GoogleStatusDialog extends StatelessWidget {
  const _GoogleStatusDialog({required this.signingIn});
  final bool signingIn;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0E0A1A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: WelcomeTheme.violet.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 40, 36, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (signingIn) ...[
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: WelcomeTheme.violetSoft,
                      ),
                    ),
                    Text(
                      'G',
                      style: getTextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF4285F4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Signing in with Google',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please wait while we authenticate your account...',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
            ] else ...[
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: WelcomeTheme.violetSoft,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 22),
              Text(
                'Login successful!',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Redirecting you to Everqpid...',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: WelcomeTheme.violetSoft,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
