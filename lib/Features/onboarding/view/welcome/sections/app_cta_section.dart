import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_actions.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/gradient_button.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/section_heading.dart';
import 'package:everqpidapp/Features/onboarding/view/widgets/welcome_photo_collage.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

class AppCtaSection extends StatelessWidget {
  const AppCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingSectionPad(
      child: LayoutBuilder(
        builder: (context, c) {
          final stack = c.maxWidth < 900;
          final phone = SizedBox(
            height: stack ? 360 : 480,
            width: stack ? double.infinity : 360,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          WelcomeTheme.violetSoft.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      border: Border.all(
                        color: WelcomeTheme.violetLight.withValues(alpha: 0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: WelcomeTheme.violet.withValues(alpha: 0.35),
                          blurRadius: 40,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: const WelcomePhotoCollage(neon: true),
                  ),
                ),
              ],
            ),
          );

          final copy = Column(
            crossAxisAlignment:
                stack ? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  style: getTextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                  children: [
                    const TextSpan(text: 'Your next connection\n'),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (b) =>
                            WelcomeTheme.partnerGradient.createShader(b),
                        child: Text(
                          'is one swipe away.',
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
                textAlign: stack ? TextAlign.center : TextAlign.left,
              ),
              const SizedBox(height: 16),
              Text(
                'Join thousands discovering meaningful matches every day on EverQpid.',
                textAlign: stack ? TextAlign.center : TextAlign.left,
                style: getTextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              GradientButton(
                label: 'Join EverQpid',
                onPressed: () => WelcomeActions.openLogin(context),
                width: 220,
              ),
            ],
          );

          if (stack) {
            return Column(
              children: [phone, const SizedBox(height: 36), copy],
            );
          }
          return Row(
            children: [
              Expanded(child: phone),
              const SizedBox(width: 48),
              Expanded(child: copy),
            ],
          );
        },
      ),
    );
  }
}
