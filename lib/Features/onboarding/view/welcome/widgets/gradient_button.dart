import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_shared_widgets.dart';
import 'package:flutter/material.dart';

/// Thin alias so section files share the existing Join CTA chrome.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height = 54,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return WelcomeJoinButton(
      label: label,
      onPressed: onPressed,
      width: width,
      height: height,
      compact: compact,
    );
  }
}
