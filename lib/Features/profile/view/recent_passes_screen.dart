import 'dart:ui';
import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/profile/model/passed_profile_model.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_edit_subpage_shell.dart';
import 'package:everqpidapp/Features/profile/view/desktop/desktop_recent_passes_view.dart';
import 'package:everqpidapp/Features/profile/view_model/recent_pass_view_model.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_bottom_sheet.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class RecentPassesScreen extends StatefulWidget {
  const RecentPassesScreen({super.key});

  @override
  State<RecentPassesScreen> createState() => _RecentPassesScreenState();
}

class _RecentPassesScreenState extends State<RecentPassesScreen> {
  /// Spec: desktop web layout from 900px; below keeps existing mobile UI.
  static const double _webMinWidth = 900;

  void _showSubscribeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Subscribe to Premium'),
        content: const Text(
          'Subscribe to see profiles you passed and get a second chance!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: getTextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              showSubscriptionBottomSheet(context: context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Subscribe',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<RecentPassViewModel>();
      vm.reset(); // 🔥 IMPORTANT
      vm.loadRecentPasses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < _webMinWidth) {
          return _buildMobile(context);
        }
        return DesktopEditSubpageShell(
          initiallyCollapsed: constraints.maxWidth < Breakpoints.tabletMax,
          child: DesktopRecentPassesView(
            onShowSubscribe: _showSubscribeDialog,
          ),
        );
      },
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        title: Text(
          'Back',
          style: getTextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: AppContentFrame(
        maxWidth: ContentMaxWidth.shell,
        child: Consumer<RecentPassViewModel>(
          builder: (context, vm, __) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Passes',
                            style: getTextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Changed your mind? Take another look at\nrecent passes.',
                            style: getTextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Grid of passed profiles
                    Expanded(
                      child: Builder(
                        builder: (_) {
                          if (vm.isLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return vm.passedUsers.isEmpty
                              ? Center(
                                  child: Text(
                                    'No passed users yet!',
                                    style: getTextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  cacheExtent: 400,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: profileGridColumns(context),
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.7,
                                  ),
                                  itemCount: vm.passedUsers.length,
                                  itemBuilder: (_, index) {
                                    final user = vm.passedUsers[index];
                                    return _PassedProfileCard(
                                      shouldBlur: !vm.isSubscribed,
                                      profile: PassedProfile(
                                        name: user.fullName,
                                        age: user.age,
                                        education: user.education ?? '',
                                        imageUrl: user.profileImageUrl,
                                        isVerified: user.isVerified,
                                      ),
                                      onTap: () {
                                        if (!vm.isSubscribed) {
                                          _showSubscribeDialog();
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileDetailScreen(
                                                profileTitle: 'passed',
                                                profile: user,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                );
                        },
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),

                // Subscribe button overlay (only if not subscribed)
                if (!vm.isSubscribed && vm.passedUsers.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 40,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: _showSubscribeDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PColors.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: PColors.primaryColor.withOpacity(0.4),
                        ),
                        child: Text(
                          'Subscribe',
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============= PASSED PROFILE CARD =============
class _PassedProfileCard extends StatelessWidget {
  final PassedProfile profile;
  final bool shouldBlur;
  final VoidCallback onTap;

  const _PassedProfileCard({
    required this.profile,
    required this.shouldBlur,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: AppNetworkImage(
                  url: profile.imageUrl,
                  memCacheWidth: 600,
                ),
              ),

              // Blur effect using BackdropFilter
              if (shouldBlur)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.black.withOpacity(0.1)),
                    ),
                  ),
                ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Profile info
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
                            '${profile.name}, ${profile.age}',
                            style: getTextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified)
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.school, color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 100,
                          child: Text(
                            profile.education,
                            style: getTextStyle(
                              fontSize: 12,
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
            ],
          ),
        ),
      ),
    );
  }
}
