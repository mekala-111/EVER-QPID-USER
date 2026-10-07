import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum SwipeFx { none, love, pass }

/// Full-screen Discover swipe FX. Presentation only — never handles pointers.
class SwipeEffectOverlay extends StatefulWidget {
  const SwipeEffectOverlay({
    super.key,
    required this.progress,
    required this.fx,
    required this.completing,
    this.celebrateT = 0,
  });

  /// 0–1 drag commitment (or 1 while celebrating).
  final double progress;
  final SwipeFx fx;
  final bool completing;

  /// 0–1 celebrate timeline driven by the host (pulse + fade).
  final double celebrateT;

  static const loveAsset = 'assets/images/love_animation.png';
  static const passAsset = 'assets/images/left bk.png';

  /// FX begins ~15% into a swipe.
  static const showAfter = 0.15;

  static const loveCelebrateMs = 850;
  static const passCelebrateMs = 750;

  static Future<void> precache(BuildContext context) {
    return Future.wait([
      precacheImage(const AssetImage(loveAsset), context),
      precacheImage(const AssetImage(passAsset), context),
    ]);
  }

  /// Map horizontal drag to 0–1 using ~28% of width (min 120).
  static double progressFromDx(double dx, double width) {
    final threshold = math.max(120.0, width * 0.28);
    return (dx.abs() / threshold).clamp(0.0, 1.0);
  }

  static SwipeFx fxFromDx(double dx) {
    if (dx > 8) return SwipeFx.love;
    if (dx < -8) return SwipeFx.pass;
    return SwipeFx.none;
  }

  /// Keep profile readable: 100% → ~75%.
  static double swipeProfileOpacity(double progress) =>
      (1.0 - progress * 0.25).clamp(0.75, 1.0);

  /// Heart focus size from viewport shortest side.
  static double heartExtent(Size size) {
    final s = size.shortestSide;
    if (s >= 900) return s.clamp(260.0, 380.0);
    if (s >= 600) return (s * 0.38).clamp(200.0, 300.0);
    return (s * 0.48).clamp(160.0, 240.0);
  }

  /// Celebrate scale: 0.65 → 1.0 → 1.18 → 1.0 then fade uses opacity.
  static double celebrateScale(double t) {
    double curve(double x, Curve c) =>
        c.transform(x.clamp(0.0, 1.0));
    if (t <= 0.35) {
      return 0.65 + 0.35 * curve(t / 0.35, Curves.easeOutCubic);
    }
    if (t <= 0.55) {
      return 1.0 + 0.18 * curve((t - 0.35) / 0.20, Curves.easeOut);
    }
    if (t <= 0.75) {
      return 1.18 - 0.18 * curve((t - 0.55) / 0.20, Curves.easeInOut);
    }
    return 1.0;
  }

  static double celebrateFade(double t) {
    if (t < 0.72) return 1.0;
    return (1.0 - (t - 0.72) / 0.28).clamp(0.0, 1.0);
  }

  @override
  State<SwipeEffectOverlay> createState() => _SwipeEffectOverlayState();
}

class _SwipeEffectOverlayState extends State<SwipeEffectOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant SwipeEffectOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final should =
        widget.fx != SwipeFx.none &&
        (widget.progress >= 0.9 || widget.completing);
    if (should) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else if (_pulse.isAnimating) {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fx == SwipeFx.none) return const SizedBox.shrink();

    final p = widget.completing
        ? 1.0
        : widget.progress.clamp(0.0, 1.0);
    if (p < SwipeEffectOverlay.showAfter && !widget.completing) {
      return const SizedBox.shrink();
    }

    final love = widget.fx == SwipeFx.love;
    final t = widget.completing ? widget.celebrateT.clamp(0.0, 1.0) : 0.0;
    final fade = widget.completing
        ? SwipeEffectOverlay.celebrateFade(t)
        : 1.0;

    // Ramp after 15%.
    final ramp = widget.completing
        ? 1.0
        : ((p - SwipeEffectOverlay.showAfter) /
                (1.0 - SwipeEffectOverlay.showAfter))
            .clamp(0.0, 1.0);

    final glowAlpha = love
        ? (0.06 + ramp * 0.16) * fade
        : (0.08 + ramp * 0.18) * fade;

    // Heart asset: appear ~30%, grow through 70%+.
    final heartAppear = widget.completing
        ? 1.0
        : ((p - 0.30) / 0.55).clamp(0.0, 1.0);
    final assetOpacity = (heartAppear * (0.55 + ramp * 0.45) * fade)
        .clamp(0.0, 0.92);

    final dragScale = 0.65 + heartAppear * 0.35;
    final scale = widget.completing
        ? SwipeEffectOverlay.celebrateScale(t)
        : dragScale;

    final pulseBoost = widget.progress >= 0.9 || widget.completing
        ? 1.0 + 0.04 * _pulse.value
        : 1.0;

    // Pass shake near commit / celebrate.
    final shakeAmt = (!love && (p >= 0.9 || widget.completing))
        ? math.sin((widget.completing ? t : p) * 42) * (3.5 + ramp * 2)
        : 0.0;

    final flash = widget.completing && love && t > 0.32 && t < 0.55
        ? (1.0 - ((t - 0.32) / 0.23).abs() * 2).clamp(0.0, 1.0) * 0.18
        : 0.0;

    final asset =
        love ? SwipeEffectOverlay.loveAsset : SwipeEffectOverlay.passAsset;
    final glowColor = love
        ? const Color(0xFFFF4FA3)
        : const Color(0xFFA855F7);

    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final size = Size(constraints.maxWidth, constraints.maxHeight);
            final heart = SwipeEffectOverlay.heartExtent(size);

            return Transform.translate(
              offset: Offset(shakeAmt, 0),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Soft romantic / dark glow — never opaque.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 0.95,
                        colors: [
                          glowColor.withValues(alpha: glowAlpha),
                          glowColor.withValues(
                            alpha: glowAlpha * (love ? 0.45 : 0.55),
                          ),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),

                  // Full-bleed asset; screen blend drops solid black plate.
                  if (assetOpacity > 0.02)
                    Opacity(
                      opacity: assetOpacity,
                      child: Transform.scale(
                        scale: scale * pulseBoost,
                        child: _BlendLayer(
                          blendMode: BlendMode.screen,
                          child: Image.asset(
                            asset,
                            fit: BoxFit.cover,
                            width: size.width,
                            height: size.height,
                            filterQuality: FilterQuality.medium,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),

                  // Centered heart emphasis (responsive), same blend.
                  if (heartAppear > 0.02)
                    Center(
                      child: Opacity(
                        opacity: (assetOpacity * 0.85).clamp(0.0, 0.9),
                        child: Transform.scale(
                          scale: scale * pulseBoost,
                          child: SizedBox(
                            width: heart * (love ? 1.35 : 1.45),
                            height: heart * (love ? 1.35 : 1.45),
                            child: _BlendLayer(
                              blendMode: BlendMode.plus,
                              child: Image.asset(
                                asset,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.medium,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Extra sparkles / rays (works even if PNG is replaced later).
                  if (ramp > 0.05)
                    CustomPaint(
                      painter: _SwipeSparklePainter(
                        progress: ramp,
                        love: love,
                        pulse: _pulse.value,
                        celebrateT: t,
                        opacity: fade,
                      ),
                    ),

                  if (flash > 0)
                    ColoredBox(
                      color: Colors.white.withValues(alpha: flash),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Composites [child] onto the backdrop with [blendMode] (screen/plus/lighten).
class _BlendLayer extends SingleChildRenderObjectWidget {
  const _BlendLayer({required this.blendMode, super.child});

  final BlendMode blendMode;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderBlendLayer(blendMode);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderBlendLayer renderObject,
  ) {
    renderObject.blendMode = blendMode;
  }
}

class _RenderBlendLayer extends RenderProxyBox {
  _RenderBlendLayer(this._blendMode);

  BlendMode _blendMode;
  BlendMode get blendMode => _blendMode;
  set blendMode(BlendMode value) {
    if (_blendMode == value) return;
    _blendMode = value;
    markNeedsPaint();
  }

  @override
  bool get alwaysNeedsCompositing => child != null;

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final bounds = offset & size;
    context.canvas.saveLayer(bounds, Paint()..blendMode = _blendMode);
    context.paintChild(child!, offset);
    context.canvas.restore();
  }
}

class _SwipeSparklePainter extends CustomPainter {
  _SwipeSparklePainter({
    required this.progress,
    required this.love,
    required this.pulse,
    required this.celebrateT,
    required this.opacity,
  });

  final double progress;
  final bool love;
  final double pulse;
  final double celebrateT;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final base = love
        ? const Color(0xFFFF6BB5)
        : const Color(0xFFC084FC);
    final count = love ? 28 : 22;
    final paint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(love ? 42 : 99);

    // Soft radial rays.
    final rayPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = base.withValues(alpha: 0.12 * progress * opacity);
    final rayLen = size.shortestSide * (0.28 + progress * 0.22);
    for (var i = 0; i < 12; i++) {
      final a = (i / 12) * math.pi * 2 + celebrateT * 0.4;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + math.cos(a) * rayLen, cy + math.sin(a) * rayLen),
        rayPaint,
      );
    }

    for (var i = 0; i < count; i++) {
      final ang = rng.nextDouble() * math.pi * 2;
      final dist = size.shortestSide *
          (0.12 + rng.nextDouble() * 0.42) *
          (0.7 + progress * 0.5);
      final drift = celebrateT * (love ? 18 : 28) * (0.5 + rng.nextDouble());
      final x = cx + math.cos(ang) * (dist + drift);
      final y = cy +
          math.sin(ang) * (dist + drift * (love ? 0.6 : 1.1)) -
          (love ? celebrateT * 12 * rng.nextDouble() : 0);
      final r = (1.2 + rng.nextDouble() * 2.8) * (0.7 + pulse * 0.3);
      paint.color = base.withValues(
        alpha: (0.25 + rng.nextDouble() * 0.45) * progress * opacity,
      );
      canvas.drawCircle(Offset(x, y), r, paint);

      // Tiny floating hearts (approx as diamonds).
      if (i % 4 == 0) {
        final hs = 3.0 + rng.nextDouble() * 4;
        final path = Path()
          ..moveTo(x, y - hs * 0.35)
          ..cubicTo(
            x + hs,
            y - hs,
            x + hs * 1.1,
            y + hs * 0.2,
            x,
            y + hs * 0.85,
          )
          ..cubicTo(
            x - hs * 1.1,
            y + hs * 0.2,
            x - hs,
            y - hs,
            x,
            y - hs * 0.35,
          );
        paint.color = base.withValues(
          alpha: 0.35 * progress * opacity,
        );
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SwipeSparklePainter old) =>
      old.progress != progress ||
      old.love != love ||
      old.pulse != pulse ||
      old.celebrateT != celebrateT ||
      old.opacity != opacity;
}

/// Host helper: runs celebrate timeline then invokes [action] exactly once.
mixin DiscoverSwipeFxHost<T extends StatefulWidget>
    on TickerProviderStateMixin<T> {
  final ValueNotifier<double> swipeProgress = ValueNotifier(0);
  final ValueNotifier<SwipeFx> activeFx = ValueNotifier(SwipeFx.none);
  bool completingSwipe = false;
  final ValueNotifier<double> celebrateT = ValueNotifier(0);

  AnimationController? _celebrate;

  bool get swipeFxBusy => completingSwipe;

  void initSwipeFx() {
    _celebrate = AnimationController(vsync: this);
    _celebrate!.addListener(() {
      celebrateT.value = _celebrate!.value;
    });
  }

  void disposeSwipeFx() {
    _celebrate?.dispose();
    swipeProgress.dispose();
    activeFx.dispose();
    celebrateT.dispose();
  }

  void updateDragFx(double dx, double width) {
    if (completingSwipe) return;
    final p = SwipeEffectOverlay.progressFromDx(dx, width);
    final fx = SwipeEffectOverlay.fxFromDx(dx);
    if (swipeProgress.value != p) swipeProgress.value = p;
    if (activeFx.value != fx) activeFx.value = fx;
  }

  void clearDragFx() {
    if (completingSwipe) return;
    swipeProgress.value = 0;
    activeFx.value = SwipeFx.none;
  }

  /// Plays FX then runs [action] once. No-op if already completing.
  Future<void> runSwipeFx({
    required SwipeFx fx,
    required VoidCallback action,
  }) async {
    if (completingSwipe || fx == SwipeFx.none) return;
    completingSwipe = true;
    activeFx.value = fx;
    swipeProgress.value = 1;
    celebrateT.value = 0;

    final ms = fx == SwipeFx.love
        ? SwipeEffectOverlay.loveCelebrateMs
        : SwipeEffectOverlay.passCelebrateMs;
    _celebrate!.duration = Duration(milliseconds: ms);

    try {
      if (MediaQuery.disableAnimationsOf(context)) {
        celebrateT.value = 1;
      } else {
        await _celebrate!.forward(from: 0);
      }
      if (!mounted) return;
      action();
    } catch (_) {
      if (mounted) action();
      rethrow;
    } finally {
      if (mounted) {
        completingSwipe = false;
        swipeProgress.value = 0;
        activeFx.value = SwipeFx.none;
        celebrateT.value = 0;
        _celebrate!.reset();
      }
    }
  }

  Widget buildSwipeFxOverlay() {
    return ListenableBuilder(
      listenable: Listenable.merge([
        swipeProgress,
        activeFx,
        celebrateT,
      ]),
      builder: (context, _) {
        return SwipeEffectOverlay(
          progress: swipeProgress.value,
          fx: activeFx.value,
          completing: completingSwipe,
          celebrateT: celebrateT.value,
        );
      },
    );
  }
}
