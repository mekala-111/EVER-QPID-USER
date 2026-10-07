import 'dart:typed_data';

import 'package:everqpidapp/Features/home/view_model/matching_view_model.dart';
import 'package:everqpidapp/Features/profile/view_model/get_profile_view_model.dart';
import 'package:everqpidapp/Features/subscription/repository/subscription_repository.dart';
import 'package:everqpidapp/Features/verification/viewmodel/verification_viewmodel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/dio_harness.dart';
import '../../helpers/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DioTestHarness harness;

  setUp(() {
    harness = DioTestHarness()..install();
  });

  group('MatchingViewModel', () {
    test('sendLike success notifies and returns match', () async {
      harness.onPost('/api/v1/matching/like-send', Fixtures.likeMatch());
      final vm = MatchingViewModel();
      var notified = 0;
      vm.addListener(() => notified++);

      final res = await vm.sendLike('p1');

      expect(res['status'], isTrue);
      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, isNull);
      expect(notified, greaterThan(0));
    });

    test('sendLike failure sets errorMessage', () async {
      harness.onPost(
        '/api/v1/matching/like-send',
        {'status': false, 'message': 'nope', 'statusCode': 400},
        status: 400,
      );
      final vm = MatchingViewModel();
      final res = await vm.sendLike('p1');
      expect(res['status'], isFalse);
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });

  group('GetProfileViewModel', () {
    test('fetchProfile loading → success', () async {
      harness.onGet(
        '/api/v1/profile/get-profile',
        Fixtures.ok(Fixtures.profileData()),
      );
      final vm = GetProfileViewModel();
      final future = vm.fetchProfile();
      expect(vm.isLoading, isTrue);
      await future;
      expect(vm.isLoading, isFalse);
      expect(vm.profile?.id, 'u1');
      expect(vm.errorMessage, isNull);
    });

    test('fetchProfile failure sets error', () async {
      harness.onGet(
        '/api/v1/profile/get-profile',
        {'message': 'fail'},
        status: 500,
      );
      final vm = GetProfileViewModel();
      await vm.fetchProfile();
      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, isNotNull);
      expect(vm.profile, isNull);
    });

    test('deleteAccount success', () async {
      harness.onPost(
        '/api/v1/profile/delete-profile-user',
        {'status': true, 'statusCode': 200},
      );
      final vm = GetProfileViewModel();
      final ok = await vm.deleteAccount(userId: 'u1', reason: 'test');
      expect(ok, isTrue);
      expect(vm.isDeleting, isFalse);
    });
  });

  group('SubscriptionRepository via Dio (VM uses Razorpay channels)', () {
    test('plans payload parses through repository', () async {
      harness.onGet(
        '/api/v1/subscription-plans/user/get-all-subscriptions?pageNumber=1&pageSize=10',
        Fixtures.ok(Fixtures.subscriptionsData()),
      );
      final res =
          await SubscriptionRepository().getAllSubscriptions();
      expect(res.subscriptions.first.planName, 'Monthly');
    });
  });

  group('VerificationViewModel', () {
    test('reset clears state and notifies', () {
      final vm = VerificationViewModel();
      var n = 0;
      vm.addListener(() => n++);
      vm.reset();
      expect(vm.isVerified, isFalse);
      expect(vm.errorMessage, isNull);
      expect(n, greaterThan(0));
    });

    test('uploadSelfie failure on empty bytes', () async {
      final vm = VerificationViewModel();
      final ok = await vm.uploadSelfie(Uint8List(0));
      expect(ok, isFalse);
      expect(vm.errorMessage, isNotNull);
      expect(vm.isUploading, isFalse);
    });
  });
}
