import 'dart:ui';

import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/landing_background.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';

/// Romantic full-page shell + centered glass card for web registration steps.
class WebOnboardingShell extends StatelessWidget {
  const WebOnboardingShell({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.child,
    this.onBack,
    this.footer,
    this.maxCardWidth = 560,
  });

  final int currentStep;
  final int totalSteps;
  final Widget child;
  final VoidCallback? onBack;
  final Widget? footer;
  final double maxCardWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 1100;
    final cardW =
        width >= 768 ? maxCardWidth : (width * 0.9).clamp(300.0, maxCardWidth);

    return Scaffold(
      backgroundColor: WelcomeTheme.pageBg,
      body: Stack(
        children: [
          const LandingBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 48 : 20,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(maxWidth: wide ? 1100 : cardW + 40),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (wide) ...[
                        Expanded(child: _LeftTagline()),
                        const SizedBox(width: 48),
                      ],
                      SizedBox(
                        width: cardW,
                        child: _OnboardingCard(
                          currentStep: currentStep,
                          totalSteps: totalSteps,
                          onBack: onBack,
                          footer: footer,
                          child: child,
                        ),
                      ),
                      if (wide) const Spacer(),
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

class _LeftTagline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Find someone\nwho feels right.',
            style: getTextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Icon(Icons.favorite_rounded,
              color: WelcomeTheme.violetSoft.withValues(alpha: 0.9), size: 28),
          const SizedBox(height: 20),
          Text(
            'Meaningful connections\nstart with being yourself.',
            style: getTextStyle(
              fontSize: 16,
              height: 1.5,
              color: const Color(0xFFAAA3B8),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  const _OnboardingCard({
    required this.currentStep,
    required this.totalSteps,
    required this.child,
    this.onBack,
    this.footer,
  });

  final int currentStep;
  final int totalSteps;
  final Widget child;
  final VoidCallback? onBack;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final progress =
        totalSteps <= 0 ? 0.0 : (currentStep / totalSteps).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(40, 36, 40, 32),
          decoration: BoxDecoration(
            color: const Color(0xFF0E061F).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFFA855F7).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 40,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.18),
                blurRadius: 32,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (onBack != null)
                    IconButton(
                      tooltip: 'Back',
                      onPressed: onBack,
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Color(0xFFD4CEDD)),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        Images.everqpidWhite,
                        height: 36,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Text(
                          'EverQpid',
                          style: getTextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Step $currentStep of $totalSteps',
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFAAA3B8),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: SizedBox(
                  height: 4,
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withValues(alpha: 0.10)),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              child,
              if (footer != null) ...[
                const SizedBox(height: 28),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shared dark field decoration for web onboarding inputs.
InputDecoration webOnboardingFieldDecoration({
  required String hint,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color c, {double w = 1}) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c, width: w),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: getTextStyle(fontSize: 15, color: const Color(0xFF777181)),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.055),
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    enabledBorder: border(Colors.white.withValues(alpha: 0.10)),
    focusedBorder: border(const Color(0xFFA855F7), w: 1.5),
    border: border(Colors.white.withValues(alpha: 0.10)),
  );
}

class WebOnboardingContinueButton extends StatefulWidget {
  const WebOnboardingContinueButton({
    super.key,
    required this.enabled,
    required this.loading,
    required this.label,
    required this.onPressed,
  });

  final bool enabled;
  final bool loading;
  final String label;
  final VoidCallback onPressed;

  @override
  State<WebOnboardingContinueButton> createState() =>
      _WebOnboardingContinueButtonState();
}

class _WebOnboardingContinueButtonState
    extends State<WebOnboardingContinueButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled || widget.loading;
    return MouseRegion(
      onEnter: (_) {
        if (widget.enabled) setState(() => _hover = true);
      },
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.enabled && !widget.loading ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: active
                ? LinearGradient(
                    colors: _hover && !widget.loading
                        ? const [Color(0xFFB65CFF), Color(0xFF8B5CF6)]
                        : const [Color(0xFFA855F7), Color(0xFF7C3AED)],
                  )
                : null,
            color:
                active ? null : const Color(0xFFA855F7).withValues(alpha: 0.20),
            boxShadow: active && _hover
                ? [
                    BoxShadow(
                      color: WelcomeTheme.violet.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: widget.loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Saving...',
                      style: getTextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  widget.label,
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: widget.enabled
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.45),
                  ),
                ),
        ),
      ),
    );
  }
}

class WebOnboardingPrivacyNote extends StatelessWidget {
  const WebOnboardingPrivacyNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.shield_outlined,
          size: 16,
          color: WelcomeTheme.violetSoft.withValues(alpha: 0.85),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Your information is used to personalize your EverQpid experience.',
            style: getTextStyle(
              fontSize: 12,
              height: 1.4,
              color: const Color(0xFF777181),
            ),
          ),
        ),
      ],
    );
  }
}
