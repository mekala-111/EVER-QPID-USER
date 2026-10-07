import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    super.key,
    this.eyebrow,
    required this.title,
    this.highlight,
    this.subtitle,
    this.align = TextAlign.center,
  });

  final String? eyebrow;
  final String title;
  final String? highlight;
  final String? subtitle;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final cross = align == TextAlign.left
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: cross,
      children: [
        if (eyebrow != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: WelcomeTheme.violet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: WelcomeTheme.violet.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              eyebrow!.toUpperCase(),
              style: getTextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: WelcomeTheme.violetLight,
                letterSpacing: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text.rich(
          TextSpan(
            style: getTextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.15,
            ),
            children: [
              TextSpan(text: title),
              if (highlight != null)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (b) =>
                        WelcomeTheme.partnerGradient.createShader(b),
                    child: Text(
                      highlight!,
                      style: getTextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.15,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          textAlign: align,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              subtitle!,
              textAlign: align,
              style: getTextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.58),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class LandingSectionPad extends StatelessWidget {
  const LandingSectionPad({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final padH = WelcomeTheme.horizontalPad(w);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        padH,
        WelcomeTheme.sectionPadV,
        padH,
        WelcomeTheme.sectionPadV * 0.35,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: WelcomeTheme.contentMaxWidth),
          child: child,
        ),
      ),
    );
  }
}
