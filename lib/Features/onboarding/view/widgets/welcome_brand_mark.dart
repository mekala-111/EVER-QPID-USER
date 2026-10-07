import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';

/// Centered EverQpid mark used over the mobile collage.
class WelcomeBrandMark extends StatelessWidget {
  const WelcomeBrandMark({super.key});

  static const heroTag = 'welcome-brand-mark';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Hero(
          tag: heroTag,
          child: Material(
            type: MaterialType.transparency,
            child: Image.asset(
              Images.everqpid,
              height: 42,
              color: Colors.white,
              errorBuilder: (_, __, ___) => Text(
                'EverQpid',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const PulsingWelcomeHeart(size: 38),
      ],
    );
  }
}

/// Hand-drawn heart with a soft pulse (used on collage + headline).
class PulsingWelcomeHeart extends StatefulWidget {
  const PulsingWelcomeHeart({super.key, this.size = 48});

  final double size;

  @override
  State<PulsingWelcomeHeart> createState() => _PulsingWelcomeHeartState();
}

class _PulsingWelcomeHeartState extends State<PulsingWelcomeHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scale = Tween(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
    _glow = Tween(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: WelcomeTheme.violetLight.withValues(alpha: _glow.value),
                  blurRadius: 18 + (_glow.value * 10),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: WelcomeHandDrawnHeart(size: widget.size),
    );
  }
}

/// Simple sketched heart outline.
class WelcomeHandDrawnHeart extends StatelessWidget {
  const WelcomeHandDrawnHeart({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 0.9),
      painter: _HeartPainter(color: WelcomeTheme.violetLight),
    );
  }
}

class _HeartPainter extends CustomPainter {
  _HeartPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w * 0.5, h * 0.92)
      ..cubicTo(w * 0.15, h * 0.65, w * 0.0, h * 0.35, w * 0.25, h * 0.18)
      ..cubicTo(w * 0.38, h * 0.05, w * 0.5, h * 0.18, w * 0.5, h * 0.32)
      ..cubicTo(w * 0.5, h * 0.18, w * 0.62, h * 0.05, w * 0.75, h * 0.18)
      ..cubicTo(w * 1.0, h * 0.35, w * 0.85, h * 0.65, w * 0.5, h * 0.92);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _HeartPainter oldDelegate) =>
      oldDelegate.color != color;
}
