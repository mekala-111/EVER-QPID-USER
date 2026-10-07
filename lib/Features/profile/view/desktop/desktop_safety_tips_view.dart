import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

/// Desktop/tablet Safety Tips — presentation only; [onSupport] from [SafetyTipsScreen].
class DesktopSafetyTipsView extends StatelessWidget {
  const DesktopSafetyTipsView({super.key, required this.onSupport});

  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showHero = width >= 1100;
    final twoCol = width >= 900;

    return ColoredBox(
      color: const Color(0xFF050014),
      child: Stack(
        children: [
          const IgnorePointer(child: _AmbientDecor()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  width >= 1100 ? 36 : 24,
                  8,
                  width >= 1100 ? 36 : 24,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                      label: const Text('Back'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFB8B2C7),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _GlassPanel(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: showHero ? 7 : 1,
                                child: const _SafetyHeader(),
                              ),
                              if (showHero) ...[
                                const SizedBox(width: 16),
                                const Expanded(
                                  flex: 4,
                                  child: _SafetyHeroIllustration(),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 28),
                          _SafetyTipsGrid(
                            twoColumns: twoCol,
                            onSupport: onSupport,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyHeader extends StatelessWidget {
  const _SafetyHeader();

  static const _intro = "At Everqpid, we're here to help you find a meaningful "
      'relationship that leads to a lifelong commitment. We take '
      'your safety seriously and strive to create a space where '
      'trust, respect, and genuine intentions come first.';

  static const _priority =
      'We encourage all users to use the app mindfully, stay '
      'cautious when sharing information, and report any '
      'suspicious behavior immediately. Your safety is our '
      'top priority.';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Safety Tips',
              style: getTextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            const Text('🛡️', style: TextStyle(fontSize: 28)),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Stay safe while making meaningful connections',
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: WelcomeTheme.violetSoft,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          _intro,
          style: getTextStyle(
            fontSize: 14.5,
            height: 1.55,
            color: const Color(0xFFB8B2C7),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _priority,
          style: getTextStyle(
            fontSize: 14.5,
            height: 1.55,
            color: const Color(0xFFB8B2C7),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Here are a few important things to keep in mind:',
          style: getTextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFE8E4F0),
          ),
        ),
      ],
    );
  }
}

class _SafetyHeroIllustration extends StatelessWidget {
  const _SafetyHeroIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  WelcomeTheme.violetSoft.withValues(alpha: 0.35),
                  WelcomeTheme.violet.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 28,
            child: Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: LinearGradient(
                  colors: [
                    WelcomeTheme.violetDeep.withValues(alpha: 0.15),
                    WelcomeTheme.violetSoft.withValues(alpha: 0.45),
                    WelcomeTheme.violetDeep.withValues(alpha: 0.15),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.35),
                    blurRadius: 18,
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.shield_rounded,
            size: 118,
            color: WelcomeTheme.violetSoft.withValues(alpha: 0.95),
            shadows: [
              Shadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.65),
                blurRadius: 28,
              ),
            ],
          ),
          const Icon(
            Icons.favorite_rounded,
            size: 42,
            color: Colors.white,
          ),
          const Positioned(
            top: 28,
            right: 36,
            child: Icon(Icons.favorite, size: 16, color: Color(0xFFC084FC)),
          ),
          const Positioned(
            top: 48,
            left: 40,
            child: Icon(Icons.favorite, size: 12, color: Color(0xFFA855F7)),
          ),
          const Positioned(
            bottom: 62,
            right: 48,
            child: Icon(Icons.auto_awesome, size: 14, color: Color(0xFFC084FC)),
          ),
        ],
      ),
    );
  }
}

class _SafetyTipsGrid extends StatelessWidget {
  const _SafetyTipsGrid({
    required this.twoColumns,
    required this.onSupport,
  });

  final bool twoColumns;
  final VoidCallback onSupport;

  @override
  Widget build(BuildContext context) {
    final cards = [
      const _SafetyTipCard(
        icon: Icons.lock_outline_rounded,
        title: 'Sharing Personal Details',
        lines: [
          '🔒 Your privacy matters. Don’t share personal info too soon.',
          '🚩 If someone rushes to move off Everqpid, stay cautious.',
          '💖 Take it slow — your comfort and safety come first.',
        ],
      ),
      const _SafetyTipCard(
        icon: Icons.location_on_outlined,
        title: 'Meeting in Person',
        lines: [
          '🍷 Your safety comes first.',
          '📍 Meet in public places for the first few times.',
          '👥 Let a friend or family member know your plans.',
          '📱 Keep your phone charged and with you.',
          '💗 Take your time — real connections don’t need rushing.',
        ],
      ),
      const _SafetyTipCard(
        icon: Icons.warning_amber_rounded,
        title: 'Watch for Warning Signs',
        lines: [
          '😕 Avoid people who are disrespectful, aggressive or make you uncomfortable.',
          '🚫 Never feel pressured to share personal information or photos.',
          '⚠️ Report any suspicious or inappropriate behavior immediately.',
        ],
      ),
      _SafetyTipCard(
        icon: Icons.headset_mic_outlined,
        title: 'Need Help?',
        lines: const [
          "If you ever feel unsafe or need assistance, we're here for you.",
        ],
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _SupportButton(onTap: onSupport),
            const SizedBox(height: 14),
            Text(
              "Your well-being is our priority.\nWe're always here to help.",
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 13,
                height: 1.45,
                color: const Color(0xFF8C859C),
              ),
            ),
          ],
        ),
      ),
    ];

    if (!twoColumns) {
      return Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            cards[i],
          ],
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cards[2]),
            const SizedBox(width: 14),
            Expanded(child: cards[3]),
          ],
        ),
      ],
    );
  }
}

class _SafetyTipCard extends StatefulWidget {
  const _SafetyTipCard({
    required this.icon,
    required this.title,
    required this.lines,
    this.footer,
  });

  final IconData icon;
  final String title;
  final List<String> lines;
  final Widget? footer;

  @override
  State<_SafetyTipCard> createState() => _SafetyTipCardState();
}

class _SafetyTipCardState extends State<_SafetyTipCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF130927).withValues(alpha: 0.88),
          border: Border.all(
            color: _hover
                ? WelcomeTheme.violetSoft.withValues(alpha: 0.55)
                : const Color(0xFFA855F7).withValues(alpha: 0.22),
          ),
          boxShadow: [
            if (_hover)
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.22),
                blurRadius: 22,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: WelcomeTheme.violet.withValues(alpha: 0.18),
                border: Border.all(
                  color: WelcomeTheme.violetSoft.withValues(alpha: 0.35),
                ),
              ),
              child:
                  Icon(widget.icon, color: WelcomeTheme.violetSoft, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: getTextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: WelcomeTheme.violetSoft,
              ),
            ),
            const SizedBox(height: 12),
            for (final line in widget.lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  line,
                  style: getTextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: const Color(0xFFB8B2C7),
                  ),
                ),
              ),
            if (widget.footer != null) widget.footer!,
          ],
        ),
      ),
    );
  }
}

class _SupportButton extends StatefulWidget {
  const _SupportButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_SupportButton> createState() => _SupportButtonState();
}

class _SupportButtonState extends State<_SupportButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: _hover
                  ? const [Color(0xFFB65CFF), Color(0xFF9B4DFF)]
                  : const [Color(0xFF9B4DFF), Color(0xFF6D28D9)],
            ),
            boxShadow: [
              BoxShadow(
                color:
                    WelcomeTheme.violet.withValues(alpha: _hover ? 0.45 : 0.28),
                blurRadius: _hover ? 18 : 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Report or Contact Support',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: const Color(0xFF0C051E).withValues(alpha: 0.82),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.28),
        ),
        boxShadow: [
          BoxShadow(
            color: WelcomeTheme.violet.withValues(alpha: 0.12),
            blurRadius: 40,
          ),
        ],
      ),
      child: child,
    );
  }
}

class _AmbientDecor extends StatelessWidget {
  const _AmbientDecor();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _AmbientPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = const Color(0xFF9B4DFF).withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.9, 90), 160, glow);
    canvas.drawCircle(Offset(30, size.height * 0.7), 130, glow);

    final star = Paint()..color = Colors.white.withValues(alpha: 0.35);
    for (final o in [
      Offset(size.width * 0.2, 60),
      Offset(size.width * 0.72, 40),
      Offset(size.width * 0.55, size.height * 0.85),
      Offset(size.width * 0.15, size.height * 0.45),
      Offset(size.width * 0.88, size.height * 0.35),
    ]) {
      canvas.drawCircle(o, 1.2, star);
    }

    final line = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.7, 0)
        ..quadraticBezierTo(
          size.width * 0.95,
          size.height * 0.25,
          size.width,
          size.height * 0.48,
        ),
      line,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.35, size.height)
        ..quadraticBezierTo(
          size.width * 0.7,
          size.height * 0.88,
          size.width,
          size.height * 0.78,
        ),
      line,
    );

    final heart = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    void drawHeart(Offset c, double s) {
      final p = Path()
        ..moveTo(c.dx, c.dy + s * 0.3)
        ..cubicTo(
          c.dx - s,
          c.dy - s * 0.4,
          c.dx - s * 1.1,
          c.dy + s * 0.6,
          c.dx,
          c.dy + s * 1.2,
        )
        ..cubicTo(
          c.dx + s * 1.1,
          c.dy + s * 0.6,
          c.dx + s,
          c.dy - s * 0.4,
          c.dx,
          c.dy + s * 0.3,
        );
      canvas.drawPath(p, heart);
    }

    drawHeart(Offset(48, 140), 10);
    drawHeart(Offset(size.width - 64, size.height * 0.58), 9);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
