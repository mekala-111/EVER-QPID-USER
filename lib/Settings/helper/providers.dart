import 'package:everqpidapp/Features/FCM/viewmodel/fcm_view_model.dart';
import 'package:everqpidapp/Features/clan2.0/view_model/clan_view_model.dart';
import 'package:everqpidapp/Features/home/view_model/home_view_model.dart';
import 'package:everqpidapp/Features/home/view_model/matching_view_model.dart';
import 'package:everqpidapp/Features/location/view_model/location_view_model.dart';
import 'package:everqpidapp/Features/mainscreen/view_model/main_screen_view_model.dart';
import 'package:everqpidapp/Features/matches/view_model/likes_view_model.dart';
import 'package:everqpidapp/Features/matches/view_model/matches_view_model.dart';
import 'package:everqpidapp/Features/messages/view_model/chat_view_model.dart';
import 'package:everqpidapp/Features/messages/view_model/messages_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/auth_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/email_auth_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/logout_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/photo_upload_view_model.dart';
import 'package:everqpidapp/Features/onboarding/view_model/signup_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/recent_pass_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/update_profile_view_model.dart';
import 'package:everqpidapp/Features/profileactions/view_model/profile_actions_view_model.dart';
import 'package:everqpidapp/Features/subscription/view_model/subscription_view_model.dart';
import 'package:everqpidapp/Features/superlikes/view_model/super_likes_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// App-wide: spans splash → onboarding → main → logout.
List<SingleChildWidget> providers = [
  ChangeNotifierProvider<LocationViewModel>(create: (_) => LocationViewModel()),
  ChangeNotifierProvider<AuthViewModel>(create: (_) => AuthViewModel()),
  ChangeNotifierProvider<EmailAuthViewModel>(
    create: (_) => EmailAuthViewModel(),
  ),
  ChangeNotifierProvider<SignupViewModel>(create: (_) => SignupViewModel()),
  ChangeNotifierProvider<PhotoUploadViewModel>(
    create: (_) => PhotoUploadViewModel(),
  ),
  ChangeNotifierProvider<GetProfileViewModel>(
    create: (_) => GetProfileViewModel(),
  ),
  ChangeNotifierProvider<ChatViewModel>(create: (_) => ChatViewModel()),
  ChangeNotifierProvider<LogoutViewModel>(create: (_) => LogoutViewModel()),
  ChangeNotifierProvider<FCMViewModel>(create: (_) => FCMViewModel()),
];

/// Authenticated shell (MainScreen + IndexedStack tabs). Disposed when shell pops.
List<SingleChildWidget> mainShellProviders = [
  ChangeNotifierProvider<MainScreenViewModel>(
    create: (_) => MainScreenViewModel(),
  ),
  ChangeNotifierProvider<HomeViewModel>(create: (_) => HomeViewModel()),
  ChangeNotifierProvider<MatchesViewModel>(create: (_) => MatchesViewModel()),
  ChangeNotifierProvider<LikesViewModel>(create: (_) => LikesViewModel()),
  ChangeNotifierProvider<MessagesViewModel>(create: (_) => MessagesViewModel()),
  ChangeNotifierProvider<ClanViewModel>(create: (_) => ClanViewModel()),
  ChangeNotifierProvider<MatchingViewModel>(create: (_) => MatchingViewModel()),
  ChangeNotifierProvider<RecentPassViewModel>(
    create: (_) => RecentPassViewModel(),
  ),
  ChangeNotifierProvider<SuperLikesViewModel>(
    create: (_) => SuperLikesViewModel(),
  ),
  ChangeNotifierProvider<ProfileViewModel>(create: (_) => ProfileViewModel()),
  ChangeNotifierProvider<ProfileActionsViewModel>(
    create: (_) => ProfileActionsViewModel(),
  ),
  // ponytail: shell-scoped so sheet→screen share one Razorpay; disposes on logout
  ChangeNotifierProvider<SubscriptionViewModel>(
    create: (_) => SubscriptionViewModel(),
  ),
];
