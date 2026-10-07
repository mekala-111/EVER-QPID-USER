import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_actions.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/gradient_button.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/section_heading.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

class FinalCtaSection extends StatelessWidget {
  const FinalCtaSection({super.key});

  @override
  Widget build(BuildContext context) {
    return LandingSectionPad(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [
              WelcomeTheme.violet.withValues(alpha: 0.35),
              WelcomeTheme.violetDeep.withValues(alpha: 0.18),
            ],
          ),
          border: Border.all(
            color: WelcomeTheme.violet.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: WelcomeTheme.violet.withValues(alpha: 0.28),
              blurRadius: 48,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
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
                  const TextSpan(text: 'Ready to find\n'),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: ShaderMask(
                      blendMode: BlendMode.srcIn,
                      shaderCallback: (b) =>
                          WelcomeTheme.partnerGradient.createShader(b),
                      child: Text(
                        'your EverQpid?',
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
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Text(
                'Your next meaningful connection could be closer than you think.',
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: 'Join now',
              onPressed: () => WelcomeActions.openLogin(context),
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
