import 'package:everqpidapp/Features/home/view/home_web_discover.dart';
import 'package:everqpidapp/Features/profile/model/user_profile_model.dart';
import 'package:everqpidapp/Features/profile/view/edit_profile_screen.dart';
import 'package:everqpidapp/Features/profile/view/preferences_screen.dart';
import 'package:everqpidapp/Features/profile/view/recent_passes_screen.dart';
import 'package:everqpidapp/Features/profile/view/safety_tips_screen.dart';
import 'package:everqpidapp/Features/profile/view/your_likes_screen.dart';
import 'package:everqpidapp/Features/profile/view_model/liked_profile_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/preferences_view_model.dart';
import 'package:everqpidapp/Features/profileactions/view/blocked_users_list_screen.dart';
import 'package:everqpidapp/Features/settings/view/hide_contact_screen.dart';
import 'package:everqpidapp/Features/settings/view/privacy_policy_screen.dart';
import 'package:everqpidapp/Features/settings/view/settings_screen.dart';
import 'package:everqpidapp/Features/settings/view/support_screen.dart';
import 'package:everqpidapp/Features/settings/view_model/contact_view_model.dart';
import 'package:everqpidapp/Features/settings/view_model/support_view_model.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_screen.dart';
import 'package:everqpidapp/Features/verification/view/verify_intro_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shared profile menu destinations — mobile + desktop use the same navigation.
abstract final class ProfileActions {
  static void openEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
    );
  }

  static void openPreferences(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PreferencesViewModel(),
          child: const PreferencesScreen(),
        ),
      ),
    );
  }

  static void openSubscriptions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SubscriptionScreen()),
    );
  }

  static void openPremium(BuildContext context) {
    openPremiumSheet(context);
  }

  static void openYourLikes(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LikedProfilesViewModel(),
          child: const YourLikesScreen(),
        ),
      ),
    );
  }

  static void openRecentPasses(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RecentPassesScreen()),
    );
  }

  static void openSafetyTips(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SafetyTipsScreen()),
    );
  }

  static void openSettings(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsScreen(userId: userId)),
    );
  }

  static void openBlockedUsers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BlockedUsersListScreen()),
    );
  }

  static void openHideContacts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ContactsViewModel(),
          child: const HideContactsScreen(),
        ),
      ),
    );
  }

  static void openPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
    );
  }

  static void openSupport(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => SupportViewModel(),
          child: SupportScreen(userId: userId),
        ),
      ),
    );
  }

  static void openVerify(BuildContext context, UserProfileModel profile) {
    if (profile.isVerified) return;
    if (profile.profileImageUrl != null && profile.gender != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyIntroScreen(
            profileImageUrl: profile.profileImageUrl!,
            gender: profile.gender!,
          ),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Please add a profile photo and gender before verification',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
