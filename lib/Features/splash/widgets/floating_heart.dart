import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:flutter/material.dart';

/// Thin violet heart outline — floats via parent [Animation].
class FloatingHeart extends StatelessWidget {
  const FloatingHeart({
    super.key,
    required this.animation,
    required this.left,
    required this.top,
    required this.size,
    required this.phase,
    this.maxOpacity = 0.2,
  });

  final Animation<double> animation;
  final double left;
  final double top;
  final double size;
  final double phase;
  final double maxOpacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = (animation.value + phase) % 1.0;
        final dy = -18 * t;
        final dx = 6 * (t < 0.5 ? t * 2 : (1 - t) * 2) - 3;
        final opacity = maxOpacity *
            (t < 0.5 ? t * 2 : (1 - t) * 2).clamp(0.15, 1.0);
        final scale = 0.92 + 0.1 * (0.5 - (t - 0.5).abs()) * 2;

        return Positioned(
          left: left + dx,
          top: top + dy,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Icon(
                Icons.favorite_border_rounded,
                size: size,
                color: WelcomeTheme.violetLight,
              ),
            ),
          ),
        );
      },
    );
  }
}
