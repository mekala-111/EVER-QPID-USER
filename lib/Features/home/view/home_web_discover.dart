import 'dart:ui';

import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/home/model/discovery_profile_model.dart';
import 'package:everqpidapp/Features/home/view_model/home_view_model.dart';
import 'package:everqpidapp/Features/home/view/swipe_feedback_overlay.dart';
import 'package:everqpidapp/Features/profileactions/view/profile_action_bottom_sheet.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_bottom_sheet.dart';
import 'package:everqpidapp/Features/superlikes/view/subscription_required_dialog.dart';
import 'package:everqpidapp/Features/superlikes/view_model/super_likes_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const _violet = Color(0xFFA855F7);
const _violetDeep = Color(0xFF7C3AED);
const _violetSoft = Color(0xFFC084FC);
const _muted = Color(0xFFB9AFC8);
const _border = Color(0x47A855F7); // ~0.28 alpha
const _surfaceRight = Color(0xF50B0518);

/// Desktop Discover card — dark neon split layout over shell background.
class WebDiscoverCard extends StatefulWidget {
  const WebDiscoverCard({
    super.key,
    required this.profile,
    required this.onLike,
    required this.onPass,
  });

  final DiscoveryProfile profile;
  final VoidCallback onLike;
  final VoidCallback onPass;

  @override
  State<WebDiscoverCard> createState() => _WebDiscoverCardState();
}

class _WebDiscoverCardState extends State<WebDiscoverCard>
    with TickerProviderStateMixin, DiscoverSwipeFxHost {
  int _photoIndex = 0;
  late final AnimationController _enter;
  final ValueNotifier<Offset> _drag = ValueNotifier(Offset.zero);

  List<String> get _photos {
    final urls = <String>[];
    void add(String? url) {
      if (url == null || url.isEmpty || urls.contains(url)) return;
      urls.add(url);
    }

    add(widget.profile.imageUrl);
    for (final url in widget.profile.additionalImages) {
      add(url);
    }
    return urls;
  }

  String get _photoUrl {
    if (_photos.isEmpty) return widget.profile.imageUrl;
    return _photos[_photoIndex.clamp(0, _photos.length - 1)];
  }

  @override
  void initState() {
    super.initState();
    initSwipeFx();
    _enter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SwipeEffectOverlay.precache(context);
      if (MediaQuery.disableAnimationsOf(context)) {
        _enter.value = 1;
      } else {
        _enter.forward();
      }
    });
  }

  @override
  void dispose() {
    disposeSwipeFx();
    _drag.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WebDiscoverCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id) {
      _photoIndex = 0;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _enter
          ..value = 0
          ..forward();
      }
    }
  }

  String _heightLabel(int cm) {
    if (cm <= 0) return '';
    final totalIn = (cm / 2.54).round();
    return "${totalIn ~/ 12}'${totalIn % 12}\"";
  }

  Future<void> _superLike() async {
    if (swipeFxBusy) return;
    final userId = LoggedInUser.id;
    if (userId == null) return;
    final vm = context.read<SuperLikesViewModel>();
    final response = await vm.sendSuperLike(
      userId: userId,
      toUserId: widget.profile.id,
    );
    if (!mounted) return;
    if (response.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Super like sent!')),
      );
      await runSwipeFx(fx: SwipeFx.love, action: widget.onLike);
    } else if (response.needsSubscription) {
      showSubscriptionRequiredDialog(
        context: context,
        message: response.message,
        onSubscribe: () {
          showSubscriptionBottomSheet(
            context: context,
            title: 'Subscription',
            message: response.message,
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _onLike() async {
    if (swipeFxBusy) return;
    await runSwipeFx(fx: SwipeFx.love, action: widget.onLike);
  }

  Future<void> _onPass() async {
    if (swipeFxBusy) return;
    await runSwipeFx(fx: SwipeFx.pass, action: widget.onPass);
  }

  void _onPanStart(DragStartDetails _) {
    if (swipeFxBusy) return;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (swipeFxBusy) return;
    _drag.value += details.delta;
    updateDragFx(_drag.value.dx, MediaQuery.sizeOf(context).width);
  }

  void _onPanEnd(DragEndDetails _) {
    if (swipeFxBusy) return;
    final dx = _drag.value.dx;
    final w = MediaQuery.sizeOf(context).width;
    final threshold = w * 0.12 < 100 ? 100.0 : w * 0.12;
    _drag.value = Offset.zero;
    if (dx.abs() > threshold) {
      final like = dx > 0;
      runSwipeFx(
        fx: like ? SwipeFx.love : SwipeFx.pass,
        action: like ? widget.onLike : widget.onPass,
      );
    } else {
      clearDragFx();
    }
  }

  void _more() {
    final homeVm = context.read<HomeViewModel>();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ProfileActionsBottomSheet(
        userId: widget.profile.id,
        userName: widget.profile.name,
        onActionCompleted: () => homeVm.fetchProfiles(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    final height = _heightLabel(p.height);
    final reduce = MediaQuery.disableAnimationsOf(context);

    Widget card = LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.clamp(0.0, 1000.0);
        final maxH = constraints.maxHeight.clamp(0.0, 650.0);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxW > 900 ? 980 : maxW,
              maxHeight: maxH < 520 ? maxH : 640,
              minHeight: 0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  // Soft radial glow behind card (IgnorePointer)
                  IgnorePointer(
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _violet.withValues(alpha: 0.14),
                            blurRadius: 90,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  ValueListenableBuilder<Offset>(
                    valueListenable: _drag,
                    builder: (context, drag, child) {
                      return ListenableBuilder(
                        listenable: swipeProgress,
                        builder: (context, _) {
                          final p = completingSwipe
                              ? swipeProgress.value
                              : SwipeEffectOverlay.progressFromDx(
                                  drag.dx,
                                  MediaQuery.sizeOf(context).width,
                                );
                          return Opacity(
                            opacity:
                                SwipeEffectOverlay.swipeProfileOpacity(p),
                            child: Transform.translate(
                              offset:
                                  Offset(drag.dx * 0.35, drag.dy * 0.05),
                              child: Transform.rotate(
                                angle: drag.dx / 1400,
                                child: child,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xE6100720),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _border, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 80,
                              offset: const Offset(0, 25),
                            ),
                            BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.10),
                              blurRadius: 45,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Row(
                            children: [
                              Expanded(flex: 48, child: _photoPane(p)),
                              Expanded(
                                flex: 52,
                                child: _detailsPane(p, heightLabel: height),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Full-screen Discover FX above the card; never eats gestures.
                  Positioned.fill(
                    child: IgnorePointer(child: buildSwipeFxOverlay()),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (reduce) return card;
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(_enter.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 10),
            child: child,
          ),
        );
      },
      child: card,
    );
  }

  Widget _photoPane(DiscoveryProfile p) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AppNetworkImage(url: _photoUrl),
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color(0x26000000),
                  Color(0xD9000000),
                ],
                stops: [0.45, 0.72, 1],
              ),
            ),
          ),
        ),
        if (_photos.length > 1) ...[
          Positioned(
            top: 14,
            left: 14,
            right: 56,
            child: Row(
              children: [
                for (var i = 0; i < _photos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 5),
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: i == _photoIndex
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned.fill(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_photoIndex > 0) setState(() => _photoIndex--);
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (_photoIndex < _photos.length - 1) {
                        setState(() => _photoIndex++);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _GlassArrow(
                icon: Icons.chevron_left_rounded,
                onTap: _photoIndex > 0
                    ? () => setState(() => _photoIndex--)
                    : null,
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _GlassArrow(
                icon: Icons.chevron_right_rounded,
                onTap: _photoIndex < _photos.length - 1
                    ? () => setState(() => _photoIndex++)
                    : null,
              ),
            ),
          ),
        ],
        Positioned(
          top: 12,
          right: 12,
          child: _GlassIconButton(
            icon: Icons.more_horiz_rounded,
            onTap: _more,
          ),
        ),
        Positioned(
          left: 20,
          right: 78,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${p.name}, ${p.age}',
                      style: getTextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (p.isVerified) ...[
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF60A5FA),
                      size: 18,
                    ),
                  ],
                ],
              ),
              if (p.education.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  p.education,
                  style: getTextStyle(fontSize: 13, color: Colors.white70),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Selector<SuperLikesViewModel, bool>(
            selector: (_, vm) => vm.isSendingSuperLike,
            builder: (context, loading, _) => _SuperLikeFab(
              loading: loading,
              onTap: loading ? null : _superLike,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailsPane(DiscoveryProfile p, {required String heightLabel}) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF5140926), _surfaceRight],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 30, 32, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    '${p.name}, ${p.age}',
                    style: getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (p.isVerified) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified,
                    color: Color(0xFF60A5FA),
                    size: 20,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                if (p.education.isNotEmpty)
                  _Meta(icon: Icons.school_outlined, label: p.education),
                if (p.locationString.isNotEmpty)
                  _Meta(
                    icon: Icons.location_on_outlined,
                    label: p.locationString,
                  ),
              ],
            ),
            if (p.bio.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                p.bio,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(fontSize: 14, color: _muted, height: 1.5),
              ),
            ],
            const SizedBox(height: 18),
            _StatsBar(age: p.age, height: heightLabel, zodiac: p.zodiacSign),
            const SizedBox(height: 18),
            if (p.interests.isNotEmpty) ...[
              Text(
                'We can talk about',
                style: getTextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.interests
                        .take(10)
                        .map((i) => _InterestChip(label: i))
                        .toList(),
                  ),
                ),
              ),
            ] else
              const Spacer(),
            if (p.languages.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final lang in p.languages.take(6))
                    _LangPill(label: lang),
                ],
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    label: 'Like',
                    filled: true,
                    icon: Icons.favorite,
                    onTap: swipeFxBusy ? null : _onLike,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Selector<SuperLikesViewModel, bool>(
                    selector: (_, vm) => vm.isSendingSuperLike,
                    builder: (context, loading, _) => _ActionBtn(
                      label: 'Super Like',
                      filled: false,
                      outlined: true,
                      icon: Icons.star_rounded,
                      onTap: (loading || swipeFxBusy) ? null : _superLike,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    label: 'Pass',
                    filled: false,
                    icon: Icons.close,
                    onTap: swipeFxBusy ? null : _onPass,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── chrome ──────────────────────────────────────────────────────────────────

class _GlassIconButton extends StatefulWidget {
  const _GlassIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<_GlassIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xA60A0514),
              border: Border.all(
                color: _hover
                    ? _violet.withValues(alpha: 0.55)
                    : Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onTap,
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassArrow extends StatelessWidget {
  const _GlassArrow({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (onTap == null) return const SizedBox(width: 32);
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: Colors.white70, size: 22),
        ),
      ),
    );
  }
}

class _SuperLikeFab extends StatefulWidget {
  const _SuperLikeFab({required this.onTap, required this.loading});
  final VoidCallback? onTap;
  final bool loading;

  @override
  State<_SuperLikeFab> createState() => _SuperLikeFabState();
}

class _SuperLikeFabState extends State<_SuperLikeFab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final lift =
        _hover && !MediaQuery.disableAnimationsOf(context) ? -2.0 : 0.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, lift, 0),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_violet, _violetDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: _violet.withValues(alpha: _hover ? 0.55 : 0.35),
              blurRadius: _hover ? 22 : 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: widget.onTap,
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: _violetSoft),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: getTextStyle(fontSize: 13, color: _muted),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _StatsBar extends StatelessWidget {
  const _StatsBar({
    required this.age,
    required this.height,
    required this.zodiac,
  });
  final int age;
  final String height;
  final String zodiac;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      (Icons.cake_outlined, 'Age', '$age'),
      if (height.isNotEmpty) (Icons.straighten, 'Height', height),
      if (zodiac.trim().isNotEmpty)
        (Icons.auto_awesome, 'Zodiac', zodiac.trim()),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: _violet.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _violet.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                height: 36,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: _violet.withValues(alpha: 0.2),
              ),
            Expanded(
              child: Column(
                children: [
                  Icon(items[i].$1, size: 16, color: _violetSoft),
                  const SizedBox(height: 4),
                  Text(
                    items[i].$2,
                    style: getTextStyle(fontSize: 11, color: _muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    items[i].$3,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

IconData _interestIcon(String label) {
  final s = label.toLowerCase();
  if (s.contains('music') || s.contains('choir') || s.contains('sing')) {
    return Icons.music_note_rounded;
  }
  if (s.contains('netflix') || s.contains('movie') || s.contains('film')) {
    return Icons.movie_outlined;
  }
  if (s.contains('bar') || s.contains('drink') || s.contains('wine')) {
    return Icons.local_bar_outlined;
  }
  if (s.contains('run') || s.contains('jog') || s.contains('gym')) {
    return Icons.directions_run;
  }
  if (s.contains('tennis') || s.contains('sport') || s.contains('cricket')) {
    return Icons.sports_tennis;
  }
  if (s.contains('travel') || s.contains('hike') || s.contains('mountain')) {
    return Icons.terrain_outlined;
  }
  if (s.contains('food') || s.contains('cook')) {
    return Icons.restaurant_outlined;
  }
  if (s.contains('content') || s.contains('creat') || s.contains('photo')) {
    return Icons.auto_awesome;
  }
  return Icons.interests_outlined;
}

class _InterestChip extends StatefulWidget {
  const _InterestChip({required this.label});
  final String label;

  @override
  State<_InterestChip> createState() => _InterestChipState();
}

class _InterestChipState extends State<_InterestChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _hover
              ? _violet.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _hover
                ? _violet.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_interestIcon(widget.label), size: 14, color: _violetSoft),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: getTextStyle(fontSize: 12, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangPill extends StatelessWidget {
  const _LangPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _violet,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: getTextStyle(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatefulWidget {
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final bool outlined;
  final VoidCallback? onTap;

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final filled = widget.filled;
    final outlined = widget.outlined;
    final lift = _hover && !filled && !MediaQuery.disableAnimationsOf(context)
        ? 0.0
        : (_hover && filled && !MediaQuery.disableAnimationsOf(context)
            ? -2.0
            : 0.0);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(0, lift, 0),
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: filled
              ? const LinearGradient(colors: [_violet, _violetDeep])
              : null,
          color: filled
              ? null
              : (_hover
                  ? (outlined
                      ? _violet.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.06))
                  : Colors.transparent),
          border: filled
              ? null
              : Border.all(
                  color: outlined
                      ? _violet.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.28),
                  width: 1.3,
                ),
          boxShadow: filled
              ? [
                  BoxShadow(
                    color: _violet.withValues(alpha: _hover ? 0.5 : 0.32),
                    blurRadius: _hover ? 20 : 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.icon,
                  size: 18,
                  color: filled
                      ? Colors.white
                      : (outlined ? _violetSoft : Colors.white),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.label,
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: filled
                        ? Colors.white
                        : (outlined ? _violetSoft : Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void openPremiumSheet(BuildContext context) {
  showSubscriptionBottomSheet(
    context: context,
    title: 'Premium',
    message: 'Unlock more likes, Super Likes, and visibility.',
  );
}
