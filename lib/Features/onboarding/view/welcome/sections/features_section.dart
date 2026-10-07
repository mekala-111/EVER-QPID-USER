import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/glass_card.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/section_heading.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingSectionPad(
      child: Column(
        children: [
          const SectionHeading(
            eyebrow: 'Features',
            title: 'Everything you need to\n',
            highlight: 'find something real',
            subtitle:
                'Smart features designed to help you discover,\nconnect and build meaningful relationships.',
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth >= 960
                  ? 3
                  : c.maxWidth >= 640
                      ? 2
                      : 1;
              const gap = 20.0;
              final tileW = (c.maxWidth - gap * (cols - 1)) / cols;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final f in WelcomeTheme.features)
                    SizedBox(
                      width: tileW,
                      child: GlassCard(
                        child: Column(
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    WelcomeTheme.violetSoft.withValues(alpha: 0.55),
                                    WelcomeTheme.violetDeep.withValues(alpha: 0.15),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: WelcomeTheme.violet.withValues(alpha: 0.4),
                                    blurRadius: 22,
                                  ),
                                ],
                              ),
                              child: Icon(f.icon, color: Colors.white, size: 30),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              f.title,
                              textAlign: TextAlign.center,
                              style: getTextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              f.subtitle,
                              textAlign: TextAlign.center,
                              style: getTextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.58),
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
