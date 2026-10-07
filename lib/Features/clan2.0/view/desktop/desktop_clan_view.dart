import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';

/// Desktop/tablet Clan — coming-soon presentation inside MainScreen shell.
class DesktopClanView extends StatelessWidget {
  const DesktopClanView({super.key});

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final w = MediaQuery.sizeOf(context).width;
    final cardCols = w >= 1100 ? 3 : (w >= 900 ? 3 : 1);

    return ColoredBox(
      color: const Color(0xFF050315),
      child: Stack(
        children: [
          const IgnorePointer(child: _AmbientDecor()),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(32, 12, 32, 40),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: w < 900 ? 24 : 48,
                    vertical: 40,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: const Color(0xFF120A1F).withValues(alpha: 0.72),
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
                  child: Column(
                    children: [
                      Image.asset(
                        Images.clanSoon,
                        height: 280,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.favorite_rounded,
                          size: 120,
                          color: WelcomeTheme.violetSoft.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Plans are coming soon',
                        textAlign: TextAlign.center,
                        style: getTextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Something exciting is on the way.',
                        textAlign: TextAlign.center,
                        style: getTextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: WelcomeTheme.violetSoft,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          'Connect beyond matches. Meet people, build communities,\n'
                          'share interests and find your clan.',
                          textAlign: TextAlign.center,
                          style: getTextStyle(
                            fontSize: 15,
                            color: const Color(0xFFB9AFC8),
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      _FeatureGrid(cols: cardCols, reduceMotion: reduce),
                      const SizedBox(height: 28),
                      const _NotifyBar(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.cols, required this.reduceMotion});
  final int cols;
  final bool reduceMotion;

  static const _items = [
    (
      Icons.groups_rounded,
      'Meet Your People',
      'Find and connect with\nlike-minded members.',
    ),
    (
      Icons.tag_rounded,
      'Interest-Based Clans',
      'Join clans that match\nyour passions.',
    ),
    (
      Icons.shield_moon_outlined,
      'Build Communities',
      'Create, chat and grow\nstrong communities.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (cols == 1) {
      return Column(
        children: [
          for (final item in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ComingSoonFeatureCard(
                icon: item.$1,
                title: item.$2,
                body: item.$3,
                reduceMotion: reduceMotion,
              ),
            ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final gap = 14.0;
        final itemW = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final item in _items)
              SizedBox(
                width: itemW,
                child: ComingSoonFeatureCard(
                  icon: item.$1,
                  title: item.$2,
                  body: item.$3,
                  reduceMotion: reduceMotion,
                ),
              ),
          ],
        );
      },
    );
  }
}

class ComingSoonFeatureCard extends StatefulWidget {
  const ComingSoonFeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.reduceMotion = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool reduceMotion;

  @override
  State<ComingSoonFeatureCard> createState() => _ComingSoonFeatureCardState();
}

class _ComingSoonFeatureCardState extends State<ComingSoonFeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lift = !widget.reduceMotion && _hover ? -3.0 : 0.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, lift, 0),
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF160B2A).withValues(alpha: 0.85),
          border: Border.all(
            color: WelcomeTheme.violet.withValues(alpha: _hover ? 0.55 : 0.28),
          ),
          boxShadow: _hover
              ? [
                  BoxShadow(
                    color: WelcomeTheme.violet.withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: WelcomeTheme.violet.withValues(alpha: 0.22),
                ),
                child: Text(
                  'Coming soon',
                  style: getTextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: WelcomeTheme.violetLight,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                    ),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.title,
                  style: getTextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.body,
                  style: getTextStyle(
                    fontSize: 13,
                    color: const Color(0xFFB9AFC8),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifyBar extends StatefulWidget {
  const _NotifyBar();

  @override
  State<_NotifyBar> createState() => _NotifyBarState();
}

class _NotifyBarState extends State<_NotifyBar> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: WelcomeTheme.violet.withValues(alpha: 0.22),
        ),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        spacing: 16,
        runSpacing: 14,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: WelcomeTheme.violet.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: WelcomeTheme.violetSoft,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Be the first to know',
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "We'll notify you when clans go live.",
                    style: getTextStyle(
                      fontSize: 13,
                      color: const Color(0xFFB9AFC8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          MouseRegion(
            onEnter: (_) => setState(() => _hover = true),
            onExit: (_) => setState(() => _hover = false),
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: WelcomeTheme.violet
                        .withValues(alpha: _hover ? 0.45 : 0.28),
                    blurRadius: _hover ? 18 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clan notifications are coming soon.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Notify me',
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
      ..color = const Color(0xFF9B51E0).withValues(alpha: 0.1);
    canvas.drawCircle(Offset(size.width * 0.85, 90), 160, glow);
    canvas.drawCircle(Offset(60, size.height * 0.7), 130, glow);

    final line = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.6, 0)
        ..quadraticBezierTo(
          size.width * 0.95,
          size.height * 0.2,
          size.width,
          size.height * 0.42,
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

    drawHeart(Offset(48, 140), 9);
    drawHeart(Offset(size.width - 64, size.height * 0.5), 8);

    final star = Paint()..color = Colors.white.withValues(alpha: 0.2);
    for (final o in [
      Offset(size.width * 0.2, 60),
      Offset(size.width * 0.5, size.height * 0.15),
      Offset(size.width * 0.9, size.height * 0.65),
    ]) {
      canvas.drawCircle(o, 1.3, star);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
