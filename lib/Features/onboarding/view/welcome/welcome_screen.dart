import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_shared_widgets.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_web_view.dart';
import 'package:flutter/material.dart';

/// Unauthenticated landing — one scrollable marketing page on all widths.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final WelcomeIntroAnimations _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _animations = WelcomeIntroAnimations(
      logoFade: CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
      ),
      headlineFade: CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.65, curve: Curves.easeOut),
      ),
      headlineSlide: Tween<Offset>(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
        ),
      ),
      ctaFade: CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.9, curve: Curves.easeOut),
      ),
      ctaScale: Tween<double>(begin: 0.94, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.45, 1.0, curve: Curves.easeOutBack),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Full landing on every width (sections stay visible below Hero).
    return WelcomeWebView(animations: _animations);
  }
}
