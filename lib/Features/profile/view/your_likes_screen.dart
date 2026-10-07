import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/profile/model/liked_profile_model.dart';
import 'package:everqpidapp/Features/profile/view_model/liked_profile_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class YourLikesScreen extends StatefulWidget {
  const YourLikesScreen({super.key});

  @override
  State<YourLikesScreen> createState() => _YourLikesScreenState();
}

class _YourLikesScreenState extends State<YourLikesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LikedProfilesViewModel>().fetchLikedProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: AppContentFrame(
        maxWidth: ContentMaxWidth.shell,
        child: Consumer<LikedProfilesViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (vm.errorMessage != null) {
              return Center(
                child: Text(
                  vm.errorMessage!,
                  style: getTextStyle(fontSize: 14, color: Colors.red),
                ),
              );
            }

            if (vm.likedProfiles.isEmpty) {
              return Center(
                child: Text(
                  "You haven’t liked anyone yet!",
                  style: getTextStyle(fontSize: 16, color: Colors.grey),
                ),
              );
            }

            return _buildGrid(vm.likedProfiles);
          },
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "Back",
        style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildGrid(List<LikedProfileData> profiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(
          child: GridView.builder(
            cacheExtent: 400,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: profileGridColumns(context),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.7,
            ),
            itemCount: profiles.length,
            itemBuilder: (_, index) {
              final p = profiles[index];
              return _LikedProfileCard(
                profile: p,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileDetailScreen(
                        profile: p,
                        profileTitle: 'likes',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Text(
            "Your Likes",
            style: getTextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Revisit the profiles you have shown interests.",
            style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _LikedProfileCard extends StatelessWidget {
  final LikedProfileData profile;
  final VoidCallback onTap;

  const _LikedProfileCard({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: AppNetworkImage(
                url: profile.profileImageUrl,
                memCacheWidth: 600,
              ),
            ),
            _buildGradient(),
            _buildInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildGradient() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${profile.fullName}, ${profile.age}",
            style: getTextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            profile.education ?? "",
            style: getTextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
