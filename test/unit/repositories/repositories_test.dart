import 'dart:typed_data';

import 'package:everqpidapp/Features/clan2.0/repository/clan_repository.dart';
import 'package:everqpidapp/Features/home/repository/home_profile_repository.dart';
import 'package:everqpidapp/Features/home/repository/matching_repository.dart';
import 'package:everqpidapp/Features/messages/repository/chat_repository.dart';
import 'package:everqpidapp/Features/onboarding/repository/email_auth_repository.dart';
import 'package:everqpidapp/Features/profile/repository/profile_repository.dart';
import 'package:everqpidapp/Features/subscription/repository/subscription_repository.dart';
import 'package:everqpidapp/Features/verification/repository/verification_repository.dart';
import 'package:everqpidapp/Settings/constants/app_url.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/dio_harness.dart';
import '../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DioTestHarness harness;

  setUp(() {
    harness = DioTestHarness()..install();
  });

  group('EmailAuthRepository', () {
    test('sendEmailOtp success', () async {
      harness.onPost('/api/v1/auth/sent-email-otp', Fixtures.emailOtpSent());
      final res = await EmailAuthRepository().sendEmailOtp('a@b.com');
      expect(res.status, isTrue);
      expect(res.message, 'OTP sent');
    });

    test('sendEmailOtp maps HTTP errors', () async {
      harness.onPost(
        '/api/v1/auth/sent-email-otp',
        {'status': false, 'statusCode': 400, 'message': 'bad'},
        status: 400,
      );
      expect(
        () => EmailAuthRepository().sendEmailOtp('a@b.com'),
        throwsA(anything),
      );
    });
  });

  group('ProfileRepository', () {
    test('getProfile success', () async {
      harness.onGet(
        '/api/v1/profile/get-profile',
        Fixtures.ok(Fixtures.profileData()),
      );
      final profile = await ProfileRepository().getProfile();
      expect(profile.id, 'u1');
      expect(profile.fullName, 'Test User');
    });
  });

  group('HomeProfileRepository', () {
    test('getAllProfiles success', () async {
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
      expect(res.users, hasLength(1));
      expect(res.users.first.name, 'Alex');
    });
  });

  group('MatchingRepository', () {
    test('likeUser success', () async {
      harness.onPost('/api/v1/matching/like-send', Fixtures.likeMatch());
      final res = await MatchingRepository().likeUser('p1');
      expect(res['status'], isTrue);
      expect(res['data']['isMatch'], isTrue);
    });
  });

  group('ChatRepository', () {
    test('getRecentChats success', () async {
      harness.onGet(
        '/api/v1/chat-Message/recent-chat-list',
        Fixtures.recentChats(),
      );
      final res = await ChatRepository().getRecentChats();
      expect(res.status, isTrue);
      expect(res.chats, isEmpty);
    });
  });

  group('SubscriptionRepository', () {
    test('getAllSubscriptions success', () async {
      harness.onGet(
        '/api/v1/subscription-plans/user/get-all-subscriptions?pageNumber=1&pageSize=10',
        Fixtures.ok(Fixtures.subscriptionsData()),
      );
      final res = await SubscriptionRepository().getAllSubscriptions();
      expect(res.subscriptions, hasLength(1));
      expect(res.subscriptions.first.planName, 'Monthly');
    });
  });

  group('ClanRepository', () {
    test('fetchClanProfiles success', () async {
      harness.onPost(
        '/api/v1/clan/fetch-location-profiles',
        Fixtures.clanProfiles(),
      );
      final res = await ClanRepository().fetchClanProfiles(
        userId: 'u1',
        clanType: 'friends',
        lat: 10,
        lng: 76,
        pageNumber: 1,
        pageSize: 10,
      );
      expect(res['profiles'], isEmpty);
      expect(res['isSubscribed'], isTrue);
    });
  });

  group('VerificationRepository', () {
    test('rejects empty image', () async {
      expect(
        () => VerificationRepository().uploadSelfieToS3(Uint8List(0)),
        throwsA(isA<Exception>()),
      );
    });

    test('uploadSelfieToS3 with jpeg + signed url', () async {
      final jpeg = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0x00, 0x00, 0x00]);
      harness.onPost(
        '/api/v1/signed-url/get-signed-url',
        Fixtures.ok({
          'signedUrl': 'https://cdn.example.com/upload?x=1',
        }),
      );
      harness.onPutAbsolute('https://cdn.example.com/upload?x=1');
      final url = await VerificationRepository().uploadSelfieToS3(jpeg);
      expect(url, startsWith('https://cdn.example.com/upload'));
    });
  });
}
