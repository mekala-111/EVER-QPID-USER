import 'dart:ui';

import 'package:everqpidapp/Features/onboarding/view/welcome/sections/app_cta_section.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/sections/blog_section.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/sections/contact_section.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/sections/features_section.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/sections/final_cta_section.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/sections/how_it_works_section.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/sections/landing_footer.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/sections/success_stories_section.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_actions.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_shared_widgets.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/onboarding/view/welcome/widgets/landing_background.dart';
import 'package:everqpidapp/Features/onboarding/view/widgets/welcome_photo_collage.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';

/// Full vertically scrollable landing (desktop + mobile).
///
/// Root cause of "only Hero visible": Hero filled the viewport
/// (`minHeight: screen − nav`) while mobile routed to a splash-only view.
/// Architecture: viewport-filling background Stack + unbounded CustomScrollView
/// content that grows with every section.
class WelcomeWebView extends StatefulWidget {
  const WelcomeWebView({super.key, required this.animations});

  final WelcomeIntroAnimations animations;

  @override
  State<WelcomeWebView> createState() => _WelcomeWebViewState();
}

class _WelcomeWebViewState extends State<WelcomeWebView> {
  final _scrollController = ScrollController();
  final _homeKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _howItWorksKey = GlobalKey();
  final _successStoriesKey = GlobalKey();
  final _blogKey = GlobalKey();
  final _contactKey = GlobalKey();

  String _activeNav = 'Home';
  bool _scrolled = false;

  late final Map<String, GlobalKey> _sectionKeys = {
    'Features': _featuresKey,
    'How it works': _howItWorksKey,
    'Success stories': _successStoriesKey,
    'Blog': _blogKey,
    'Contact': _contactKey,
  };

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final scrolled = offset > 24;
    if (scrolled != _scrolled) setState(() => _scrolled = scrolled);

    String next = 'Home';
    for (final item in WelcomeTheme.navItems.skip(1)) {
      final ctx = _sectionKeys[item]?.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final y = box.localToGlobal(Offset.zero).dy;
      // Active when section top has crossed under sticky nav.
      if (y <= WelcomeTheme.navHeight + 48) next = item;
    }
    if (next != _activeNav) setState(() => _activeNav = next);
  }

  void _scrollTo(String item) {
    setState(() => _activeNav = item);
    if (item == 'Home') {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
      return;
    }
    final ctx = _sectionKeys[item]?.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
      // Leave room for sticky navbar so section headings stay visible.
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padH = WelcomeTheme.horizontalPad(size.width);
    final topInset = MediaQuery.paddingOf(context).top;
    final navBlock = topInset + WelcomeTheme.navHeight;

    return Scaffold(
      backgroundColor: WelcomeTheme.pageBg,
      body: Stack(
        children: [
          const LandingBackground(),
          CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Clears sticky nav so section titles aren't covered.
              SliverToBoxAdapter(child: SizedBox(height: navBlock)),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _homeKey,
                  child: ConstrainedBox(
                    // Hero min-height only — does NOT clamp the whole page.
                    constraints: BoxConstraints(
                      minHeight: (size.height - navBlock).clamp(850.0, 950.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(padH, 24, padH, 48),
                      child: _DesktopHero(
                        animations: widget.animations,
                        onLearnMore: () => _scrollTo('Features'),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _featuresKey,
                  child: const FeaturesSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _howItWorksKey,
                  child: const HowItWorksSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _successStoriesKey,
                  child: const SuccessStoriesSection(),
                ),
              ),
              const SliverToBoxAdapter(child: AppCtaSection()),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _blogKey,
                  child: const BlogSection(),
                ),
              ),
              SliverToBoxAdapter(
                child: KeyedSubtree(
                  key: _contactKey,
                  child: const ContactSection(),
                ),
              ),
              const SliverToBoxAdapter(child: FinalCtaSection()),
              SliverToBoxAdapter(
                child: LandingFooter(onNavTap: _scrollTo),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _StickyNav(
              topInset: topInset,
              padH: padH,
              scrolled: _scrolled,
              active: _activeNav,
              onNavTap: _scrollTo,
              onJoinNow: () => WelcomeActions.openLogin(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyNav extends StatelessWidget {
  const _StickyNav({
    required this.topInset,
    required this.padH,
    required this.scrolled,
    required this.active,
    required this.onNavTap,
    required this.onJoinNow,
  });

  final double topInset;
  final double padH;
  final bool scrolled;
  final String active;
  final ValueChanged<String> onNavTap;
  final VoidCallback onJoinNow;

  @override
  Widget build(BuildContext context) {
    final bar = Container(
      height: WelcomeTheme.navHeight,
      padding: EdgeInsets.symmetric(horizontal: padH),
      decoration: BoxDecoration(
        color: scrolled
            ? WelcomeTheme.pageBg.withValues(alpha: 0.72)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: scrolled
                ? WelcomeTheme.violet.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
      ),
      child: _WebNavBar(
        active: active,
        onNavTap: onNavTap,
        onJoinNow: onJoinNow,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: topInset),
        if (scrolled)
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: bar,
            ),
          )
        else
          bar,
      ],
    );
  }
}

/// Existing Hero — appearance preserved; only layout stacks on narrow widths.
class _DesktopHero extends StatelessWidget {
  const _DesktopHero({
    required this.animations,
    required this.onLearnMore,
  });

  final WelcomeIntroAnimations animations;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final headingSize = (width * 0.055).clamp(
      width < 900 ? 42.0 : WelcomeTheme.desktopHeadingMin,
      WelcomeTheme.desktopHeadingMax,
    );
    final teaserFeatures = WelcomeTheme.features.take(3).toList();
    final stack = width < 900;

    final copy = FadeTransition(
      opacity: animations.headlineFade,
      child: SlideTransition(
        position: animations.headlineSlide,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              stack ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: [
            WelcomeHeadline(
              fontSize: headingSize,
              showHeart: true,
              heartInline: true,
              maxWidth: 620,
              textAlign: stack ? TextAlign.center : TextAlign.left,
            ),
            const SizedBox(height: 22),
            WelcomeSubtitle(
              fontSize: 18,
              maxWidth: 480,
              textAlign: stack ? TextAlign.center : TextAlign.left,
            ),
            const SizedBox(height: 36),
            FadeTransition(
              opacity: animations.ctaFade,
              child: ScaleTransition(
                scale: animations.ctaScale,
                child: Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  alignment:
                      stack ? WrapAlignment.center : WrapAlignment.start,
                  children: [
                    WelcomeJoinButton(
                      width: WelcomeTheme.ctaWidth,
                      height: WelcomeTheme.ctaHeight,
                      onPressed: () => WelcomeActions.openLogin(context),
                    ),
                    WelcomeOutlineButton(
                      label: 'Learn more',
                      width: WelcomeTheme.ctaWidth,
                      height: WelcomeTheme.ctaHeight,
                      onPressed: onLearnMore,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 56),
            WelcomeFeatureRow(features: teaserFeatures),
          ],
        ),
      ),
    );

    final collage = SizedBox(
      height: stack ? 380 : 560,
      child: FadeTransition(
        opacity: animations.logoFade,
        child: const WelcomePhotoCollage(
          neon: true,
          showCenterHeart: true,
          showBackdropGlow: true,
        ),
      ),
    );

    if (stack) {
      return Column(
        children: [copy, const SizedBox(height: 40), collage],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 45, child: copy),
        const SizedBox(width: 32),
        Expanded(flex: 55, child: collage),
      ],
    );
  }
}

class _WebNavBar extends StatelessWidget {
  const _WebNavBar({
    required this.active,
    required this.onNavTap,
    required this.onJoinNow,
  });

  final String active;
  final ValueChanged<String> onNavTap;
  final VoidCallback onJoinNow;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 900;

    return Row(
      children: [
        InkWell(
          onTap: () => onNavTap('Home'),
          borderRadius: BorderRadius.circular(8),
          child: Text(
            'EverQpid',
            style: getTextStyle(
              fontSize: narrow ? 22 : 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const Spacer(),
        if (!narrow)
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in WelcomeTheme.navItems) ...[
                    _NavLink(
                      label: item,
                      selected: item == active,
                      onTap: () => onNavTap(item),
                    ),
                    const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          )
        else
          PopupMenuButton<String>(
            tooltip: 'Menu',
            color: WelcomeTheme.bgMid,
            onSelected: onNavTap,
            itemBuilder: (_) => [
              for (final item in WelcomeTheme.navItems)
                PopupMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
            ],
            child: const Icon(Icons.menu_rounded, color: Colors.white),
          ),
        const SizedBox(width: 16),
        WelcomeJoinButton(
          onPressed: onJoinNow,
          compact: true,
          height: 48,
          width: narrow ? 110 : 132,
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: getTextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: Colors.white.withValues(alpha: selected ? 1 : 0.55),
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2.5,
              width: selected ? 26 : 0,
              decoration: BoxDecoration(
                color: WelcomeTheme.violetLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
