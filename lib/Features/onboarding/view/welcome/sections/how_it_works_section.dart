import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/glass_card.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/section_heading.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

class HowItWorksSection extends StatelessWidget {
  const HowItWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingSectionPad(
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'How it works',
            title: 'Finding your person\n',
            highlight: 'should feel simple.',
          ),
          const SizedBox(height: 56),
          LayoutBuilder(
            builder: (context, c) {
              final wide = c.maxWidth >= 900;
              if (!wide) {
                return Column(
                  children: [
                    for (final step in WelcomeTheme.howItWorks) ...[
                      _StepCard(step: step),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              }
              return SizedBox(
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 80,
                      right: 80,
                      top: 70,
                      child: CustomPaint(
                        painter: _ConnectorPainter(),
                        size: Size(c.maxWidth - 160, 4),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < WelcomeTheme.howItWorks.length; i++) ...[
                          if (i > 0) const SizedBox(width: 20),
                          Expanded(child: _StepCard(step: WelcomeTheme.howItWorks[i])),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});
  final WelcomeStep step;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.number,
            style: getTextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: WelcomeTheme.violetSoft,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: WelcomeTheme.violet.withValues(alpha: 0.18),
            ),
            child: Icon(step.icon, color: WelcomeTheme.violetLight),
          ),
          const SizedBox(height: 16),
          Text(
            step.title,
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            step.subtitle,
            style: getTextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.58),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          WelcomeTheme.violet.withValues(alpha: 0.15),
          WelcomeTheme.violetLight.withValues(alpha: 0.7),
          WelcomeTheme.violet.withValues(alpha: 0.15),
        ],
      ).createShader(Offset.zero & size)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height / 2)
      ..quadraticBezierTo(size.width / 2, -18, size.width, size.height / 2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
