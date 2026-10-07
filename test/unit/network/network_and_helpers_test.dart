import 'package:everqpidapp/Data/Exceptions/app_exceptions.dart';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Settings/helper/upload_validation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/dio_harness.dart';
import '../../helpers/fake_api_service.dart';
import '../../helpers/fake_firebase.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkApiServiceV2 + Dio mock', () {
    late DioTestHarness harness;

    setUp(() {
      harness = DioTestHarness()..install();
    });

    test('GET 200 returns body', () async {
      harness.onGet('/health', {'ok': true});
      final data = await NetworkApiServiceV2.instance.getGetApiResponse('/health');
      expect(data['ok'], isTrue);
    });

    test('GET non-2xx throws AppExceptions', () async {
      harness.onGet('/boom', {'message': 'nope'}, status: 404);
      expect(
        () => NetworkApiServiceV2.instance.getGetApiResponse('/boom'),
        throwsA(isA<AppExceptions>()),
      );
    });
  });

  group('FakeApiService', () {
    test('returns canned payloads', () async {
      final api = FakeApiService(
        cannedGet: {'status': true, 'data': 1},
        cannedPost: {'status': true, 'data': 2},
      );
      expect((await api.getGetApiResponse('/x'))['data'], 1);
      expect((await api.getPostApiResponse('/y'))['data'], 2);
    });

    test('rethrows configured errors', () async {
      final api = FakeApiService(throwOnCall: Exception('offline'));
      expect(() => api.getGetApiResponse('/x'), throwsException);
    });
  });

  group('FakeFirebaseAuthSession', () {
    test('signIn and signOut', () async {
      final auth = FakeFirebaseAuthSession();
      final user = await auth.signInWithCredential();
      expect(user.uid, isNotEmpty);
      await auth.signOut();
      expect(auth.signedOut, isTrue);
      expect(auth.currentUser, isNull);
    });
  });

  group('UploadValidation', () {
    test('demo asserts', () {
      UploadValidation.demo();
    });
  });
}
