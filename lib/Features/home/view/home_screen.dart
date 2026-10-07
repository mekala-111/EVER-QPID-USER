import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/home/model/discovery_profile_model.dart';
import 'package:everqpidapp/Features/home/view/home_web_discover.dart';
import 'package:everqpidapp/Features/home/view/swipe_feedback_overlay.dart';
import 'package:everqpidapp/Features/home/view_model/home_view_model.dart';
import 'package:everqpidapp/Features/profileactions/view/profile_action_bottom_sheet.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_bottom_sheet.dart';
import 'package:everqpidapp/Features/superlikes/view/subscription_required_dialog.dart';
import 'package:everqpidapp/Features/superlikes/view_model/super_likes_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch profiles when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().fetchProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Shell (tablet/desktop) uses dark MainScreen chrome — keep body transparent.
    final inShell = !context.isMobile;

    return Scaffold(
      backgroundColor: inShell ? Colors.transparent : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (!inShell)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(Images.everqpid, height: 32),
                    IconButton(
                      icon: const Icon(Icons.tune, size: 28),
                      onPressed: () {
                        // TODO: open filter screen
                      },
                    ),
                  ],
                ),
              ),

            // Profile card — capped on tablet/desktop so the deck doesn't stretch.
            Expanded(
              child: AppContentFrame(
                maxWidth:
                    inShell ? ContentMaxWidth.shell : ContentMaxWidth.homeCard,
                child: Consumer<HomeViewModel>(
                  builder: (context, viewModel, child) {
                    // Loading state
                    if (viewModel.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: inShell ? const Color(0xFFC084FC) : null,
                        ),
                      );
                    }

                    // Error state
                    if (viewModel.errorMessage != null &&
                        !viewModel.hasProfiles) {
                      final fg = inShell ? Colors.white70 : Colors.grey[700];
                      final iconC = inShell ? Colors.white38 : Colors.grey[400];
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80,
                              color: iconC,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              viewModel.errorMessage!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: fg),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: viewModel.fetchProfiles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PColors.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Empty state
                    if (!viewModel.hasProfiles && !viewModel.isLoading) {
                      final titleC = inShell ? Colors.white : Colors.grey[700];
                      final bodyC = inShell ? Colors.white54 : Colors.grey[500];
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color:
                                  inShell ? Colors.white38 : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No profiles found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: titleC,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Check back later for new matches',
                              style: TextStyle(fontSize: 14, color: bodyC),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show profiles
                    if (viewModel.currentIndex < viewModel.profiles.length) {
                      final profile =
                          viewModel.profiles[viewModel.currentIndex];
                      if (inShell) {
                        final reduce = MediaQuery.disableAnimationsOf(context);
                        return AnimatedSwitcher(
                          duration: Duration(
                            milliseconds: reduce ? 0 : 300,
                          ),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, anim) {
                            if (reduce) return child;
                            final slide = Tween<Offset>(
                              begin: const Offset(0.035, 0),
                              end: Offset.zero,
                            ).animate(anim);
                            return FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: slide,
                                child: child,
                              ),
                            );
                          },
                          child: WebDiscoverCard(
                            key: ValueKey(profile.id),
                            profile: profile,
                            onLike: () => viewModel.onSwipe(true, context),
                            onPass: () => viewModel.onSwipe(false, context),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () => viewModel.refreshProfiles(),
                        child: SwipeableProfileCard(
                          profile: profile,
                          onSwipeLeft: () => viewModel.onSwipe(false, context),
                          onSwipeRight: () => viewModel.onSwipe(true, context),
                          isLoadingMore: viewModel.isLoadingMore,
                        ),
                      );
                    }

                    // All profiles viewed
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: inShell ? Colors.white38 : Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'That\'s everyone for now!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: inShell ? Colors.white : Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new profiles',
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  inShell ? Colors.white54 : Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: viewModel.refreshProfiles,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PColors.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ============= SWIPEABLE PROFILE CARD WITH DETAILS =============
//

class SwipeableProfileCard extends StatefulWidget {
  final DiscoveryProfile profile;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool isLoadingMore;

  const SwipeableProfileCard({
    super.key,
    required this.profile,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    this.isLoadingMore = false,
  });

  @override
  State<SwipeableProfileCard> createState() => _SwipeableProfileCardState();
}

class _SwipeableProfileCardState extends State<SwipeableProfileCard>
    with TickerProviderStateMixin, DiscoverSwipeFxHost {
  final ValueNotifier<Offset> _drag = ValueNotifier(Offset.zero);
  bool _isDragging = false;
  late ScrollController _scrollController;
  int _photoIndex = 0;

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

  @override
  void initState() {
    super.initState();
    initSwipeFx();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) SwipeEffectOverlay.precache(context);
    });
  }

  @override
  void didUpdateWidget(covariant SwipeableProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.id != widget.profile.id) {
      _photoIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
  }

  @override
  void dispose() {
    disposeSwipeFx();
    _drag.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  void _prevPhoto() {
    if (_photoIndex <= 0) return;
    setState(() => _photoIndex--);
  }

  void _nextPhoto() {
    if (_photoIndex >= _photos.length - 1) return;
    setState(() => _photoIndex++);
  }

  void _onDragStart(DragStartDetails details) {
    if (swipeFxBusy) return;
    setState(() => _isDragging = true);
  }

  Future<void> _handleSuperLike() async {
    if (swipeFxBusy) return;
    final userId = LoggedInUser.id;
    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }

    final matchingViewModel = context.read<SuperLikesViewModel>();

    // Show loading indicator
    setState(() {});

    final response = await matchingViewModel.sendSuperLike(
      userId: userId,
      toUserId: widget.profile.id,
    );

    if (!mounted) return;

    if (response.isSuccess) {
      // Show success animation/message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.star_rounded, color: Colors.amber[300]),
              const SizedBox(width: 8),
              const Text('Super like sent!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );

      await runSwipeFx(fx: SwipeFx.love, action: widget.onSwipeRight);
    } else if (response.needsSubscription) {
      // Show subscription dialog
      showSubscriptionRequiredDialog(
        context: context,
        message: response.message,
        onSubscribe: () {
          // // TODO: Navigate to subscription screen
          // ScaffoldMessenger.of(
          //   context,
          // ).showSnackBar(const SnackBar(content: Text('Super like enabled')));
          // Show subscription bottom sheet
          showSubscriptionBottomSheet(
            context: context,
            title: 'Subscription',
            message: response.message,
          );
        },
      );
    } else {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message), backgroundColor: Colors.red),
      );
    }
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (swipeFxBusy) return;
    _drag.value += details.delta;
    final w = MediaQuery.sizeOf(context).width;
    updateDragFx(_drag.value.dx, w);
  }

  void _onDragEnd(DragEndDetails details) {
    if (swipeFxBusy) return;
    const swipeThreshold = 100;
    final dragPosition = _drag.value;

    if (dragPosition.dx.abs() > swipeThreshold) {
      final like = dragPosition.dx > 0;
      _drag.value = Offset.zero;
      setState(() => _isDragging = false);
      runSwipeFx(
        fx: like ? SwipeFx.love : SwipeFx.pass,
        action: like ? widget.onSwipeRight : widget.onSwipeLeft,
      );
    } else {
      _drag.value = Offset.zero;
      clearDragFx();
      setState(() => _isDragging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onPanStart: _onDragStart,
          onPanUpdate: _onDragUpdate,
          onPanEnd: _onDragEnd,
          child: ValueListenableBuilder<Offset>(
            valueListenable: _drag,
            builder: (context, dragPosition, child) {
              final rotation = dragPosition.dx / 1000;
              final opacity = SwipeEffectOverlay.swipeProfileOpacity(
                SwipeEffectOverlay.progressFromDx(
                  dragPosition.dx,
                  MediaQuery.sizeOf(context).width,
                ),
              );
              return Transform.translate(
                offset: dragPosition,
                child: Transform.rotate(
                  angle: rotation,
                  child: Opacity(
                    opacity: opacity,
                    child: child,
                  ),
                ),
              );
            },
            child: _buildCardBody(),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(child: buildSwipeFxOverlay()),
        ),
      ],
    );
  }

  Widget _buildCardBody() {
    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Stack(
            children: [
              // Main card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: _isDragging
                        ? const NeverScrollableScrollPhysics()
                        : const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //
                        // MAIN IMAGE + OVERLAY CONTENT
                        //
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              RepaintBoundary(
                                child: AppNetworkImage(
                                  url: _photos.isEmpty
                                      ? widget.profile.imageUrl
                                      : _photos[_photoIndex.clamp(
                                          0,
                                          _photos.length - 1,
                                        )],
                                ),
                              ),

                              // Gradient
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.75),
                                      ],
                                      stops: const [0.5, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              // Tap left / right to cycle photos (not scroll —
                              // scroll is reserved for the card body).
                              if (_photos.length > 1)
                                Positioned.fill(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: _prevPhoto,
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: _nextPhoto,
                                          child: const SizedBox.expand(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Story-style progress segments
                              if (_photos.length > 1)
                                Positioned(
                                  top: 10,
                                  left: 12,
                                  right: 48,
                                  child: Row(
                                    children:
                                        List.generate(_photos.length, (i) {
                                      final active = i <= _photoIndex;
                                      return Expanded(
                                        child: Container(
                                          height: 3,
                                          margin: EdgeInsets.only(
                                            right:
                                                i == _photos.length - 1 ? 0 : 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(
                                              alpha: active ? 0.95 : 0.35,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),

                              // Web: explicit chevron controls (Figma)
                              if (kIsWeb && _photos.length > 1) ...[
                                if (_photoIndex > 0)
                                  Positioned(
                                    left: 10,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: _PhotoNavButton(
                                        icon: Icons.chevron_left,
                                        onTap: _prevPhoto,
                                      ),
                                    ),
                                  ),
                                if (_photoIndex < _photos.length - 1)
                                  Positioned(
                                    right: 10,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: _PhotoNavButton(
                                        icon: Icons.chevron_right,
                                        onTap: _nextPhoto,
                                      ),
                                    ),
                                  ),
                              ],

                              // Three dots menu
                              Positioned(
                                top: 16,
                                right: 16,
                                child: GestureDetector(
                                  onTap: () {
                                    final homeViewModel =
                                        context.read<HomeViewModel>();
                                    showModalBottomSheet(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      isScrollControlled: true,
                                      builder: (context) =>
                                          ProfileActionsBottomSheet(
                                        userId: widget.profile
                                            .id, // Make sure your DiscoveryProfile model has id field
                                        userName: widget.profile.name,
                                        onActionCompleted: () async {
                                          // Refresh profiles or move to next
                                          await homeViewModel.fetchProfiles();
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(
                                        20,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.more_vert,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),

                              // Name, age, education + purple button
                              Positioned(
                                left: 20,
                                right: 20,
                                bottom: 20,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  '${widget.profile.name}, ${widget.profile.age}',
                                                  style: getTextStyle(
                                                    fontSize: 32,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (widget
                                                  .profile.isVerified) ...[
                                                const SizedBox(width: 8),
                                                const Icon(
                                                  Icons.verified,
                                                  color: Colors.blue,
                                                  size: 24,
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.school,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              Flexible(
                                                child: Text(
                                                  widget.profile.education,
                                                  style: getTextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Selector<SuperLikesViewModel, bool>(
                                      selector: (_, vm) =>
                                          vm.isSendingSuperLike,
                                      builder: (context, isLoading, _) {
                                        return GestureDetector(
                                          onTap: isLoading
                                              ? null
                                              : _handleSuperLike,
                                          child: Container(
                                            padding: const EdgeInsets.all(
                                              12,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isLoading
                                                  ? Colors.grey[400]
                                                  : PColors.primaryColor,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: PColors.primaryColor
                                                      .withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(
                                                    0,
                                                    4,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            child: isLoading
                                                ? const SizedBox(
                                                    width: 30,
                                                    height: 30,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.white),
                                                    ),
                                                  )
                                                : Image.asset(
                                                    Images.arrowLove,
                                                    height: 30,
                                                    color: Colors.white,
                                                  ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        //
                        // INTERESTS
                        //
                        if (widget.profile.interests.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'We can talk about',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.profile.interests
                                      .map(
                                        (interest) =>
                                            _InterestChip(label: interest),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),

                        if (widget.profile.interests.isNotEmpty)
                          const Divider(height: 1),

                        //
                        // LANGUAGES
                        //
                        if (widget.profile.languages.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Languages',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.profile.languages
                                      .map(
                                        (lang) => _LanguageChip(label: lang),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),

                        if (widget.profile.languages.isNotEmpty)
                          const Divider(height: 1),

                        //
                        // SECONF IMAGE
                        //
                        if (widget.profile.additionalImages.length > 1)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AppNetworkImage(
                                  url: widget.profile.additionalImages[1],
                                ),
                              ),
                            ),
                          ),

                        if (widget.profile.additionalImages.length > 1)
                          const Divider(height: 1),
                        //
                        // BIO
                        //
                        if (widget.profile.bio.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'This is Me',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.profile.bio,
                                  style: getTextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // if (widget.profile.bio.isNotEmpty)
                        //   const Divider(height: 1),

                        //
                        // BASICS
                        //
                        if (widget.profile.relationshipStatus.isNotEmpty ||
                            widget.profile.height > 0 ||
                            widget.profile.religion.isNotEmpty ||
                            widget.profile.locationString.isNotEmpty) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Basics',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    // Relationship Status
                                    if (widget.profile.relationshipStatus
                                            .isNotEmpty &&
                                        widget.profile.relationshipStatus !=
                                            'Not specified')
                                      _IconBasicChip(
                                        icon: Icons.people,
                                        label:
                                            widget.profile.relationshipStatus,
                                        iconColor: PColors.primaryColor,
                                      ),

                                    // Height
                                    if (widget.profile.height > 0)
                                      _IconBasicChip(
                                        icon: Icons.straighten,
                                        label: '${widget.profile.height} cm',
                                        iconColor: Colors.blue[700],
                                      ),

                                    // Religion
                                    if (widget.profile.religion.isNotEmpty &&
                                        widget.profile.religion !=
                                            'Not specified' &&
                                        widget.profile.religion !=
                                            'Prefer not to say')
                                      _IconBasicChip(
                                        icon: Icons.auto_awesome,
                                        label: widget.profile.religion,
                                        iconColor: Colors.orange[700],
                                      ),
                                    // Zodiac Sign
                                    if (widget.profile.zodiacSign.isNotEmpty &&
                                        widget.profile.zodiacSign !=
                                            'Not specified')
                                      _IconBasicChip(
                                        icon: Icons.star,
                                        label: widget.profile.zodiacSign,
                                        iconColor: Colors.pink[700],
                                      ),

                                    // Alcohol Consumption
                                    if (widget.profile.alcoholConsumption
                                            .isNotEmpty &&
                                        widget.profile.alcoholConsumption !=
                                            'Not specified')
                                      _IconBasicChip(
                                        icon: Icons.local_bar,
                                        label:
                                            widget.profile.alcoholConsumption,
                                        iconColor: Colors.purple[700],
                                      ),
                                    // Smoking Habits
                                    if (widget
                                            .profile.smokingHabit.isNotEmpty &&
                                        widget.profile.smokingHabit !=
                                            'Not specified')
                                      _IconBasicChip(
                                        icon: Icons.smoking_rooms_rounded,
                                        label: widget.profile.smokingHabit,
                                        iconColor: Colors.brown[700],
                                      ),
                                    // Workout Frequency
                                    if (widget.profile.workoutFrequency
                                            .isNotEmpty &&
                                        widget.profile.workoutFrequency !=
                                            'Not specified')
                                      _IconBasicChip(
                                        icon: Icons.fitness_center,
                                        label: widget.profile.workoutFrequency,
                                        iconColor: Colors.green[700],
                                      ),
                                    // Location
                                    if (widget.profile.locationString
                                            .isNotEmpty &&
                                        widget.profile.locationString !=
                                            'Not specified')
                                      _IconBasicChip(
                                        icon: Icons.location_on,
                                        label: widget.profile.locationString,
                                        iconColor: Colors.red[600],
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (widget.profile.additionalImages.isNotEmpty)
                          const Divider(height: 1),

                        //
                        // PROFESSION
                        //
                        if (widget.profile.profession.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profession',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.profile.profession
                                      .map(
                                        (prof) => _BasicChip(label: prof),
                                      )
                                      .toList(),
                                ),
                              ],
                            ),
                          ),

                        if (widget.profile.profession.isNotEmpty)
                          const Divider(height: 1),

                        //
                        // THIRD IMAGE
                        //
                        if (widget.profile.additionalImages.length > 2)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AppNetworkImage(
                                  url: widget.profile.additionalImages[2],
                                ),
                              ),
                            ),
                          ),
                        if (widget.profile.additionalImages.length > 2)
                          const Divider(height: 1),
                        //
                        // EDUCATION (MORE DETAILS)
                        //
                        if (widget.profile.moreEducation.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Education',
                                  style: getTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: widget.profile.moreEducation
                                      .map((edu) => _BasicChip(label: edu))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        //
                        // LAST IMAGE
                        if (widget.profile.additionalImages.length > 3)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: AppNetworkImage(
                                  url: widget.profile.additionalImages[3],
                                ),
                              ),
                            ),
                          ),

                        // if (widget.profile.additionalImages.length > 3)
                        //   const Divider(height: 1),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),

              //
              // Loading indicator when loading more
              //
              if (widget.isLoadingMore)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Loading more...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // loading-more chip stays above; swipe indicators moved to ValueListenableBuilder
            ],
          ),
    );
  }
}

class _PhotoNavButton extends StatelessWidget {
  const _PhotoNavButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 26, color: Colors.black87),
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;

  const _InterestChip({required this.label});

  // String _getEmoji(String label) {
  //   switch (label.toLowerCase()) {
  //     case 'dogs':
  //       return '🐕';
  //     case 'music':
  //       return '🎵';
  //     case 'photography':
  //       return '📷';
  //     case 'shopping':
  //       return '🛍️';
  //     case 'movies':
  //     case 'movie':
  //       return '🎬';
  //     case 'travel':
  //     case 'travelling':
  //       return '✈️';
  //     case 'coffee':
  //       return '☕';
  //     case 'reading':
  //       return '📚';
  //     case 'yoga':
  //       return '🧘';
  //     case 'gaming':
  //       return '🎮';
  //     case 'cooking':
  //       return '🍳';
  //     case 'dancing':
  //       return '💃';
  //     case 'sports':
  //       return '🏅';
  //     case 'art':
  //       return '🎨';
  //     case 'fitness':
  //       return '🏋️';
  //     case 'nature':
  //       return '🌿';
  //     case 'blogging':
  //       return '📝';
  //     default:
  //       return '✨';
  //   }
  // }
  // String _getEmoji(String label) {
  //   switch (label.toLowerCase()) {
  //     case 'dogs':
  //       return '🐕';
  //     case 'cats':
  //       return '🐈';
  //     case 'music':
  //       return '🎵';
  //     case 'singing':
  //       return '🎤';
  //     case 'rock music':
  //       return '🎸';
  //     case 'electronic music':
  //       return '🎧';
  //     case 'jazz':
  //       return '🎹';
  //     case 'soul music':
  //       return '🎷';
  //     case 'pop music':
  //       return '🎶';
  //     case 'k-pop':
  //       return '🎤';
  //     case 'hip hop':
  //       return '🎧';

  //     case 'movies':
  //       return '🎬';
  //     case 'netflix':
  //       return '🍿';
  //     case 'tv shows':
  //       return '📺';
  //     case 'horror movies':
  //       return '👻';
  //     case 'comedy':
  //       return '😂';
  //     case 'drama':
  //       return '🎭';
  //     case 'marvel':
  //       return '🦸';
  //     case 'harry potter':
  //       return '🧙';
  //     case 'anime':
  //       return '🇯🇵';

  //     case 'foodie':
  //       return '🍕';
  //     case 'street food':
  //       return '🍔';
  //     case 'ramen':
  //       return '🍜';
  //     case 'sushi':
  //       return '🍣';
  //     case 'biryani':
  //       return '🍛';
  //     case 'coffee':
  //       return '☕';
  //     case 'wine':
  //       return '🍷';
  //     case 'cocktails':
  //       return '🍹';
  //     case 'ice cream':
  //       return '🍦';

  //     case 'travel':
  //       return '✈️';
  //     case 'mountains':
  //       return '🏔️';
  //     case 'beach':
  //       return '🏖️';
  //     case 'road trips':
  //       return '🚗';
  //     case 'camping':
  //       return '🏕️';
  //     case 'hiking':
  //       return '🥾';
  //     case 'surfing':
  //       return '🏄';
  //     case 'rowing':
  //       return '🚣';

  //     case 'football':
  //       return '⚽';
  //     case 'basketball':
  //       return '🏀';
  //     case 'tennis':
  //       return '🎾';
  //     case 'cricket':
  //       return '🏏';
  //     case 'gaming':
  //       return '🎮';
  //     case 'playstation':
  //       return '🕹️';
  //     case 'board games':
  //       return '🎲';

  //     case 'photography':
  //       return '📷';
  //     case 'art':
  //       return '🎨';
  //     case 'writing':
  //       return '✍️';
  //     case 'blogging':
  //       return '📝';
  //     case 'content creation':
  //       return '🎥';
  //     case 'entrepreneurship':
  //       return '💼';

  //     case 'shopping':
  //       return '🛍️';
  //     case 'festivals':
  //       return '🎉';
  //     case 'nightlife':
  //       return '🍻';
  //     case 'stand-up comedy':
  //       return '🎤';

  //     case 'skincare':
  //       return '🧴';
  //     case 'self care':
  //       return '💆';
  //     case 'mental health':
  //       return '🧠';
  //     case 'self love':
  //       return '💖';

  //     case 'social media':
  //       return '📱';
  //     case 'instagram':
  //       return '📸';
  //     case 'youtube':
  //       return '🎥';
  //     case 'podcasts':
  //       return '🎧';

  //     default:
  //       return '✨';
  //   }
  // }
  String _getEmoji(String label) {
    switch (label.toLowerCase()) {
      // Movies & TV
      case 'animated movies':
        return '🎬';
      case 'crime shows':
        return '🕵️‍♂️';
      case 'drama shows':
        return '🎭';
      case 'fantasy movies':
        return '🧙‍♂️';
      case 'documentaries':
        return '🎥';
      case 'indie films':
        return '🎞️';
      case 'reality tv':
        return '📺';
      case 'rom-coms':
        return '💘';
      case 'sports shows':
        return '🏟️';
      case 'thriller films':
        return '😱';
      case 'k-drama shows':
        return '🇰🇷';
      case 'horror movies':
        return '👻';
      case 'bollywood':
        return '🎬';
      case 'movies':
        return '🎥';
      case 'sci-fi':
        return '👽';
      case 'anime':
        return '🍥';
      case 'comedy':
        return '😂';

      // Social causes
      case 'activism':
        return '✊';
      case 'mental health awareness':
        return '🧠';
      case 'voter rights':
        return '🗳️';
      case 'climate change':
        return '🌍';
      case 'lgbtqia+ rights':
        return '🏳️‍🌈';
      case 'feminism':
        return '♀️';
      case 'black lives matter':
        return '✊🏿';
      case 'inclusivity':
        return '🤝';
      case 'human rights':
        return '⚖️';
      case 'social development':
        return '🏘️';
      case 'volunteering':
        return '🙋‍♂️';
      case 'environmentalism':
        return '🌱';
      case 'world peace':
        return '🕊️';
      case 'pride':
        return '🏳️‍🌈';
      case 'youth empowerment':
        return '🚀';
      case 'equality':
        return '⚖️';
      case 'politics':
        return '🏛️';
      case 'disability rights':
        return '♿';

      // Wellness & Self care
      case 'self love':
        return '💖';
      case 'trying new things':
        return '🧪';
      case 'tarot':
        return '🔮';
      case 'spa':
        return '💆‍♀️';
      case 'self care':
        return '🛀';
      case 'self development':
        return '📈';
      case 'meditation':
        return '🧘';
      case 'skincare':
        return '🧴';
      case 'makeup':
        return '💄';
      case 'astrology':
        return '♈';
      case 'mindfulness':
        return '🧘‍♂️';
      case 'sauna':
        return '🔥';
      case 'active lifestyle':
        return '🏃‍♂️';
      case 'yoga':
        return '🧘‍♀️';

      // Creative
      case 'photography':
        return '📸';
      case 'writing':
        return '✍️';
      case 'literature':
        return '📚';
      case 'painting':
        return '🎨';
      case 'drawing':
        return '🖌️';
      case 'art':
        return '🎭';
      case 'blogging':
        return '📝';
      case 'singing':
        return '🎤';
      case 'musical writing':
        return '🎼';
      case 'musical instrument':
        return '🎹';
      case 'dancing':
        return '🕺';

      // Food
      case 'ramen':
        return '🍜';
      case 'sushi':
        return '🍣';
      case 'biryani':
        return '🍛';
      case 'street food':
        return '🍔';
      case 'ice cream':
        return '🍨';
      case 'coffee':
        return '☕';
      case 'tea':
        return '🍵';
      case 'korean food':
        return '🍱';
      case 'plant-based':
        return '🥗';
      case 'foodie':
        return '🍽️';

      // Tech & Gaming
      case 'gaming':
        return '🎮';
      case 'playstation':
        return '🕹️';
      case 'xbox':
        return '🎮';
      case 'online games':
        return '👾';
      case 'trivia':
        return '🧠';
      case 'ludo':
        return '🎲';

      // Travel & Outdoor
      case 'camping':
        return '🏕️';
      case 'hiking':
        return '🥾';
      case 'beach':
        return '🏖️';
      case 'mountains':
        return '🌄';
      case 'travel':
        return '✈️';
      case 'nature':
        return '🌿';
      case 'road trips':
        return '🚗';

      // Fitness & Sports
      case 'gym':
        return '🏋️‍♂️';
      case 'running':
        return '🏃';
      case 'football':
        return '⚽';
      case 'basketball':
        return '🏀';
      case 'badminton':
        return '🏸';
      case 'swimming':
        return '🏊‍♂️';
      case 'cycling':
        return '🚴‍♂️';

      default:
        return '✨';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_getEmoji(label), style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(label, style: getTextStyle(fontSize: 13, color: Colors.black)),
        ],
      ),
    );
  }
}

//
// Language Chip
//

class _LanguageChip extends StatelessWidget {
  final String label;

  const _LanguageChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.language, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Text(label, style: getTextStyle(fontSize: 13, color: Colors.black)),
        ],
      ),
    );
  }
}

//
// Basic Chip
//

class _BasicChip extends StatelessWidget {
  final String label;

  const _BasicChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: getTextStyle(fontSize: 13, color: Colors.black),
      ),
    );
  }
}

class _IconBasicChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _IconBasicChip({
    required this.icon,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor ?? Colors.grey[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: getTextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
