// lib/features/matches/view/matches_screen.dart

import 'dart:ui';
import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/matches/view/desktop/desktop_matches_view.dart';
import 'package:everqpidapp/Features/matches/view_model/likes_view_model.dart';
import 'package:everqpidapp/Features/matches/view_model/matches_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/responsive/responsive_builder.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/features/matches/model/match_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final matchesVM = context.read<MatchesViewModel>();
      final likesVM = context.read<LikesViewModel>();

      if (matchesVM.matches.isEmpty && !matchesVM.isLoading) {
        matchesVM.fetchMatches();
      }

      // Defer likes — IndexedStack mounts this tab at startup alongside Discover /
      // Messages; racing get-received-likes often connectionTimeouts on web.
      if (likesVM.receivedLikes.isEmpty && !likesVM.isLoading) {
        Future<void>.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          final vm = context.read<LikesViewModel>();
          if (vm.receivedLikes.isEmpty && !vm.isLoading) {
            vm.fetchReceivedLikes();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ResponsiveBuilder(
      mobile: (_) => _MobileMatchesBody(tabController: _tabController),
      tablet: (_) => const DesktopMatchesView(),
      desktop: (_) => const DesktopMatchesView(),
    );
  }
}

/// Original mobile Matches UI — unchanged presentation.
class _MobileMatchesBody extends StatelessWidget {
  const _MobileMatchesBody({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AppContentFrame(
          maxWidth: ContentMaxWidth.shell,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Text(
                  'Match for you',
                  style: getTextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              _buildTabsUI(context),
              const SizedBox(height: 20),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [_buildMatchesTab(), _buildLikesTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabsUI(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: getTextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        unselectedLabelStyle: getTextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          _tabLabel('Matches', tabController.index == 0),
          _tabLabel('Likes', tabController.index == 1),
        ],
      ),
    );
  }

  Widget _tabLabel(String text, bool active) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text),
          if (active) ...[
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchesTab() {
    return Consumer<MatchesViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vm.errorMessage!,
                  style: getTextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => vm.refreshMatches(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        if (vm.matches.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No matches yet ❤️',
                  style: getTextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep swiping to find your match! or Retry!',
                  style: getTextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),
                IconButton(
                  icon: Icon(Icons.refresh, size: 40, color: Colors.grey[400]),
                  onPressed: () => vm.refreshMatches(),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => vm.refreshMatches(),
          child: Stack(
            children: [
              GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                cacheExtent: 400,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: profileGridColumns(context),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.7,
                ),
                itemCount: vm.matches.length + (vm.hasNext ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == vm.matches.length) {
                    if (vm.isLoadingMore) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        vm.loadMoreMatches();
                      });
                      return const SizedBox.shrink();
                    }
                  }

                  final profile = vm.matches[index];

                  return RepaintBoundary(
                    child: _MatchCard(
                      profile: MatchProfile(
                        name: profile.fullName,
                        age: profile.age,
                        education: profile.education ?? '',
                        imageUrl: profile.profileImageUrl ?? '',
                        isVerified: profile.isVerified,
                      ),
                      shouldBlur: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileDetailScreen(
                              profile: profile,
                              profileTitle: 'matches',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLikesTab() {
    return Consumer<LikesViewModel>(
      builder: (context, vm, child) {
        if (vm.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (vm.statusCode == 400 && vm.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No one liked you yet 😢',
                  style: getTextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "Don't worry, your perfect match is coming!",
                  style: getTextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        if (vm.receivedLikes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No one liked you yet 😢',
                  style: getTextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  "Don't worry, your perfect match is coming!",
                  style: getTextStyle(fontSize: 14, color: Colors.grey[400]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => vm.fetchReceivedLikes(isRefresh: true),
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo is ScrollEndNotification &&
                      scrollInfo.metrics.extentAfter < 200 &&
                      vm.hasNext &&
                      !vm.isLoadingMore &&
                      !vm.isLoading) {
                    vm.loadMoreLikes();
                  }
                  return false;
                },
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  cacheExtent: 400,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: profileGridColumns(context),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount:
                      vm.receivedLikes.length + (vm.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == vm.receivedLikes.length && vm.isLoadingMore) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final profile = vm.receivedLikes[index];

                    return RepaintBoundary(
                      child: _MatchCard(
                        profile: MatchProfile(
                          name: profile.fullName,
                          age: profile.age,
                          education: profile.education ?? '',
                          imageUrl: profile.profileImageUrl,
                          isVerified: profile.isVerified,
                        ),
                        shouldBlur: false,
                        showHeartIcon: true,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfileDetailScreen(
                                profile: profile,
                                profileTitle: 'likes',
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchProfile profile;
  final bool shouldBlur;
  final bool showHeartIcon;
  final VoidCallback onTap;

  const _MatchCard({
    required this.profile,
    required this.shouldBlur,
    this.showHeartIcon = false,
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
              Positioned.fill(
                child: AppNetworkImage(
                  url: profile.imageUrl,
                  memCacheWidth: 600,
                  errorIconSize: 60,
                ),
              ),
              if (shouldBlur)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.black.withOpacity(0.1)),
                  ),
                ),
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
                    ),
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
                        Expanded(
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
              if (showHeartIcon && shouldBlur)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: PColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
