// features/clan/view/clan_home_screen.dart

import 'dart:ui';
import 'package:everqpidapp/Features/clan2.0/model/clan_profile_model.dart';
import 'package:everqpidapp/Features/clan2.0/view/clan_list_screen.dart';
import 'package:everqpidapp/Features/clan2.0/view_model/clan_view_model.dart';
import 'package:everqpidapp/Features/clan2.0/widgets/city_selector_bottom_sheet.dart';
import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_bottom_sheet.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class ClanHomeScreen extends StatelessWidget {
  final String userId;

  const ClanHomeScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<ClanViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Clan',
                              style: getTextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            // Clickable location selector
                            GestureDetector(
                              onTap: () {
                                showOfflineCitySelector(
                                  context: context,
                                  currentCity: viewModel.selectedCity,
                                  currentState: viewModel.selectedState,
                                  currentCountry: viewModel.selectedCountry,
                                  onLocationSelected: (location) {
                                    viewModel.updateSelectedLocation(
                                      city: location.city,
                                      state: location.state,
                                      country: location.country,
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: PColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: PColors.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: PColors.primaryColor,
                                    ),
                                    const SizedBox(width: 4),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 150,
                                      ),
                                      child: Text(
                                        viewModel.locationDisplayName,
                                        style: getTextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: PColors.primaryColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 18,
                                      color: PColors.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Clan Cards
                        Row(
                          children: [
                            Expanded(
                              child: _ClanCard(
                                title: 'Home Clan',
                                color: const Color(0xFF4CAF50),
                                clanType: 'home',
                                photos: viewModel.getClanPhotos('home'),
                                onTap: () => _navigateToClanList(
                                  context,
                                  'home',
                                  userId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ClanCard(
                                title: 'Work Clan',
                                color: const Color(0xFFE53935),
                                clanType: 'work',
                                photos: viewModel.getClanPhotos('work'),
                                onTap: () => _navigateToClanList(
                                  context,
                                  'work',
                                  userId,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _ClanCard(
                                title: 'Study Clan',
                                color: const Color(0xFF1E88E5),
                                clanType: 'study',
                                photos: viewModel.getClanPhotos('study'),
                                onTap: () => _navigateToClanList(
                                  context,
                                  'study',
                                  userId,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ClanCard(
                                title: 'Quest Clan',
                                color: const Color(0xFF9C27B0),
                                clanType: 'quest',
                                photos: viewModel.getClanPhotos('quest'),
                                onTap: () => _navigateToClanList(
                                  context,
                                  'quest',
                                  userId,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Most Active Members
                        const Text(
                          'Most active members',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 240,
                          child: viewModel.mostActiveProfiles.isEmpty
                              ? Center(
                                  child: Text(
                                    'No active members yet',
                                    style: getTextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  cacheExtent: 300,
                                  itemCount:
                                      viewModel.mostActiveProfiles.length,
                                  itemBuilder: (context, index) {
                                    final profile =
                                        viewModel.mostActiveProfiles[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: RepaintBoundary(
                                        child: _ActiveMemberCard(
                                          isSubscribed: viewModel.isSubscribed,
                                          profile: profile,
                                          ontap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileDetailScreen(
                                                  profileTitle: 'clan',
                                                  profile: profile,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Subscribe button
                if (!viewModel.isSubscribed &&
                    viewModel.mostActiveProfiles.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          showSubscriptionBottomSheet(context: context);
                        },
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

  void _navigateToClanList(
    BuildContext context,
    String clanType,
    String userId,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClanListScreen(clanType: clanType, userId: userId),
      ),
    );
  }
}

class _ClanCard extends StatelessWidget {
  final String title;
  final Color color;
  final String clanType;
  final List<dynamic> photos;
  final VoidCallback onTap;

  const _ClanCard({
    required this.title,
    required this.color,
    required this.clanType,
    required this.photos,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayPhotos = photos.take(3).toList();
    final remainingCount = photos.length > 3 ? photos.length - 3 : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (displayPhotos.isNotEmpty)
              SizedBox(
                height: 60,
                child: Stack(
                  children: [
                    for (int i = 0; i < displayPhotos.length; i++)
                      Positioned(
                        left: i * 30.0,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: displayPhotos[i].profileImageUrl != null
                                ? DecorationImage(
                                    image: AppNetworkImage.provider(
                                      displayPhotos[i].profileImageUrl!,
                                      memCacheWidth: 120,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: displayPhotos[i].profileImageUrl == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (remainingCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '+$remainingCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
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

class _ActiveMemberCard extends StatelessWidget {
  final ClanProfile profile;
  final VoidCallback? ontap;
  final bool isSubscribed;

  const _ActiveMemberCard({
    required this.profile,
    this.ontap,
    required this.isSubscribed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubscribed ? ontap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: profile.profileImageUrl != null
                    ? AppNetworkImage(
                        url: profile.profileImageUrl!,
                        memCacheWidth: 400,
                      )
                    : const Center(child: Icon(Icons.person, size: 48)),
              ),
              if (!isSubscribed)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(color: Colors.black.withOpacity(0.15)),
                    ),
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
                            '${profile.fullName}, ${profile.age}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified)
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: PColors.primaryColor,
                          ),
                      ],
                    ),
                    if (profile.currentProfession.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.school,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              profile.currentProfession,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
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
    );
  }
}
