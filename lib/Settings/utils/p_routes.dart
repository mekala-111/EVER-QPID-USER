import 'package:everqpidapp/Features/common_widgets/all_profile_detail_screen.dart';
import 'package:everqpidapp/Features/itsamatch/view/its_a_match_screen.dart';
import 'package:everqpidapp/Features/mainscreen/view/main_screen.dart';
import 'package:everqpidapp/Features/messages/view/messages_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/gender_selection_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/looking_for_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/name_dob_screen.dart';
import 'package:everqpidapp/Features/onboarding/view/onboarding_1.dart';
import 'package:everqpidapp/Features/onboarding/view/photo_upload_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_about_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_bio_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_interests_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_profile_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_relationship_goals_screen.dart';
import 'package:everqpidapp/Features/profile/view/edit_work_and_education_screen.dart';
import 'package:everqpidapp/Features/profile/view/safety_tips_screen.dart';
import 'package:everqpidapp/Features/settings/view/delete_account_screen.dart';
import 'package:everqpidapp/Features/settings/view/manage_subscription_screen.dart';
import 'package:everqpidapp/Features/settings/view/settings_screen.dart';
import 'package:everqpidapp/Features/settings/view/support_screen.dart';
import 'package:everqpidapp/Features/settings/view_model/support_view_model.dart';
import 'package:everqpidapp/Settings/common/widgets/no_internet_screen.dart';
import 'package:everqpidapp/features/messages/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Features/settings/view/privacy_policy_screen.dart';
import '../../Features/settings/view/terms_conditions_screen.dart';
import '../../Features/splash/view/splash_screen.dart';
import '../../Features/onboarding/view/welcome/welcome_screen.dart';
import 'p_pages.dart';

class Routes {
  static Route<dynamic>? genericRoute(RouteSettings settings) {
    switch (settings.name) {
      case PPages.splash:
        return MaterialPageRoute(builder: (context) => const SplashScreen());
      case PPages.noInternet:
        return MaterialPageRoute(builder: (context) => NoInternetWidget());
      case PPages.welcomePageUi:
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
      case PPages.mainScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        final tabIndex = args?['tabIndex'] as int?;
        return MaterialPageRoute(
          builder: (context) => MainScreen(
            initialTab: tabIndex ?? 0,
          ),
        );
      case PPages.login:
        return MaterialPageRoute(builder: (context) => Onboarding1());
      case PPages.chatScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => ChatScreen(
            receiverId: args?['receiverId'],
            name: args?['name'],
            imageUrl: args?['imageUrl'],
            isOnline: args?['isOnline'],
          ),
        );
      case PPages.deleteAccountScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) =>
              DeleteAccountScreen(userId: args?['userId'] ?? ''),
        );
      case PPages.settingsScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => SettingsScreen(userId: args?['userId'] ?? ''),
        );
      // case PPages.locationPermission:
      //   return MaterialPageRoute(
      //     builder: (context) => LocationPermissionScreen(),
      //   );
      // case PPages.notificationPermission:
      //   return MaterialPageRoute(
      //     builder: (context) => NotificationPermissionScreen(),
      //   );
      case PPages.nameDobScreen:
        return MaterialPageRoute(builder: (context) => NameDobScreen());
      case PPages.editAboutScreen:
        return MaterialPageRoute(builder: (context) => EditAboutScreen());
      case PPages.editBioScreen:
        return MaterialPageRoute(builder: (context) => EditBioScreen());
      case PPages.itsAMatchScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) =>
              ItsAMatchScreen(matchedName: args?['matchedName']),
        );
      case PPages.editInterestsScreen:
        return MaterialPageRoute(builder: (context) => EditInterestsScreen());
      case PPages.editProfileScreen:
        return MaterialPageRoute(builder: (context) => EditProfileScreen());
      case PPages.editRelationshipsScreen:
        return MaterialPageRoute(
          builder: (context) => EditRelationshipGoalsScreen(),
        );
      case PPages.genderSelectionScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) =>
              GenderSelectionScreen(name: args?['name'], dob: args?['dob']),
        );
      case PPages.lookingForScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => LookingForScreen(
            name: args?['name'],
            dob: args?['dob'],
            gender: args?['gender'],
          ),
        );
      case PPages.photoUploadScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) => PhotoUploadScreen(
            name: args?['name'],
            dob: args?['dob'],
            gender: args?['gender'],
            lookingFor: args?['lookingFor'],
          ),
        );
      case PPages.safetyTipsScreen:
        return MaterialPageRoute(builder: (context) => SafetyTipsScreen());
      // case PPages.profileIntroScreen:
      //   return MaterialPageRoute(builder: (context) => ProfileIntroScreen());
      case PPages.messagesScreen:
        return MaterialPageRoute(builder: (context) => MessagesScreen());
      case PPages.editWorkEducationScreen:
        return MaterialPageRoute(
          builder: (context) => EditWorkEducationScreen(),
        );
      case PPages.manageSubscriptionScreen:
        return MaterialPageRoute(
          builder: (context) => ManageSubscriptionScreen(),
        );
      case PPages.profileDetailScreen:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (context) =>
              ProfileDetailScreen(profile: args?['profile'], profileTitle: ''),
        );
      case PPages.supportScreen:
        final args = settings.arguments as Map<String, dynamic>?;

        return MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => SupportViewModel(),
            child: SupportScreen(userId: args?['userId'] ?? ''),
          ),
        );
      case PPages.privacyPolicyScreen:
        return MaterialPageRoute(
          builder: (context) => const PrivacyPolicyScreen(),
        );
      case PPages.termsConditionsScreen:
        return MaterialPageRoute(
          builder: (context) => const TermsConditionsScreen(),
        );

      default:
        return null;
    }
  }
}
