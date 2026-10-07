import 'package:everqpidapp/Features/profile/view/profile_actions.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/app_network_image.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:everqpidapp/Settings/responsive/app_content_frame.dart';
import 'package:everqpidapp/Settings/responsive/content_max_width.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:everqpidapp/config/config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Existing mobile Profile UI — do not restyle for desktop.
class MobileProfileView extends StatelessWidget {
  const MobileProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AppContentFrame(
          maxWidth: ContentMaxWidth.form,
          child: Consumer<GetProfileViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (vm.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(vm.errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: vm.fetchProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final profile = vm.profile;

              if (profile == null) {
                return const Center(child: Text('No profile data found'));
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                      child: Text(
                        'Profile',
                        style: getTextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: AppNetworkImage.provider(
                              profile.profileImageUrl ??
                                  AppConfig.placeholderImageUrl,
                              memCacheWidth: 160,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.fullName,
                                  style: getTextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.email.isEmpty
                                      ? '${profile.countryCode ?? ''} ${profile.phoneNumber}'
                                      : profile.email,
                                  style: getTextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () =>
                                      ProfileActions.openVerify(context, profile),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: profile.isVerified
                                          ? PColors.primaryColor
                                              .withOpacity(0.1)
                                          : Colors.orange[50],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: profile.isVerified
                                            ? PColors.primaryColor
                                            : Colors.orange,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          profile.isVerified
                                              ? Icons.verified
                                              : Icons.shield_outlined,
                                          color: profile.isVerified
                                              ? PColors.primaryColor
                                              : Colors.orange,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          profile.isVerified
                                              ? 'Verified'
                                              : 'Verify Now',
                                          style: getTextStyle(
                                            fontSize: 13,
                                            color: profile.isVerified
                                                ? PColors.primaryColor
                                                : Colors.orange,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'General',
                        style: getTextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      onTap: () => ProfileActions.openEditProfile(context),
                    ),
                    _MenuItem(
                      icon: Icons.tune,
                      title: 'Preferences',
                      onTap: () => ProfileActions.openPreferences(context),
                    ),
                    _MenuItem(
                      icon: Icons.workspace_premium_outlined,
                      title: 'Subscriptions',
                      onTap: () => ProfileActions.openSubscriptions(context),
                    ),
                    _MenuItem(
                      icon: Icons.favorite_border,
                      title: 'Your Likes',
                      onTap: () => ProfileActions.openYourLikes(context),
                    ),
                    _MenuItem(
                      icon: Icons.replay,
                      title: 'Recent Passes',
                      onTap: () => ProfileActions.openRecentPasses(context),
                    ),
                    _MenuItem(
                      icon: Icons.shield_outlined,
                      title: 'Safety Tips',
                      onTap: () => ProfileActions.openSafetyTips(context),
                    ),
                    _MenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => ProfileActions.openSettings(
                        context,
                        vm.profile?.id ?? '',
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: Colors.grey[700]),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: getTextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
