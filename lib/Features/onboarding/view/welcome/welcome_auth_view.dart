import 'package:everqpidapp/Features/onboarding/view/phone_login_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/google_auth_flow.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/p_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Figma mobile welcome / auth entry — match pixel-for-pixel.
class WelcomeAuthView extends StatelessWidget {
  const WelcomeAuthView({super.key});

  static const _manPhoto =
      'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=600&q=80';
  static const _womanPhoto =
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=600&q=80';

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF080015),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // Background glows
            Positioned(
              top: MediaQuery.sizeOf(context).height * 0.18,
              left: -40,
              right: -40,
              height: 340,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      WelcomeTheme.violetSoft.withValues(alpha: 0.45),
                      WelcomeTheme.violet.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 40,
              right: 40,
              height: 200,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      WelcomeTheme.violetDeep.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(28, 12, 28, bottom > 0 ? 8 : 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const _EverqpidScriptLogo(),
                    const Spacer(flex: 2),
                    const _DualPhotoCollage(
                      topUrl: _manPhoto,
                      bottomUrl: _womanPhoto,
                    ),
                    const Spacer(flex: 3),
                    _GlowOutlineButton(
                      onPressed: () => GoogleAuthFlow.signIn(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _GoogleGlyph(),
                          const SizedBox(width: 12),
                          Text(
                            'Continue with Google',
                            style: getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _GlowOutlineButton(
                      onPressed: () => _openPhone(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smartphone_outlined,
                            color: Colors.white.withValues(alpha: 0.95),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Use Mobile Number',
                            style: getTextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const _LegalFooter(),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _openPhone(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
    );
  }
}

/// Script-style Everqpid wordmark: white + violet "q" + heart over "i".
class _EverqpidScriptLogo extends StatelessWidget {
  const _EverqpidScriptLogo();

  @override
  Widget build(BuildContext context) {
    const script = TextStyle(
      fontFamily: 'Georgia',
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w600,
      fontSize: 42,
      height: 1.1,
      letterSpacing: -0.5,
    );

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Text.rich(
          TextSpan(
            style: script.copyWith(color: Colors.white),
            children: const [
              TextSpan(text: 'Ever'),
              TextSpan(
                text: 'q',
                style: TextStyle(color: Color(0xFFB794F6)),
              ),
              TextSpan(text: 'pid'),
            ],
          ),
        ),
        // Soft heart / cloud above the "i"
        Positioned(
          right: 28,
          top: -6,
          child: Icon(
            Icons.favorite,
            size: 14,
            color: WelcomeTheme.violetLight.withValues(alpha: 0.95),
            shadows: [
              Shadow(
                color: WelcomeTheme.violetSoft.withValues(alpha: 0.9),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DualPhotoCollage extends StatelessWidget {
  const _DualPhotoCollage({required this.topUrl, required this.bottomUrl});

  final String topUrl;
  final String bottomUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Neon arc trails
          Positioned.fill(
            child: CustomPaint(painter: _NeonArcsPainter()),
          ),
          // Bottom-left photo (woman) — tilted left
          Positioned(
            left: 8,
            bottom: 8,
            child: Transform.rotate(
              angle: -0.14,
              child: _FramedPhoto(url: bottomUrl, width: 148, height: 188),
            ),
          ),
          // Top-right photo (man) — tilted right
          Positioned(
            right: 4,
            top: 4,
            child: Transform.rotate(
              angle: 0.12,
              child: _FramedPhoto(url: topUrl, width: 158, height: 200),
            ),
          ),
          // Heart badges
          const Positioned(
            right: 18,
            top: 0,
            child: _HeartBadge(),
          ),
          const Positioned(
            left: 22,
            bottom: 24,
            child: _HeartBadge(),
          ),
        ],
      ),
    );
  }
}

class _FramedPhoto extends StatelessWidget {
  const _FramedPhoto({
    required this.url,
    required this.width,
    required this.height,
  });

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0F5),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ColoredBox(
            color: WelcomeTheme.violet.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }
}

class _HeartBadge extends StatelessWidget {
  const _HeartBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF12081F).withValues(alpha: 0.85),
        border: Border.all(color: WelcomeTheme.violetLight, width: 1.6),
        boxShadow: [
          BoxShadow(
            color: WelcomeTheme.violetSoft.withValues(alpha: 0.75),
            blurRadius: 14,
          ),
        ],
      ),
      child: const Icon(Icons.favorite, color: Colors.white, size: 16),
    );
  }
}

class _NeonArcsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    final cx = size.width * 0.42;
    final cy = size.height * 0.48;

    for (var i = 0; i < 5; i++) {
      final t = i / 4;
      paint.color = WelcomeTheme.violetLight.withValues(alpha: 0.55 - t * 0.08);
      final rx = size.width * (0.28 + i * 0.07);
      final ry = size.height * (0.38 + i * 0.08);
      final rect = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
      canvas.drawArc(rect, -math.pi * 0.85, math.pi * 1.05, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowOutlineButton extends StatefulWidget {
  const _GlowOutlineButton({required this.onPressed, required this.child});

  final VoidCallback onPressed;
  final Widget child;

  @override
  State<_GlowOutlineButton> createState() => _GlowOutlineButtonState();
}

class _GlowOutlineButtonState extends State<_GlowOutlineButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1,
        duration: const Duration(milliseconds: 160),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(40),
            child: Ink(
              height: 54,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: const Color(0xFF140A24).withValues(alpha: 0.72),
                border: Border.all(
                  color: WelcomeTheme.violetSoft.withValues(alpha: 0.95),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.45),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    // Compact multi-color "G" mark without an asset.
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.width / 2;
    final stroke = size.width * 0.18;
    final rect = Rect.fromCircle(center: Offset(r, r), radius: r - stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 0.55, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 0.05, math.pi * 0.55, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, math.pi * 0.6, math.pi * 0.45, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, math.pi * 1.05, math.pi * 0.45, false, paint);

    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(r - stroke * 0.1, r - stroke * 0.55, r * 0.95, stroke),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    final base = getTextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.72),
      height: 1.45,
    );
    final link = base.copyWith(
      color: WelcomeTheme.violetLight,
      decoration: TextDecoration.underline,
      decorationColor: WelcomeTheme.violetLight,
    );

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          const TextSpan(text: 'By Signing Up, You Agree To Our '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, PPages.termsConditionsScreen),
              child: Text('Terms', style: link),
            ),
          ),
          const TextSpan(text: '. See How We Use Your Data In Our '),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, PPages.privacyPolicyScreen),
              child: Text('Privacy Policy', style: link),
            ),
          ),
          const TextSpan(text: '.'),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
