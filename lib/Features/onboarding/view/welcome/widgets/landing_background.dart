import 'dart:math' as math;

import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:flutter/material.dart';

/// Full-viewport violet atmosphere behind the scrollable landing content.
class LandingBackground extends StatefulWidget {
  const LandingBackground({super.key});

  @override
  State<LandingBackground> createState() => _LandingBackgroundState();
}

class _LandingBackgroundState extends State<LandingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Positioned.fill(
      child: IgnorePointer(
        child: ColoredBox(
          color: WelcomeTheme.pageBg,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, _) {
              final t = _pulse.value;
              return Stack(
                children: [
                  _glow(
                    top: -size.height * 0.1,
                    left: size.width * 0.2,
                    width: size.width * 0.6,
                    height: size.height * 0.45,
                    color: WelcomeTheme.violetGlow.withValues(alpha: 0.32 + t * 0.08),
                  ),
                  _glow(
                    top: size.height * 0.35,
                    right: -size.width * 0.1,
                    width: size.width * 0.5,
                    height: size.height * 0.55,
                    color: WelcomeTheme.violetSoft.withValues(alpha: 0.22 + t * 0.06),
                  ),
                  _glow(
                    top: size.height * 0.7,
                    left: -80,
                    width: 320,
                    height: 320,
                    color: WelcomeTheme.violetDeep.withValues(alpha: 0.2),
                  ),
                  _glow(
                    bottom: -40,
                    left: size.width * 0.25,
                    right: size.width * 0.25,
                    height: 260,
                    color: WelcomeTheme.violet.withValues(alpha: 0.18),
                  ),
                  ..._particles(size, t),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _glow({
    double? top,
    double? left,
    double? right,
    double? bottom,
    double? width,
    double? height,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      ),
    );
  }

  List<Widget> _particles(Size size, double t) {
    // ponytail: fixed decorative hearts, real particle system if motion design expands
    final rng = math.Random(7);
    return List.generate(12, (i) {
      final x = rng.nextDouble();
      final y = rng.nextDouble();
      final drift = math.sin((t + i) * math.pi) * 8;
      return Positioned(
        left: size.width * x,
        top: size.height * y + drift,
        child: Icon(
          i.isEven ? Icons.favorite : Icons.favorite_border,
          size: 8 + (i % 4) * 2.0,
          color: WelcomeTheme.violetLight.withValues(alpha: 0.12 + (i % 3) * 0.04),
        ),
      );
    });
  }
}
