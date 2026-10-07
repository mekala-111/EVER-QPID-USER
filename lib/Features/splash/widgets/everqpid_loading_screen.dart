import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/splash/widgets/animated_glow.dart';
import 'package:everqpidapp/Features/splash/widgets/floating_heart.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';

/// Premium EverQpid boot / gate loading UI (dark violet, love-themed).
class EverQpidLoadingScreen extends StatefulWidget {
  const EverQpidLoadingScreen({super.key});

  static const Color bg = Color(0xFF090415);

  @override
  State<EverQpidLoadingScreen> createState() => _EverQpidLoadingScreenState();
}

class _EverQpidLoadingScreenState extends State<EverQpidLoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _glow;
  late final AnimationController _hearts;
  late final AnimationController _loader;

  late final Animation<double> _iconFade;
  late final Animation<double> _iconScale;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _tagFade;
  late final Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _hearts = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 9),
    )..repeat();
    _loader = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _iconFade = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _iconScale = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _enter,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );
    _nameFade = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.28, 0.7, curve: Curves.easeOut),
    );
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enter,
        curve: const Interval(0.28, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _tagFade = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.5, 0.9, curve: Curves.easeOut),
    );
    _loaderFade = CurvedAnimation(
      parent: _enter,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _enter.forward();
  }

  @override
  void dispose() {
    _enter.dispose();
    _glow.dispose();
    _hearts.dispose();
    _loader.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 768;
    final iconSize = wide ? 100.0 : 80.0;
    final nameWidth = wide ? 200.0 : 160.0;
    final tagSize = wide ? 17.0 : 15.0;
    final heartCount = wide ? 8 : 5;

    return Scaffold(
      backgroundColor: EverQpidLoadingScreen.bg,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF080313),
              Color(0xFF15072D),
              Color(0xFF090415),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background glows — isolated so logo text doesn't rebuild.
            RepaintBoundary(
              child: Stack(
                children: [
                  AnimatedGlow(
                    animation: _glow,
                    alignment: const Alignment(0, -0.15),
                    size: wide ? 420 : 300,
                    baseOpacity: 0.42,
                  ),
                  AnimatedGlow(
                    animation: _glow,
                    alignment: const Alignment(0.85, -0.75),
                    size: wide ? 220 : 160,
                    color: WelcomeTheme.violetSoft,
                    baseOpacity: 0.22,
                  ),
                  AnimatedGlow(
                    animation: _glow,
                    alignment: const Alignment(-0.9, 0.85),
                    size: wide ? 260 : 180,
                    color: WelcomeTheme.violetDeep,
                    baseOpacity: 0.2,
                  ),
                ],
              ),
            ),
            RepaintBoundary(
              child: Stack(
                children: [
                  for (var i = 0; i < heartCount; i++)
                    FloatingHeart(
                      animation: _hearts,
                      left: size.width * _heartX[i],
                      top: size.height * _heartY[i],
                      size: _heartSizes[i],
                      phase: i / heartCount,
                      maxOpacity: 0.08 + (i % 3) * 0.05,
                    ),
                ],
              ),
            ),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Desktop/mobile vertical bias ~40–45% via spacer ratio.
                      SizedBox(height: size.height * (wide ? 0.06 : 0.08)),
                      FadeTransition(
                        opacity: _iconFade,
                        child: ScaleTransition(
                          scale: _iconScale,
                          child: AnimatedBuilder(
                            animation: _glow,
                            builder: (context, child) {
                              final breath = 0.35 + _glow.value * 0.2;
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: WelcomeTheme.violet
                                          .withValues(alpha: breath),
                                      blurRadius: 36,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: child,
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                Images.appIcon,
                                width: iconSize,
                                height: iconSize,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: iconSize,
                                  height: iconSize,
                                  color: WelcomeTheme.violetDeep,
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      FadeTransition(
                        opacity: _nameFade,
                        child: SlideTransition(
                          position: _nameSlide,
                          child: Image.asset(
                            Images.everqpid,
                            width: nameWidth,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Text(
                              'EverQpid',
                              style: getTextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FadeTransition(
                        opacity: _tagFade,
                        child: Text(
                          'Where meaningful connections begin.',
                          textAlign: TextAlign.center,
                          style: getTextStyle(
                            fontSize: tagSize,
                            color: Colors.white.withValues(alpha: 0.7),
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _loaderFade,
                        child: Column(
                          children: [
                            _VioletRingLoader(controller: _loader),
                            const SizedBox(height: 14),
                            Text(
                              'Finding something special...',
                              style: getTextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _heartX = [0.08, 0.78, 0.18, 0.88, 0.12, 0.72, 0.42, 0.92];
  static const _heartY = [0.18, 0.22, 0.62, 0.55, 0.78, 0.72, 0.12, 0.38];
  static const _heartSizes = [20.0, 28.0, 14.0, 36.0, 22.0, 16.0, 30.0, 18.0];
}

class _VioletRingLoader extends StatelessWidget {
  const _VioletRingLoader({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _RingPainter(
              progress: controller.value,
              color: WelcomeTheme.violetLight,
              colorSoft: WelcomeTheme.violetSoft,
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.colorSoft,
  });

  final double progress;
  final Color color;
  final Color colorSoft;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final bg = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius, bg);

    final sweep = 1.6;
    final start = progress * 6.2832;
    final fg = Paint()
      ..shader = SweepGradient(
        colors: [colorSoft, color, colorSoft.withValues(alpha: 0.1)],
        startAngle: start,
        endAngle: start + sweep,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
