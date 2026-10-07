import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Data/services/fcm_service.dart';
import 'package:everqpidapp/Features/onboarding/model/login_model.dart';
import 'package:everqpidapp/Features/onboarding/model/logout_model.dart';

class AuthApiRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  /// Check if user exists
  Future<Map<String, dynamic>> checkUserExists({
    required String countryCode,
    required String mobileNumber,
  }) async {
    try {
      log('📡 Checking if user exists: $countryCode$mobileNumber');

      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/check-user-exists',
        body: {'countryCode': countryCode, 'mobileNumber': mobileNumber},
      );

      log('✅ User check response received');
      return response;
    } catch (e) {
      log('❌ Error checking user exists: $e');
      rethrow;
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final fcmToken = await FCM().getFCMToken();
      log('🔐 Calling login API');
      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/user-auth',
        body: request.toJson(),
        headers: {'fcm-token': fcmToken ?? ''},
      );

      if (response is Map<String, dynamic>) {
        log('✅ Login success response');
        return LoginResponse.fromJson(response);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Login API error: $e');
      rethrow;
    }
  }

  Future<LogoutResponse> logout(String refreshToken) async {
    try {
      log('📤 Calling logout API');

      final request = LogoutRequest(refreshToken: refreshToken);

      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/log-out',
        body: request.toJson(),
      );

      log('📥 Logout API completed');

      return LogoutResponse.fromJson(response);
    } catch (e) {
      log('❌ Logout API failed: $e');
      rethrow;
    }
  }

  /// User authentication (Login/Register)
  Future<Map<String, dynamic>> userAuth({
    required String countryCode,
    required String mobileNumber,
  }) async {
    try {
      log('📡 User authentication: $countryCode$mobileNumber');
      final fcmToken = await FCM().getFCMToken();
      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/user-auth',
        body: {'countryCode': countryCode, 'mobileNumber': mobileNumber},
        headers: {'fcm-token': fcmToken ?? ''},
      );

      log('✅ User auth response received');
      return response;
    } catch (e) {
      log('❌ Error in user auth: $e');
      rethrow;
    }
  }
}
