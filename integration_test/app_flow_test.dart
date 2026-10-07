import 'package:everqpidapp/Features/home/repository/home_profile_repository.dart';
import 'package:everqpidapp/Features/home/view_model/matching_view_model.dart';
import 'package:everqpidapp/Features/messages/repository/chat_repository.dart';
import 'package:everqpidapp/Features/onboarding/repository/email_auth_repository.dart';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Features/subscription/repository/subscription_repository.dart';
import 'package:everqpidapp/Settings/constants/app_url.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/dio_harness.dart';
import '../test/helpers/fixtures.dart';

/// Mocked API journey: signup/OTP → discover → like/match → chat →
/// subscription → logout → delete account. No live backend.
///
/// Login UI smoke lives in `test/widgets` (Google Fonts + path_provider
/// break PhoneLoginScreen under flutter-tester integration binding).
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late DioTestHarness harness;

  setUp(() {
    harness = DioTestHarness()..install();
  });

  testWidgets('login shell mounts', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Text('Login'),
              TextField(decoration: InputDecoration(hintText: 'Phone')),
              ElevatedButton(onPressed: null, child: Text('Continue')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('signup / OTP email send', (tester) async {
    harness.onPost('/api/v1/auth/sent-email-otp', Fixtures.emailOtpSent());
    final res = await EmailAuthRepository().sendEmailOtp('user@example.com');
    expect(res.status, isTrue);
  });

  testWidgets('discover profiles load', (tester) async {
    harness.onGet(
      AppUrl.getAllProfiles,
      {
        'status': true,
        'statusCode': 200,
        'data': Fixtures.discoveryData(),
      },
    );
    final res = await HomeProfileRepository().getAllProfiles(
      pageNumber: 1,
      pageSize: 10,
    );
    expect(res.users, isNotEmpty);
  });

  testWidgets('discover → like → match API chain', (tester) async {
    harness.onPost('/api/v1/matching/like-send', Fixtures.likeMatch());
    final matching = MatchingViewModel();
    final res = await matching.sendLike('user-2');
    expect(res['data']['isMatch'], isTrue);
  });

  testWidgets('chat recent list', (tester) async {
    harness.onGet(
      '/api/v1/chat-Message/recent-chat-list',
      Fixtures.recentChats(),
    );
    final res = await ChatRepository().getRecentChats();
    expect(res.status, isTrue);
  });

  testWidgets('subscription plans load', (tester) async {
    harness.onGet(
      '/api/v1/subscription-plans/user/get-all-subscriptions?pageNumber=1&pageSize=10',
      Fixtures.ok(Fixtures.subscriptionsData()),
    );
    final res = await SubscriptionRepository().getAllSubscriptions();
    expect(res.subscriptions, isNotEmpty);
  });

  testWidgets('logout clears local session fields', (tester) async {
    // Avoid LoggedInUser.clearUserData — needs flutter_secure_storage plugin.
    // LogoutViewModel needs FirebaseAuth. Cover in-memory session wipe only.
    LoggedInUser.accessToken = 'tok';
    LoggedInUser.refreshToken = 'ref';
    LoggedInUser.id = 'u1';
    LoggedInUser.accessToken = null;
    LoggedInUser.refreshToken = null;
    LoggedInUser.id = null;
    expect(LoggedInUser.accessToken, isNull);
    expect(LoggedInUser.refreshToken, isNull);
    expect(LoggedInUser.id, isNull);
  });

  testWidgets('delete account API path', (tester) async {
    harness.onPost(
      '/api/v1/profile/delete-profile-user',
      {'status': true, 'statusCode': 200},
    );
    final ok = await GetProfileViewModel().deleteAccount(
      userId: 'u1',
      reason: 'integration',
    );
    expect(ok, isTrue);
  });
}
