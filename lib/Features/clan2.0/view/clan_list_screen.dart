import 'dart:ui';
import 'package:everqpidapp/Features/clan2.0/model/clan_profile_model.dart';
import 'package:everqpidapp/Features/clan2.0/view_model/clan_view_model.dart';
import 'package:everqpidapp/Features/clan2.0/widgets/city_selector_bottom_sheet.dart';
import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_bottom_sheet.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/breakpoints.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';

class ClanListScreen extends StatefulWidget {
  final String clanType;
  final String userId;

  const ClanListScreen({
    super.key,
    required this.clanType,
    required this.userId,
  });

  @override
  State<ClanListScreen> createState() => _ClanListScreenState();
}

class _ClanListScreenState extends State<ClanListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<ClanViewModel>();
      viewModel.prepareProfilesSearch(widget.clanType);
      viewModel.searchClanProfiles(widget.clanType);
    });
  }

  String get _clanTitle {
    switch (widget.clanType) {
      case 'home':
        return 'Home Clan';
      case 'work':
        return 'Work Clan';
      case 'study':
        return 'Study Clan';
      case 'quest':
        return 'Quest Clan';
      default:
        return 'Clan';
    }
  }

  String get _clanSubtitle {
    switch (widget.clanType) {
      case 'home':
        return 'Permanent residents of this area.';
      case 'work':
        return 'Professionals working in this area.';
      case 'study':
        return 'Students studying in this area.';
      case 'quest':
        return 'Travelers exploring this area.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            context.read<ClanViewModel>().clearSelectedClan();
            Navigator.pop(context);
          },
        ),
        centerTitle: false,
        title: Text(
          'Back',
          style: getTextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: [
          Selector<ClanViewModel, String>(
            selector: (_, vm) => vm.locationDisplayName,
            builder: (context, locationDisplayName, _) {
              final viewModel = context.read<ClanViewModel>();
              return GestureDetector(
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
                  margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: PColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PColors.primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: PColors.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: Text(
                          locationDisplayName,
                          style: getTextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: PColors.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: PColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ClanViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      viewModel.errorMessage ?? 'An error occurred',
                      textAlign: TextAlign.center,
                      style:
                          getTextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PColors.primaryColor,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No members in ${viewModel.selectedCity ?? "this city"} yet',
                    style: getTextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try selecting a different city',
                    style: getTextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _clanTitle,
                              style: getTextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _clanSubtitle,
                              style: getTextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey[600]!,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_city,
                                  size: 16,
                                  color: PColors.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    viewModel.fullLocationName,
                                    style: getTextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${viewModel.profiles.length} members found',
                              style: getTextStyle(
                                fontSize: 14,
                                color: PColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: profileGridColumns(context),
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= viewModel.profiles.length) {
                              return null;
                            }
                            return _ProfileCard(
                              profile: viewModel.profiles[index],
                              index: index,
                              isSubscribed: viewModel.isSubscribed,
                              ontap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileDetailScreen(
                                    profileTitle: 'clan',
                                    profile: viewModel.profiles[index],
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: viewModel.profiles.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
                ),
                if (!viewModel.isSubscribed && viewModel.profiles.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 40,
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
            ),
          );
        },
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ClanProfile profile;
  final int index;
  final VoidCallback? ontap;
  final bool isSubscribed;

  const _ProfileCard({
    required this.profile,
    required this.index,
    this.ontap,
    required this.isSubscribed,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = profile.profilePhotos.isNotEmpty
        ? profile.profilePhotos.first
        : profile.profileImageUrl;

    return GestureDetector(
      onTap: isSubscribed ? ontap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[300],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: imageUrl != null
                    ? AppNetworkImage(url: imageUrl, memCacheWidth: 500)
                    : const Center(child: Icon(Icons.person, size: 48)),
              ),
              if (!isSubscribed)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(color: Colors.black.withOpacity(0.15)),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified)
                          Icon(
                            Icons.verified,
                            size: 18,
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
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              profile.currentProfession,
                              style: const TextStyle(
                                fontSize: 12,
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
