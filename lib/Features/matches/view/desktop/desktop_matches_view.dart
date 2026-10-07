import 'dart:ui';

import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/common_widgets/base_profile.dart';
import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/matches/model/match_response_model.dart';
import 'package:everqpidapp/Features/matches/model/received_like_profile_model.dart';
import 'package:everqpidapp/Features/matches/view_model/likes_view_model.dart';
import 'package:everqpidapp/Features/matches/view_model/matches_view_model.dart';
import 'package:everqpidapp/Features/messages/view/chat_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view/profile_actions.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Desktop/tablet Matches — presentation only; same ViewModels as mobile.
class DesktopMatchesView extends StatefulWidget {
  const DesktopMatchesView({super.key});

  @override
  State<DesktopMatchesView> createState() => _DesktopMatchesViewState();
}

class _DesktopMatchesViewState extends State<DesktopMatchesView>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  late final AnimationController _heartPulse;

  @override
  void initState() {
    super.initState();
    _heartPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _heartPulse.dispose();
    super.dispose();
  }

  void _goDiscover() => MainScreenBridge.navigateToTab(0);

  Future<void> _openChat(MatchUserProfile p) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverId: p.id,
          name: p.fullName,
          imageUrl: p.profileImageUrl ?? '',
          isOnline: false,
        ),
      ),
    );
  }

  void _openProfile(BaseProfile profile, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileDetailScreen(
          profile: profile,
          profileTitle: title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchesVM = context.watch<MatchesViewModel>();
    final likesVM = context.watch<LikesViewModel>();
    final matchCount = matchesVM.totalCount > 0
        ? matchesVM.totalCount
        : matchesVM.matches.length;
    final likesCount = likesVM.totalCount > 0
        ? likesVM.totalCount
        : likesVM.receivedLikes.length;
    final showRail = MediaQuery.sizeOf(context).width >= 1100 &&
        ((_tab == 0 && matchesVM.matches.isNotEmpty) ||
            (_tab == 1 && likesVM.receivedLikes.isNotEmpty));

    final main = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(onDiscover: _goDiscover),
        const SizedBox(height: 20),
        _SegmentedTabs(
          tab: _tab,
          matchesCount: matchCount,
          likesCount: likesCount,
          onChanged: (i) => setState(() => _tab = i),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _tab == 0
                ? KeyedSubtree(
                    key: const ValueKey('matches'),
                    child: _MatchesPane(
                      vm: matchesVM,
                      heartPulse: _heartPulse,
                      onDiscover: _goDiscover,
                      onOpenProfile: (p) => _openProfile(p, 'matches'),
                      onMessage: _openChat,
                    ),
                  )
                : KeyedSubtree(
                    key: const ValueKey('likes'),
                    child: _LikesPane(
                      vm: likesVM,
                      heartPulse: _heartPulse,
                      onDiscover: _goDiscover,
                      onOpenProfile: (p) => _openProfile(p, 'likes'),
                      onUpgrade: () => ProfileActions.openPremium(context),
                      compactGrid: showRail,
                    ),
                  ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
            child: showRail
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: main),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 280,
                        child: _MatchesSideRail(
                          onDiscover: _goDiscover,
                          onUpgrade: () => ProfileActions.openPremium(context),
                          onImproveProfile: () =>
                              ProfileActions.openEditProfile(context),
                        ),
                      ),
                    ],
                  )
                : main,
          ),
        ),
      ),
    );
  }
}

// ─── Header / tabs ──────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onDiscover});
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Match for you',
                    style: getTextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    Icons.favorite_rounded,
                    size: 22,
                    color: WelcomeTheme.violetLight.withValues(alpha: 0.95),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Find meaningful connections.',
                style: getTextStyle(
                  fontSize: 14,
                  color: const Color(0xFFB9B2C8),
                ),
              ),
            ],
          ),
        ),
        _VioletButton(
          label: 'Discover People',
          icon: Icons.groups_outlined,
          onPressed: onDiscover,
        ),
      ],
    );
  }
}

class _SegmentedTabs extends StatelessWidget {
  const _SegmentedTabs({
    required this.tab,
    required this.matchesCount,
    required this.likesCount,
    required this.onChanged,
  });

  final int tab;
  final int matchesCount;
  final int likesCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegTab(
              label: 'Matches',
              count: matchesCount,
              selected: tab == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _SegTab(
              label: 'Likes',
              count: likesCount,
              selected: tab == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegTab extends StatelessWidget {
  const _SegTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: selected
            ? const LinearGradient(
                colors: [WelcomeTheme.violetDeep, WelcomeTheme.violetSoft],
              )
            : null,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: WelcomeTheme.violet.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : const Color(0xFF9A92AB),
                  ),
                ),
                Text(
                  '  •  $count',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF7A728C),
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

// ─── Right rail ─────────────────────────────────────────────────────────────

class _MatchesSideRail extends StatelessWidget {
  const _MatchesSideRail({
    required this.onDiscover,
    required this.onUpgrade,
    required this.onImproveProfile,
  });

  final VoidCallback onDiscover;
  final VoidCallback onUpgrade;
  final VoidCallback onImproveProfile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          width: double.infinity,
          child: _VioletButton(
            label: 'Discover People',
            icon: Icons.groups_outlined,
            onPressed: onDiscover,
            expand: true,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF140A22).withValues(alpha: 0.75),
            border: Border.all(
              color: WelcomeTheme.violet.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.workspace_premium_outlined,
                    color: WelcomeTheme.violetLight,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'EverQpid Premium',
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _BenefitRow('See who likes you'),
              const _BenefitRow('Unlimited likes'),
              const _BenefitRow('Priority in Discover'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _VioletButton(
                  label: 'Upgrade to Premium',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onUpgrade,
                  expand: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.04),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Profile tips',
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '• Add more photos\n• Complete your profile',
                style: getTextStyle(
                  fontSize: 13,
                  color: const Color(0xFFB9B2C8),
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onImproveProfile,
                style: TextButton.styleFrom(
                  foregroundColor: WelcomeTheme.violetLight,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  'Improve My Profile →',
                  style: getTextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: WelcomeTheme.violetLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: WelcomeTheme.violetLight),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: getTextStyle(fontSize: 13, color: const Color(0xFFD6CFE3)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Matches pane ───────────────────────────────────────────────────────────

class _MatchesPane extends StatelessWidget {
  const _MatchesPane({
    required this.vm,
    required this.heartPulse,
    required this.onDiscover,
    required this.onOpenProfile,
    required this.onMessage,
  });

  final MatchesViewModel vm;
  final Animation<double> heartPulse;
  final VoidCallback onDiscover;
  final ValueChanged<MatchUserProfile> onOpenProfile;
  final ValueChanged<MatchUserProfile> onMessage;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.matches.isEmpty) return const _SkeletonGrid();
    if (vm.errorMessage != null && vm.matches.isEmpty) {
      return _EmptyGlass(
        heartPulse: heartPulse,
        title: "Couldn't load your matches",
        body: 'Something went wrong while loading your connections.',
        primaryLabel: 'Try Again',
        primaryIcon: Icons.refresh_rounded,
        onPrimary: () => vm.refreshMatches(),
      );
    }
    if (vm.matches.isEmpty) {
      return _EmptyGlass(
        heartPulse: heartPulse,
        title: 'No matches yet',
        body:
            'Your next connection could be just one swipe away.\nKeep discovering people and your new matches will appear here.',
        primaryLabel: 'Discover People',
        primaryIcon: Icons.groups_outlined,
        onPrimary: onDiscover,
        secondaryLabel: 'Retry',
        onSecondary: () => vm.refreshMatches(),
        secondaryLoading: vm.isLoading,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _gridCols(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: vm.matches.length,
            itemBuilder: (_, i) {
              final p = vm.matches[i];
              return _DesktopPersonCard(
                name: p.fullName,
                age: p.age,
                imageUrl: p.profileImageUrl ?? '',
                isVerified: p.isVerified,
                location: p.locationString,
                showMessage: true,
                onTap: () => onOpenProfile(p),
                onMessage: () => onMessage(p),
              );
            },
          ),
        ),
        if (vm.hasNext)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: _ViewMoreButton(
                loading: vm.isLoadingMore,
                onPressed: () => vm.loadMoreMatches(),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Likes pane ─────────────────────────────────────────────────────────────

class _LikesPane extends StatelessWidget {
  const _LikesPane({
    required this.vm,
    required this.heartPulse,
    required this.onDiscover,
    required this.onOpenProfile,
    required this.onUpgrade,
    required this.compactGrid,
  });

  final LikesViewModel vm;
  final Animation<double> heartPulse;
  final VoidCallback onDiscover;
  final ValueChanged<ReceivedLikeProfile> onOpenProfile;
  final VoidCallback onUpgrade;
  final bool compactGrid;

  @override
  Widget build(BuildContext context) {
    if (vm.isLoading && vm.receivedLikes.isEmpty) return const _SkeletonGrid();

    if (vm.errorMessage != null &&
        vm.receivedLikes.isEmpty &&
        vm.statusCode != 400) {
      return _EmptyGlass(
        heartPulse: heartPulse,
        title: "Couldn't load likes",
        body: vm.errorMessage!,
        primaryLabel: 'Try Again',
        primaryIcon: Icons.refresh_rounded,
        onPrimary: () => vm.fetchReceivedLikes(isRefresh: true),
      );
    }

    final locked = !vm.isSubscribed && vm.receivedLikes.isNotEmpty;

    if (vm.receivedLikes.isEmpty) {
      // Match mobile copy when empty; premium upsell only when locked likes exist.
      return _EmptyGlass(
        heartPulse: heartPulse,
        title: 'No one liked you yet 😢',
        body: "Don't worry, your perfect match is coming!",
        primaryLabel: 'Discover People',
        primaryIcon: Icons.groups_outlined,
        onPrimary: onDiscover,
        secondaryLabel: 'Refresh Likes',
        onSecondary: () => vm.fetchReceivedLikes(isRefresh: true),
        secondaryLoading: vm.isLoading,
      );
    }

    final cols = compactGrid
        ? (MediaQuery.sizeOf(context).width >= 1400 ? 4 : 3)
        : _gridCols(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'People who liked you',
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.only(bottom: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),
            itemCount: vm.receivedLikes.length,
            itemBuilder: (_, i) {
              final p = vm.receivedLikes[i];
              return _DesktopPersonCard(
                name: p.fullName,
                age: p.age,
                imageUrl: p.profileImageUrl,
                isVerified: p.isVerified,
                location: p.locationString,
                locked: locked,
                onTap: locked ? onUpgrade : () => onOpenProfile(p),
              );
            },
          ),
        ),
        if (vm.hasNext)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: _ViewMoreButton(
                loading: vm.isLoadingMore,
                onPressed: () => vm.loadMoreLikes(),
              ),
            ),
          ),
      ],
    );
  }
}

int _gridCols(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w >= 1400) return 4;
  if (w >= 1000) return 3;
  return profileGridColumns(context);
}

// ─── Card ───────────────────────────────────────────────────────────────────

class _DesktopPersonCard extends StatefulWidget {
  const _DesktopPersonCard({
    required this.name,
    required this.age,
    required this.imageUrl,
    required this.isVerified,
    required this.onTap,
    this.location,
    this.showMessage = false,
    this.onMessage,
    this.locked = false,
  });

  final String name;
  final int age;
  final String imageUrl;
  final bool isVerified;
  final String? location;
  final bool showMessage;
  final VoidCallback onTap;
  final VoidCallback? onMessage;
  final bool locked;

  @override
  State<_DesktopPersonCard> createState() => _DesktopPersonCardState();
}

class _DesktopPersonCardState extends State<_DesktopPersonCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final loc = widget.location?.trim();
    final meta = [
      '${widget.name}, ${widget.age}',
      if (loc != null && loc.isNotEmpty) loc,
    ].join(' · ');

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFF120A1F).withValues(alpha: 0.72),
          border: Border.all(
            color: _hover
                ? WelcomeTheme.violetLight.withValues(alpha: 0.55)
                : WelcomeTheme.violet.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: _hover
                  ? WelcomeTheme.violet.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.25),
              blurRadius: _hover ? 22 : 12,
              offset: Offset(0, _hover ? 8 : 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedScale(
                          scale: _hover ? 1.03 : 1.0,
                          duration: const Duration(milliseconds: 220),
                          child: AppNetworkImage(
                            url: widget.imageUrl,
                            memCacheWidth: 480,
                            errorIconSize: 40,
                          ),
                        ),
                        if (widget.locked) ...[
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: ColoredBox(
                              color: Colors.black.withValues(alpha: 0.28),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: WelcomeTheme.violet
                                          .withValues(alpha: 0.85),
                                    ),
                                    child: const Icon(
                                      Icons.lock_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Upgrade to Premium\nto see who likes you',
                                    textAlign: TextAlign.center,
                                    style: getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ] else ...[
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0x990A0414),
                                ],
                                stops: [0.55, 1],
                              ),
                            ),
                          ),
                          if (widget.showMessage && widget.onMessage != null)
                            Positioned(
                              left: 10,
                              right: 10,
                              bottom: 10,
                              child: SizedBox(
                                height: 32,
                                child: OutlinedButton.icon(
                                  onPressed: widget.onMessage,
                                  icon: const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 14,
                                  ),
                                  label: const Text('Message'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    backgroundColor:
                                        Colors.black.withValues(alpha: 0.28),
                                    side: BorderSide(
                                      color: WelcomeTheme.violetLight
                                          .withValues(alpha: 0.55),
                                    ),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                    textStyle: getTextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getTextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (widget.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.verified,
                              size: 14,
                              color: Color(0xFF60A5FA),
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
      ),
    );
  }
}

// ─── Empty / skeleton / buttons ─────────────────────────────────────────────

class _EmptyGlass extends StatelessWidget {
  const _EmptyGlass({
    required this.heartPulse,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.primaryIcon,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.secondaryLoading = false,
  });

  final Animation<double> heartPulse;
  final String title;
  final String body;
  final String primaryLabel;
  final IconData primaryIcon;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final bool secondaryLoading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 56),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: const Color(0xFF120A1F).withValues(alpha: 0.55),
            border: Border.all(
              color: WelcomeTheme.violet.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: WelcomeTheme.violet.withValues(alpha: 0.12),
                blurRadius: 40,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeartVisual(pulse: heartPulse),
              const SizedBox(height: 24),
              Text(
                title,
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                textAlign: TextAlign.center,
                style: getTextStyle(
                  fontSize: 14,
                  color: const Color(0xFFB9B2C8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _VioletButton(
                label: primaryLabel,
                icon: primaryIcon,
                onPressed: onPrimary,
              ),
              if (secondaryLabel != null && onSecondary != null) ...[
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: secondaryLoading ? null : onSecondary,
                  icon: secondaryLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: WelcomeTheme.violetLight,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(secondaryLabel!),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFB9B2C8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _HeartVisual extends StatelessWidget {
  const _HeartVisual({required this.pulse});
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 140,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, _) {
          final t = pulse.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100 + t * 14,
                height: 100 + t * 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: WelcomeTheme.violet
                          .withValues(alpha: 0.28 + t * 0.18),
                      blurRadius: 40 + t * 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 22,
                top: 28 + t * 8,
                child: Icon(
                  Icons.favorite_border,
                  size: 18,
                  color: WelcomeTheme.violetLight.withValues(alpha: 0.4),
                ),
              ),
              Positioned(
                right: 28,
                top: 20 + (1 - t) * 10,
                child: Icon(
                  Icons.favorite,
                  size: 12,
                  color: WelcomeTheme.violetSoft.withValues(alpha: 0.45),
                ),
              ),
              Positioned(
                right: 36,
                bottom: 32 - t * 6,
                child: Icon(
                  Icons.favorite_border,
                  size: 14,
                  color: WelcomeTheme.violet.withValues(alpha: 0.35),
                ),
              ),
              Transform.scale(
                scale: 0.94 + t * 0.1,
                child: Icon(
                  Icons.favorite_rounded,
                  size: 72,
                  color: WelcomeTheme.violetLight.withValues(alpha: 0.92),
                  shadows: [
                    Shadow(
                      color: WelcomeTheme.violet.withValues(alpha: 0.7),
                      blurRadius: 24,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridCols(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.78,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
    );
  }
}

class _ViewMoreButton extends StatelessWidget {
  const _ViewMoreButton({required this.onPressed, required this.loading});
  final VoidCallback onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: loading ? null : onPressed,
      icon: loading
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
        textStyle: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _VioletButton extends StatelessWidget {
  const _VioletButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.expand = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [WelcomeTheme.violetDeep, WelcomeTheme.violetSoft],
        ),
        boxShadow: [
          BoxShadow(
            color: WelcomeTheme.violet.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: getTextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}
