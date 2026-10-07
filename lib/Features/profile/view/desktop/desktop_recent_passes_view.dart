import 'dart:ui';

import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/model/passed_profile_model.dart';
import 'package:everqpidapp/Features/profile/model/recent_pass_model.dart';
import 'package:everqpidapp/Features/profile/view_model/recent_pass_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop/tablet Recent Passes — presentation only; same [RecentPassViewModel].
class DesktopRecentPassesView extends StatefulWidget {
  const DesktopRecentPassesView({
    super.key,
    required this.onShowSubscribe,
  });

  final VoidCallback onShowSubscribe;

  @override
  State<DesktopRecentPassesView> createState() =>
      _DesktopRecentPassesViewState();
}

class _DesktopRecentPassesViewState extends State<DesktopRecentPassesView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _pulse.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _goDiscover() {
    Navigator.of(context).popUntil((r) => r.isFirst);
    MainScreenBridge.navigateToTab(0);
  }

  void _openProfile(RecentPassUser user) {
    final vm = context.read<RecentPassViewModel>();
    if (!vm.isSubscribed) {
      widget.onShowSubscribe();
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileDetailScreen(
          profileTitle: 'passed',
          profile: user,
        ),
      ),
    );
  }

  int _gridCols(double width) {
    if (width >= 1200) return 4;
    if (width >= 1000) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecentPassViewModel>();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return ColoredBox(
      color: const Color(0xFF05030D),
      child: Stack(
        children: [
          IgnorePointer(
            child: _AmbientDecor(pulse: reduceMotion ? null : _pulse),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1140),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 8, 40, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _BackLink(onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          'Recent Passes',
                          style: getTextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 28,
                          color: WelcomeTheme.violetLight.withValues(alpha: 0.9),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Changed your mind? Take another look at recent passes.',
                      style: getTextStyle(
                        fontSize: 15,
                        color: const Color(0xFFB8B3C7),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Expanded(
                      child: vm.isLoading && vm.passedUsers.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: WelcomeTheme.violetLight,
                              ),
                            )
                          : vm.passedUsers.isEmpty
                              ? _EmptyState(
                                  pulse: reduceMotion ? null : _pulse,
                                  onDiscover: _goDiscover,
                                )
                              : Stack(
                                  children: [
                                    _PassesGrid(
                                      users: vm.passedUsers,
                                      shouldBlur: !vm.isSubscribed,
                                      cols: _gridCols(
                                        MediaQuery.sizeOf(context).width,
                                      ),
                                      reduceMotion: reduceMotion,
                                      onTap: _openProfile,
                                      onLoadMore: vm.hasNext
                                          ? () => vm.loadRecentPasses()
                                          : null,
                                      loadingMore: vm.isLoading,
                                    ),
                                    if (!vm.isSubscribed)
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 16,
                                        child: Center(
                                          child: _SubscribeChip(
                                            onTap: widget.onShowSubscribe,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── chrome ──────────────────────────────────────────────────────────────────

class _BackLink extends StatelessWidget {
  const _BackLink({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.arrow_back_rounded, size: 18),
        label: const Text('Back'),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFB8B3C7),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }
}

class _SubscribeChip extends StatelessWidget {
  const _SubscribeChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: [WelcomeTheme.violetDeep, WelcomeTheme.violetSoft],
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            child: Text(
              'Subscribe',
              style: getTextStyle(
                fontSize: 15,
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

// ─── empty ───────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.pulse, required this.onDiscover});
  final Animation<double>? pulse;
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 520, maxWidth: 900),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF120A1F).withValues(alpha: 0.55),
          border: Border.all(
            color: const Color(0xFFA855F7).withValues(alpha: 0.30),
          ),
          boxShadow: [
            BoxShadow(
              color: WelcomeTheme.violet.withValues(alpha: 0.12),
              blurRadius: 40,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _BinocularsVisual(pulse: pulse),
            const SizedBox(height: 28),
            Text(
              'No passed users yet!',
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven’t passed on anyone yet.\nExplore more people and start connecting.',
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 14,
                color: const Color(0xFFB8B3C7),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            _DiscoverButton(onPressed: onDiscover),
          ],
        ),
      ),
    );
  }
}

class _BinocularsVisual extends StatelessWidget {
  const _BinocularsVisual({this.pulse});
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    Widget core(double t) {
      return SizedBox(
        width: 220,
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 130 + t * 14,
              height: 90 + t * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: WelcomeTheme.violet
                        .withValues(alpha: 0.32 + t * 0.18),
                    blurRadius: 42 + t * 16,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -t * 5),
              child: Image.asset(
                Images.binoculars,
                width: 160,
                height: 160,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        ),
      );
    }

    if (pulse == null) return core(0.5);
    return AnimatedBuilder(
      animation: pulse!,
      builder: (_, __) => core(pulse!.value),
    );
  }
}

class _DiscoverButton extends StatelessWidget {
  const _DiscoverButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 230,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF6D28D9), Color(0xFF9B4DFF), Color(0xFFA855F7)],
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Discover People',
                style: getTextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── grid ────────────────────────────────────────────────────────────────────

class _PassesGrid extends StatelessWidget {
  const _PassesGrid({
    required this.users,
    required this.shouldBlur,
    required this.cols,
    required this.reduceMotion,
    required this.onTap,
    this.onLoadMore,
    this.loadingMore = false,
  });

  final List<RecentPassUser> users;
  final bool shouldBlur;
  final int cols;
  final bool reduceMotion;
  final ValueChanged<RecentPassUser> onTap;
  final VoidCallback? onLoadMore;
  final bool loadingMore;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      cacheExtent: 400,
      slivers: [
        SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final user = users[index];
              final card = _PassCard(
                profile: PassedProfile(
                  name: user.fullName,
                  age: user.age,
                  education: user.education ?? user.locationString ?? '',
                  imageUrl: user.profileImageUrl,
                  isVerified: user.isVerified,
                ),
                location: user.locationString,
                shouldBlur: shouldBlur,
                onTap: () => onTap(user),
              );
              if (reduceMotion) return card;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 280 + (index % 6) * 40),
                curve: Curves.easeOutCubic,
                builder: (context, t, child) {
                  return Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, (1 - t) * 12),
                      child: child,
                    ),
                  );
                },
                child: card,
              );
            },
            childCount: users.length,
          ),
        ),
        if (onLoadMore != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 72),
              child: Center(
                child: TextButton.icon(
                  onPressed: loadingMore ? null : onLoadMore,
                  icon: loadingMore
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: WelcomeTheme.violetLight,
                          ),
                        )
                      : const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  label: const Text('View More'),
                  style: TextButton.styleFrom(
                    foregroundColor: WelcomeTheme.violetLight,
                  ),
                ),
              ),
            ),
          )
        else
          const SliverToBoxAdapter(child: SizedBox(height: 72)),
      ],
    );
  }
}

class _PassCard extends StatefulWidget {
  const _PassCard({
    required this.profile,
    required this.shouldBlur,
    required this.onTap,
    this.location,
  });

  final PassedProfile profile;
  final bool shouldBlur;
  final VoidCallback onTap;
  final String? location;

  @override
  State<_PassCard> createState() => _PassCardState();
}

class _PassCardState extends State<_PassCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final lift = !reduceMotion && _hover ? -3.0 : 0.0;
    final borderAlpha = _hover ? 0.45 : 0.22;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, lift, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: WelcomeTheme.violet.withValues(alpha: borderAlpha),
          ),
          boxShadow: [
            BoxShadow(
              color: WelcomeTheme.violet.withValues(alpha: _hover ? 0.28 : 0.08),
              blurRadius: _hover ? 22 : 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppNetworkImage(
                    url: widget.profile.imageUrl,
                    memCacheWidth: 600,
                  ),
                  if (widget.shouldBlur)
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.12),
                      ),
                    ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC05030D)],
                        stops: [0.45, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${widget.profile.name}, ${widget.profile.age}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: getTextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (widget.profile.isVerified)
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF60A5FA),
                                size: 18,
                              ),
                          ],
                        ),
                        if ((widget.location ?? widget.profile.education)
                            .trim()
                            .isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                widget.location != null &&
                                        widget.location!.trim().isNotEmpty
                                    ? Icons.location_on_outlined
                                    : Icons.school_outlined,
                                color: Colors.white70,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  (widget.location?.trim().isNotEmpty == true
                                          ? widget.location!
                                          : widget.profile.education)
                                      .trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: getTextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── ambient ─────────────────────────────────────────────────────────────────

class _AmbientDecor extends StatelessWidget {
  const _AmbientDecor({this.pulse});
  final Animation<double>? pulse;

  @override
  Widget build(BuildContext context) {
    Widget layer(double t) {
      return CustomPaint(
        painter: _AmbientPainter(t: t),
        child: const SizedBox.expand(),
      );
    }

    if (pulse == null) return layer(0.4);
    return AnimatedBuilder(
      animation: pulse!,
      builder: (_, __) => layer(pulse!.value),
    );
  }
}

class _AmbientPainter extends CustomPainter {
  _AmbientPainter({required this.t});
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..color = const Color(0xFF9B4DFF).withValues(alpha: 0.08 + t * 0.04);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.12), 160, glow);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.75), 120, glow);

    final line = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final path = Path()
      ..moveTo(size.width * 0.7, 0)
      ..quadraticBezierTo(
        size.width * 0.95,
        size.height * 0.25,
        size.width,
        size.height * 0.45,
      );
    canvas.drawPath(path, line);

    final heart = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    _drawHeart(canvas, Offset(40, size.height * 0.2 + t * 8), 10, heart);
    _drawHeart(canvas, Offset(size.width - 56, size.height * 0.55 - t * 6), 8, heart);

    final star = Paint()..color = Colors.white.withValues(alpha: 0.18 + t * 0.1);
    for (final o in [
      Offset(size.width * 0.22, 48),
      Offset(size.width * 0.55, size.height * 0.18),
      Offset(size.width * 0.92, size.height * 0.7),
    ]) {
      canvas.drawCircle(o, 1.4, star);
    }
  }

  void _drawHeart(Canvas canvas, Offset c, double s, Paint paint) {
    final path = Path()
      ..moveTo(c.dx, c.dy + s * 0.3)
      ..cubicTo(
        c.dx - s,
        c.dy - s * 0.4,
        c.dx - s * 1.1,
        c.dy + s * 0.6,
        c.dx,
        c.dy + s * 1.2,
      )
      ..cubicTo(
        c.dx + s * 1.1,
        c.dy + s * 0.6,
        c.dx + s,
        c.dy - s * 0.4,
        c.dx,
        c.dy + s * 0.3,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AmbientPainter old) => old.t != t;
}
