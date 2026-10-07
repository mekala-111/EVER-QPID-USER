import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/common_widgets/base_profile.dart';
import 'package:everqpidapp/Features/common_widgets/icon_basic_chip.dart';
import 'package:everqpidapp/Features/home/view_model/home_view_model.dart';
import 'package:everqpidapp/Features/home/view_model/matching_view_model.dart';
import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/profileactions/view/profile_action_bottom_sheet.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_bottom_sheet.dart';
import 'package:everqpidapp/Features/superlikes/view/subscription_required_dialog.dart';
import 'package:everqpidapp/Features/superlikes/view_model/super_likes_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/utils/images.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String profileTitle;

  final BaseProfile profile;
  const ProfileDetailScreen({
    super.key,
    required this.profile,
    required this.profileTitle,
  });

  @override
  Widget build(BuildContext context) {
    // final viewModel = Provider.of<MatchingViewModel>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
            MainScreenBridge.navigateToTab(1);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune, size: 28),
            onPressed: () {
              // TODO: open filter screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Profile card with loading and error states
            Expanded(
              child: Consumer<MatchingViewModel>(
                builder: (context, viewModel, child) {
                  // Loading state
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Empty state
                  if (viewModel.isLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No profiles found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new matches',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Show profiles

                  return SwipeableProfileCard(
                    profileTitle: profileTitle,
                    profile: profile,
                    onSwipeLeft: () =>
                        viewModel.sendUnlike(profile.id, context),
                    onSwipeRight: () => viewModel.sendLike(profile.id),
                    // isLoadingMore:alse, context),
                    // onSwipeRight: () => viewModel.onSwipe(true, context),
                    // isLoadingMore: viewModel.isLoadingMore,
                  );
                },
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
  final BaseProfile profile;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool isLoadingMore;
  final String profileTitle;

  const SwipeableProfileCard({
    super.key,
    required this.profile,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.profileTitle,
    this.isLoadingMore = false,
  });

  @override
  State<SwipeableProfileCard> createState() => _SwipeableProfileCardState();
}

class _SwipeableProfileCardState extends State<SwipeableProfileCard>
    with SingleTickerProviderStateMixin {
  Future<void> _handleSuperLike() async {
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

      // Move to next profile
      widget.onSwipeRight();
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

  @override
  Widget build(BuildContext context) {
    // final rotation = _dragPosition.dx / 1000;
    // final opacity = 1 - (_dragPosition.dx.abs() / 200).clamp(0.0, 0.6);

    return GestureDetector(
      // onPanStart: _onDragStart,
      // onPanUpdate: _onDragUpdate,
      // onPanEnd: _onDragEnd,
      child: Padding(
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
                  physics:
                      // ? const NeverScrollableScrollPhysics()
                      const BouncingScrollPhysics(),
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
                            AppNetworkImage(
                              url: widget.profile.profileImageUrl ?? '',
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
                                          .id, // Make sure your UserProfile model has id field
                                      userName: widget.profile.fullName,
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
                                    borderRadius: BorderRadius.circular(20),
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
                                                '${widget.profile.fullName}, ${widget.profile.age}',
                                                style: getTextStyle(
                                                  fontSize: 32,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (widget.profile.isVerified) ...[
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
                                                widget.profile.education ?? "",
                                                style: getTextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Selector<SuperLikesViewModel, bool>(
                                    selector: (_, vm) => vm.isSendingSuperLike,
                                    builder: (context, isLoading, _) {
                                      return GestureDetector(
                                        onTap:
                                            isLoading ? null : _handleSuperLike,
                                        child: Container(
                                          padding: const EdgeInsets.all(12),
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
                                                offset: const Offset(0, 4),
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
                      if (widget.profile.interests!.isNotEmpty)
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
                                children: widget.profile.interests!
                                    .map(
                                      (interest) =>
                                          _InterestChip(label: interest),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),

                      if (widget.profile.interests!.isNotEmpty)
                        const Divider(height: 1),

                      //
                      // LANGUAGES
                      //
                      if (widget.profile.otherLanguages!.isNotEmpty)
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
                                children: widget.profile.otherLanguages!
                                    .map((lang) => _LanguageChip(label: lang))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),

                      if (widget.profile.otherLanguages!.isNotEmpty)
                        const Divider(height: 1),

                      //
                      // SECONF IMAGE
                      //
                      if (widget.profile.profilePhotos!.length > 1)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AppNetworkImage(
                                url: widget.profile.profilePhotos![1],
                              ),
                            ),
                          ),
                        ),

                      if (widget.profile.profilePhotos!.length > 1)
                        const Divider(height: 1),
                      //
                      // BIO
                      //
                      if (widget.profile.aboutMe != null)
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
                                widget.profile.aboutMe!,
                                style: getTextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (widget.profile.aboutMe!.isNotEmpty)
                        const Divider(height: 1),
                      if (widget.profile.relationshipStatus!.isNotEmpty ||
                          widget.profile.height != null ||
                          widget.profile.religion!.isNotEmpty ||
                          widget.profile.locationString!.isNotEmpty) ...[
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
                                  if (widget.profile.relationshipStatus!
                                          .isNotEmpty &&
                                      widget.profile.relationshipStatus !=
                                          'Not specified')
                                    IconBasicChip(
                                      icon: Icons.people,
                                      label:
                                          widget.profile.relationshipStatus ??
                                              '',
                                      iconColor: PColors.primaryColor,
                                    ),

                                  // Height
                                  if (widget.profile.height != null &&
                                      widget.profile.height! > 0)
                                    IconBasicChip(
                                      icon: Icons.straighten,
                                      label: '${widget.profile.height} cm',
                                      iconColor: Colors.blue[700],
                                    ),

                                  // Religion
                                  if (widget.profile.religion!.isNotEmpty &&
                                      widget.profile.religion !=
                                          'Not specified' &&
                                      widget.profile.religion !=
                                          'Prefer not to say')
                                    IconBasicChip(
                                      icon: Icons.auto_awesome,
                                      label: widget.profile.religion ?? '',
                                      iconColor: Colors.orange[700],
                                    ),
                                  // Zodiac Sign
                                  if (widget.profile.zodiacSign!.isNotEmpty &&
                                      widget.profile.zodiacSign !=
                                          'Not specified')
                                    IconBasicChip(
                                      icon: Icons.star,
                                      label: widget.profile.zodiacSign!,
                                      iconColor: Colors.pink[700],
                                    ),

                                  // Alcohol Consumption
                                  if (widget.profile.alcoholConsumption!
                                          .isNotEmpty &&
                                      widget.profile.alcoholConsumption !=
                                          'Not specified')
                                    IconBasicChip(
                                      icon: Icons.local_bar,
                                      label: widget.profile.alcoholConsumption!,
                                      iconColor: Colors.purple[700],
                                    ),
                                  // Smoking Habits
                                  if (widget.profile.smokingHabit!.isNotEmpty &&
                                      widget.profile.smokingHabit !=
                                          'Not specified')
                                    IconBasicChip(
                                      icon: Icons.smoking_rooms_rounded,
                                      label: widget.profile.smokingHabit!,
                                      iconColor: Colors.brown[700],
                                    ),
                                  // Workout Frequency
                                  if (widget.profile.workoutFrequency!
                                          .isNotEmpty &&
                                      widget.profile.workoutFrequency !=
                                          'Not specified')
                                    IconBasicChip(
                                      icon: Icons.fitness_center,
                                      label: widget.profile.workoutFrequency!,
                                      iconColor: Colors.green[700],
                                    ),
                                  // Location
                                  if (widget
                                          .profile.locationString!.isNotEmpty &&
                                      widget.profile.locationString !=
                                          'Not specified')
                                    IconBasicChip(
                                      icon: Icons.location_on,
                                      label:
                                          widget.profile.locationString ?? '',
                                      iconColor: Colors.red[600],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (widget.profile.profilePhotos!.isNotEmpty)
                        const Divider(height: 1),

                      //
                      // PROFESSION
                      //
                      if (widget.profile.currentProfession!.isNotEmpty)
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
                                children: [widget.profile.currentProfession!]
                                    .map((prof) => _BasicChip(label: prof))
                                    .toList(),
                              ),
                            ],
                          ),
                        ),

                      if (widget.profile.currentProfession!.isNotEmpty)
                        const Divider(height: 1),

                      //
                      // THIRD IMAGE
                      //
                      if (widget.profile.profilePhotos!.length > 2)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AppNetworkImage(
                                url: widget.profile.profilePhotos![2],
                              ),
                            ),
                          ),
                        ),
                      if (widget.profile.profilePhotos!.length > 2)
                        const Divider(height: 1),
                      //
                      // EDUCATION (MORE DETAILS)
                      //
                      if (widget.profile.education!.isNotEmpty)
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
                                children: [
                                  widget.profile.education!,
                                ].map((edu) => _BasicChip(label: edu)).toList(),
                              ),
                            ],
                          ),
                        ),
                      //
                      // LAST IMAGE
                      if (widget.profile.profilePhotos!.length > 3)
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: AppNetworkImage(
                                url: widget.profile.profilePhotos![3],
                              ),
                            ),
                          ),
                        ),
                      widget.profileTitle != 'passed'
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ActionButton(
                                  icon: Icons.close,
                                  color: Colors.red,
                                  onTap: () async {
                                    final Map<String, dynamic> result =
                                        await context
                                            .read<MatchingViewModel>()
                                            .sendUnlike(
                                              widget.profile.id,
                                              context,
                                            );
                                    if (result["status"] == true) {
                                      Fluttertoast.showToast(
                                        msg: result["message"] ??
                                            'Unliked successfully',
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: result["message"] ??
                                            'Error unliking',
                                        backgroundColor: Colors.red,
                                      );
                                    }
                                  },
                                ),
                                const SizedBox(width: 20),

                                // _ActionButton(
                                //   icon: Icons.star,
                                //   color: Colors.amber,

                                //   onTap: () {
                                //     context.read<SuperLikesViewModel>().sendSuperLike(
                                //       userId: LoggedInUser.id!,
                                //       toUserId: widget.profile.id,
                                //     );
                                //   },
                                // ),
                                const SizedBox(width: 20),
                                _ActionButton(
                                  icon: Icons.favorite,
                                  color: Colors.green,
                                  onTap: () async {
                                    final Map<String, dynamic> result =
                                        await context
                                            .read<MatchingViewModel>()
                                            .sendLike(widget.profile.id);
                                    if (result["status"] == true) {
                                      Fluttertoast.showToast(
                                        msg: result["message"] ??
                                            'Unliked successfully',
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: result["message"] ??
                                            'Error unliking',
                                        backgroundColor: Colors.red,
                                      );
                                    }
                                  },
                                ),
                              ],
                            )
                          : Center(
                              child: _ActionButton(
                                icon: Icons.favorite,
                                color: Colors.green,
                                onTap: () async {
                                  final Map<String, dynamic> result =
                                      await context
                                          .read<MatchingViewModel>()
                                          .sendLike(widget.profile.id);
                                  if (result["status"] == true) {
                                    Fluttertoast.showToast(
                                      msg: result["message"] ??
                                          'Unliked successfully',
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                      msg:
                                          result["message"] ?? 'Error unliking',
                                      backgroundColor: Colors.red,
                                    );
                                  }
                                },
                              ),
                            ),

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
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            //
            // SWIPE INDICATORS
            //
            // if (_isDragging && _dragPosition.dx > 50)
            //   Positioned(
            //     top: 50,
            //     left: 50,
            //     child: Transform.rotate(
            //       angle: -0.3,
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 20,
            //           vertical: 10,
            //         ),
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Colors.green, width: 4),
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         child: Text(
            //           'LIKE',
            //           style: getTextStyle(
            //             fontSize: 32,
            //             fontWeight: FontWeight.w900,
            //             color: Colors.green,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),

            // if (_isDragging && _dragPosition.dx < -50)
            //   Positioned(
            //     top: 50,
            //     right: 50,
            //     child: Transform.rotate(
            //       angle: 0.3,
            //       child: Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 20,
            //           vertical: 10,
            //         ),
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Colors.red, width: 4),
            //           borderRadius: BorderRadius.circular(8),
            //         ),
            //         child: Text(
            //           'NOPE',
            //           style: getTextStyle(
            //             fontSize: 32,
            //             fontWeight: FontWeight.w900,
            //             color: Colors.red,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label;

  const _InterestChip({required this.label});

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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 30, color: color),
      ),
    );
  }
}
