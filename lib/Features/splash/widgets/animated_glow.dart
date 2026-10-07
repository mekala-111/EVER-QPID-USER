import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:flutter/material.dart';

/// Soft violet radial orb — animates via parent [Animation], no own ticker.
class AnimatedGlow extends StatelessWidget {
  const AnimatedGlow({
    super.key,
    required this.animation,
    required this.alignment,
    required this.size,
    this.color,
    this.baseOpacity = 0.35,
  });

  final Animation<double> animation;
  final Alignment alignment;
  final double size;
  final Color? color;
  final double baseOpacity;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final t = animation.value;
          final scale = 0.92 + t * 0.12;
          final opacity = baseOpacity * (0.75 + t * 0.35);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (color ?? WelcomeTheme.violet).withValues(alpha: opacity),
                    (color ?? WelcomeTheme.violetSoft)
                        .withValues(alpha: opacity * 0.35),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
