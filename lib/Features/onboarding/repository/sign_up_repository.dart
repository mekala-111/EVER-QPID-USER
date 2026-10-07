import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Data/services/fcm_service.dart';
import 'package:everqpidapp/Features/onboarding/model/sign_up_model.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';

class SignupRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  Future<SignupResponse> signup(SignupRequest request) async {
    try {
      AppLogger.d('📤 Signup request: ${request.toJson()}');
      String? fcmToken;
      try {
        fcmToken = await FCM().getFCMToken();
      } catch (e) {
        AppLogger.d('⚠️ FCM token unavailable during signup: $e');
      }

      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/user-auth',
        body: request.toJson(),
        headers: {'fcm-token': fcmToken ?? ''},
      );

      AppLogger.d('📥 Signup raw response: $response');

      final parsed = SignupResponse.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
      AppLogger.d(
        '📥 Signup status=${parsed.status} hasData=${parsed.data != null}',
      );
      return parsed;
    } catch (e, st) {
      AppLogger.e('❌ Signup error in repository', e);
      AppLogger.d('$st');
      rethrow;
    }
  }
}
