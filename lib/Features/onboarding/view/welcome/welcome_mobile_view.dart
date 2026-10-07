import 'dart:async';

import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_auth_view.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_shared_widgets.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';

/// Mobile welcome — JoinPage-style splash (bg + logo), then auth entry.
class WelcomeMobileView extends StatefulWidget {
  const WelcomeMobileView({super.key, required this.animations});

  /// Kept for [WelcomeScreen] API compatibility.
  final WelcomeIntroAnimations animations;

  @override
  State<WelcomeMobileView> createState() => _WelcomeMobileViewState();
}

class _WelcomeMobileViewState extends State<WelcomeMobileView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), _goAuth);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goAuth() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, __, ___) => const WelcomeAuthView(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              Images.bgMb,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: WelcomeTheme.bgTop,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: widget.animations.logoFade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Images.cupid,
                    width: size.width * 0.4,
                    height: size.width * 0.4,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      Images.everqpid,
                      width: size.width * 0.5,
                      fit: BoxFit.contain,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Looking for your Qpid',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: WelcomeTheme.violetLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
