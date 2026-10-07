import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/widgets/welcome_brand_mark.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

/// Intro animation bundle owned by [WelcomeScreen], consumed by both views.
class WelcomeIntroAnimations {
  const WelcomeIntroAnimations({
    required this.logoFade,
    required this.headlineFade,
    required this.headlineSlide,
    required this.ctaFade,
    required this.ctaScale,
  });

  final Animation<double> logoFade;
  final Animation<double> headlineFade;
  final Animation<Offset> headlineSlide;
  final Animation<double> ctaFade;
  final Animation<double> ctaScale;
}

/// Dark premium page chrome with multiple radial violet glows.
class WelcomePageBackground extends StatelessWidget {
  const WelcomePageBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: WelcomeTheme.bgTop,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: WelcomeTheme.pageGradient),
        child: Stack(
          children: [
            // Top-center ambient glow
            Positioned(
              top: -size.height * 0.12,
              left: size.width * 0.15,
              right: size.width * 0.15,
              height: size.height * 0.42,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      WelcomeTheme.violetGlow.withValues(alpha: 0.38),
                      WelcomeTheme.violet.withValues(alpha: 0.12),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            // Right-side glow (behind collage on desktop)
            Positioned(
              top: size.height * 0.12,
              right: -size.width * 0.08,
              width: size.width * 0.55,
              height: size.height * 0.7,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      WelcomeTheme.violetSoft.withValues(alpha: 0.42),
                      WelcomeTheme.violetDeep.withValues(alpha: 0.14),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
            // Bottom glow
            Positioned(
              bottom: -80,
              left: size.width * 0.2,
              right: size.width * 0.2,
              height: 280,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      WelcomeTheme.violet.withValues(alpha: 0.28),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Left soft glow
            Positioned(
              top: size.height * 0.35,
              left: -100,
              width: 280,
              height: 280,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      WelcomeTheme.violetDeep.withValues(alpha: 0.22),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// "Find your partner in life" with violet linear-gradient highlight.
class WelcomeHeadline extends StatelessWidget {
  const WelcomeHeadline({
    super.key,
    this.fontSize,
    this.showHeart = false,
    this.heartInline = false,
    this.maxWidth,
    this.textAlign = TextAlign.left,
  });

  final double? fontSize;
  final bool showHeart;
  final bool heartInline;
  final double? maxWidth;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final size = fontSize ?? (width * 0.11).clamp(36.0, 56.0);

    final base = getTextStyle(
      fontSize: size,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      height: 1.08,
      letterSpacing: -1.2,
    );

    // Measure highlight word so the gradient shader fits exactly.
    final wordPainter = TextPainter(
      text: TextSpan(text: WelcomeTheme.highlightWord, style: base),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final highlight = base.copyWith(
      foreground: Paint()
        ..shader = WelcomeTheme.partnerGradient.createShader(
          Rect.fromLTWH(0, 0, wordPainter.width, wordPainter.height),
        ),
    );

    const full = WelcomeTheme.headline;
    const word = WelcomeTheme.highlightWord;
    final idx = full.indexOf(word);
    final before = idx >= 0 ? full.substring(0, idx) : full;
    final after = idx >= 0 ? full.substring(idx + word.length) : '';

    final rich = Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(text: before),
          TextSpan(text: word, style: highlight),
          TextSpan(text: after),
        ],
      ),
      textAlign: textAlign,
    );

    final centered = textAlign == TextAlign.center;

    final Widget headline = showHeart && heartInline
        ? Wrap(
            alignment: centered ? WrapAlignment.center : WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              rich,
              PulsingWelcomeHeart(size: size * 0.42),
            ],
          )
        : rich;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Column(
        crossAxisAlignment:
            centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          headline,
          if (showHeart && !heartInline) ...[
            const SizedBox(height: 12),
            const PulsingWelcomeHeart(size: 40),
          ],
        ],
      ),
    );
  }
}

class WelcomeSubtitle extends StatelessWidget {
  const WelcomeSubtitle({
    super.key,
    this.fontSize = 15,
    this.maxWidth,
    this.textAlign = TextAlign.left,
  });

  final double fontSize;
  final double? maxWidth;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: Text(
        WelcomeTheme.subtitle,
        textAlign: textAlign,
        style: getTextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          color: Colors.white.withValues(alpha: 0.78),
          height: 1.55,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class WelcomeJoinButton extends StatefulWidget {
  const WelcomeJoinButton({
    super.key,
    required this.onPressed,
    this.label = 'Join now',
    this.width,
    this.height = WelcomeTheme.ctaHeight,
    this.compact = false,
    this.fullWidth = false,
  });

  final VoidCallback onPressed;
  final String label;
  final double? width;
  final double height;
  final bool compact;
  final bool fullWidth;

  @override
  State<WelcomeJoinButton> createState() => _WelcomeJoinButtonState();
}

class _WelcomeJoinButtonState extends State<WelcomeJoinButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.compact ? 14.0 : WelcomeTheme.ctaRadius;
    final w = widget.fullWidth
        ? double.infinity
        : (widget.width ?? (widget.compact ? null : WelcomeTheme.ctaWidth));

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hover ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: w,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: WelcomeTheme.ctaGradient,
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: _hover ? 0.75 : 0.5),
                blurRadius: _hover ? 32 : 22,
                spreadRadius: _hover ? 1 : 0,
                offset: Offset(0, _hover ? 12 : 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(radius),
              child: Center(
                child: Text(
                  widget.label,
                  style: getTextStyle(
                    fontSize: widget.compact ? 14 : 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeOutlineButton extends StatefulWidget {
  const WelcomeOutlineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = WelcomeTheme.ctaWidth,
    this.height = WelcomeTheme.ctaHeight,
  });

  final String label;
  final VoidCallback onPressed;
  final double width;
  final double height;

  @override
  State<WelcomeOutlineButton> createState() => _WelcomeOutlineButtonState();
}

class _WelcomeOutlineButtonState extends State<WelcomeOutlineButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _hover ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: OutlinedButton(
            onPressed: widget.onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: _hover
                  ? WelcomeTheme.violet.withValues(alpha: 0.12)
                  : Colors.transparent,
              side: BorderSide(
                color: Colors.white.withValues(alpha: _hover ? 0.95 : 0.7),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(WelcomeTheme.ctaRadius),
              ),
            ),
            child: Text(
              widget.label,
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WelcomeFeatureRow extends StatelessWidget {
  const WelcomeFeatureRow({super.key, this.features});

  /// Defaults to [WelcomeTheme.features] when null.
  final List<WelcomeFeature>? features;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tight = constraints.maxWidth < 640;
        final items = (features ?? WelcomeTheme.features)
            .map((f) => _FeatureItem(feature: f, compact: tight))
            .toList();

        if (tight) {
          return Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const SizedBox(height: 22),
                items[i],
              ],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 28),
              Expanded(child: items[i]),
            ],
          ],
        );
      },
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.feature, required this.compact});

  final WelcomeFeature feature;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 44.0 : 52.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: WelcomeTheme.violet.withValues(alpha: 0.2),
            border: Border.all(
              color: WelcomeTheme.violetLight.withValues(alpha: 0.55),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.35),
                blurRadius: 16,
              ),
            ],
          ),
          child: Icon(
            feature.icon,
            color: WelcomeTheme.violetLight,
            size: compact ? 22 : 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                feature.title,
                style: getTextStyle(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                feature.subtitle,
                style: getTextStyle(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.68),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
