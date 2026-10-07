import 'package:everqpidapp/Features/onboarding/view/welcome/welcome_theme.dart';
import 'package:everqpidapp/Features/profile/view/profile_actions.dart';
import 'package:everqpidapp/Features/profile/view/widgets/profile_action_card.dart';
import 'package:everqpidapp/Features/profile/view/widgets/profile_summary_card.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Settings/constants/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Compact web profile for 768–1199 — no sidebar, no bottom-nav duplication.
class TabletProfileView extends StatelessWidget {
  const TabletProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090415),
      body: Consumer<GetProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading && vm.profile == null) {
            return const Center(
              child: CircularProgressIndicator(color: WelcomeTheme.violetLight),
            );
          }
          if (vm.errorMessage != null && vm.profile == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vm.errorMessage!,
                    style: getTextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: vm.fetchProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          final profile = vm.profile;
          if (profile == null) {
            return Center(
              child: Text(
                'No profile data found',
                style: getTextStyle(color: Colors.white70),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Profile',
                            style: getTextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.favorite_border_rounded,
                            color: WelcomeTheme.violetLight,
                            size: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Manage your account and preferences',
                        style: getTextStyle(
                          fontSize: 14,
                          color: const Color(0xFFB9B2C8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ProfileHeroCard(profile: profile),
                      const SizedBox(height: 20),
                      // Reuse desktop premium banner via DesktopProfileView structure
                      // by inlining a thin call — open premium from actions.
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => ProfileActions.openPremium(context),
                          icon: Icon(Icons.workspace_premium,
                              color: Colors.amber[300]),
                          label: const Text('Upgrade to Premium'),
                          style: FilledButton.styleFrom(
                            backgroundColor: WelcomeTheme.violet,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Profile Management',
                        style: getTextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ProfileActionCard(
                        icon: Icons.edit_outlined,
                        title: 'Edit Profile',
                        description: 'Update photos, bio and details',
                        onTap: () => ProfileActions.openEditProfile(context),
                      ),
                      const SizedBox(height: 12),
                      ProfileActionCard(
                        icon: Icons.tune,
                        title: 'Preferences',
                        description: 'Match preferences and filters',
                        onTap: () => ProfileActions.openPreferences(context),
                      ),
                      const SizedBox(height: 12),
                      ProfileActionCard(
                        icon: Icons.favorite_border,
                        title: 'Your Likes',
                        description: 'People who liked you',
                        onTap: () => ProfileActions.openYourLikes(context),
                      ),
                      const SizedBox(height: 12),
                      ProfileActionCard(
                        icon: Icons.replay,
                        title: 'Recent Passes',
                        description: "Profiles you've passed on",
                        onTap: () => ProfileActions.openRecentPasses(context),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Account & Safety',
                        style: getTextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ProfileActionCard(
                        icon: Icons.workspace_premium_outlined,
                        title: 'Subscriptions',
                        description: 'Manage subscription and payment',
                        onTap: () => ProfileActions.openSubscriptions(context),
                      ),
                      const SizedBox(height: 12),
                      ProfileActionCard(
                        icon: Icons.shield_outlined,
                        title: 'Safety Tips',
                        description: 'Stay safe while connecting',
                        onTap: () => ProfileActions.openSafetyTips(context),
                      ),
                      const SizedBox(height: 12),
                      ProfileActionCard(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        description: 'Account, privacy and more',
                        onTap: () =>
                            ProfileActions.openSettings(context, profile.id),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
