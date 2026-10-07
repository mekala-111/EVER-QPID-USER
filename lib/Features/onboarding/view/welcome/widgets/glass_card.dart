import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:flutter/material.dart';

class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = 24,
    this.onTap,
    this.enableHover = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool enableHover;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lift = widget.enableHover && _hover;

    return MouseRegion(
      onEnter: widget.enableHover ? (_) => setState(() => _hover = true) : null,
      onExit: widget.enableHover ? (_) => setState(() => _hover = false) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, lift ? -8 : 0, 0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: const Color(0xFF120C22).withValues(alpha: lift ? 0.92 : 0.78),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(
            color: WelcomeTheme.violet.withValues(alpha: lift ? 0.55 : 0.32),
          ),
          boxShadow: [
            BoxShadow(
              color: WelcomeTheme.violet.withValues(alpha: lift ? 0.28 : 0.1),
              blurRadius: lift ? 28 : 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
