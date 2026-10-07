import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/widgets/welcome_brand_mark.dart';
import 'package:flutter/material.dart';

/// Free-floating portrait collage — unique sizes/offsets per Figma.
class WelcomePhotoCollage extends StatelessWidget {
  const WelcomePhotoCollage({
    super.key,
    this.neon = false,
    this.showCenterHeart = false,
    this.showBackdropGlow = false,
  });

  final bool neon;
  final bool showCenterHeart;
  final bool showBackdropGlow;

  static const photos = <String>[
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=500&q=80',
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=500&q=80',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&q=80',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=500&q=80',
    'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=500&q=80',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&q=80',
    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=500&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        if (w <= 0 || h <= 0) return const SizedBox.shrink();

        final tiles = neon ? _webTiles(w, h) : _mobileTiles(w, h);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (showBackdropGlow)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.1, 0.05),
                      radius: 0.85,
                      colors: [
                        WelcomeTheme.violetSoft.withValues(alpha: 0.55),
                        WelcomeTheme.violet.withValues(alpha: 0.22),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
              ),
            for (var i = 0; i < tiles.length; i++)
              Positioned(
                left: tiles[i].left,
                top: tiles[i].top,
                width: tiles[i].width,
                height: tiles[i].height,
                child: Transform.rotate(
                  angle: tiles[i].angle,
                  child: _PortraitTile(
                    url: photos[i % photos.length],
                    neon: neon || tiles[i].glow,
                    radius: tiles[i].radius,
                  ),
                ),
              ),
            if (showCenterHeart)
              const Align(
                alignment: Alignment(0.05, 0.08),
                child: PulsingWelcomeHeart(size: 56),
              ),
          ],
        );
      },
    );
  }

  /// Mobile — organic cloud, white borders, varied sizes.
  static List<_TileSpec> _mobileTiles(double w, double h) => [
        _TileSpec(-w * 0.08, h * 0.02, w * 0.36, h * 0.38, -0.06, radius: 20),
        _TileSpec(w * 0.24, -h * 0.03, w * 0.30, h * 0.34, 0.05, radius: 18),
        _TileSpec(w * 0.52, h * 0.00, w * 0.40, h * 0.42, -0.03, radius: 22),
        _TileSpec(w * 0.78, h * 0.30, w * 0.28, h * 0.34, 0.06, radius: 16),
        _TileSpec(-w * 0.05, h * 0.36, w * 0.34, h * 0.40, 0.04, radius: 20),
        _TileSpec(w * 0.28, h * 0.32, w * 0.38, h * 0.48, -0.05, radius: 24),
        _TileSpec(w * 0.62, h * 0.40, w * 0.34, h * 0.42, 0.03, radius: 20),
        _TileSpec(w * 0.08, h * 0.70, w * 0.30, h * 0.34, -0.02, radius: 18),
      ];

  /// Desktop — free-float composition (not a uniform grid).
  static List<_TileSpec> _webTiles(double w, double h) => [
        _TileSpec(
          w * 0.00, h * 0.02, w * 0.26, h * 0.46, -0.05,
          glow: true, radius: 24,
        ),
        _TileSpec(
          w * 0.28, -h * 0.02, w * 0.22, h * 0.36, 0.04,
          radius: 18,
        ),
        _TileSpec(
          w * 0.52, h * 0.00, w * 0.30, h * 0.48, -0.02,
          glow: true, radius: 26,
        ),
        _TileSpec(
          w * 0.78, h * 0.08, w * 0.24, h * 0.38, 0.05,
          radius: 20,
        ),
        _TileSpec(
          w * -0.02, h * 0.42, w * 0.24, h * 0.40, 0.03,
          radius: 20,
        ),
        _TileSpec(
          w * 0.24, h * 0.38, w * 0.34, h * 0.52, -0.04,
          glow: true, radius: 28,
        ),
        _TileSpec(
          w * 0.58, h * 0.44, w * 0.26, h * 0.42, 0.02,
          radius: 22,
        ),
        _TileSpec(
          w * 0.80, h * 0.52, w * 0.22, h * 0.36, -0.05,
          glow: true, radius: 18,
        ),
      ];
}

class _TileSpec {
  const _TileSpec(
    this.left,
    this.top,
    this.width,
    this.height,
    this.angle, {
    this.glow = false,
    this.radius = 20,
  });

  final double left;
  final double top;
  final double width;
  final double height;
  final double angle;
  final bool glow;
  final double radius;
}

class _PortraitTile extends StatelessWidget {
  const _PortraitTile({
    required this.url,
    this.neon = false,
    this.radius = 20,
  });

  final String url;
  final bool neon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: neon
              ? WelcomeTheme.violetLight.withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.92),
          width: neon ? 2.5 : 2,
        ),
        boxShadow: [
          if (neon)
            BoxShadow(
              color: WelcomeTheme.violet.withValues(alpha: 0.7),
              blurRadius: 28,
              spreadRadius: 1,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ColoredBox(
            color: WelcomeTheme.violet.withValues(alpha: 0.35),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ColoredBox(
              color: WelcomeTheme.bgMid,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: WelcomeTheme.violetLight.withValues(alpha: 0.7),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
