import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Data/services/fcm_service.dart';
import '../model/email_auth_model.dart';

class EmailAuthRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  // Send OTP to email
  Future<SendEmailOtpResponse> sendEmailOtp(String email) async {
    try {
      log('📤 Sending OTP to: $email');

      final request = SendEmailOtpRequest(email: email);
      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/sent-email-otp',
        body: request.toJson(),
      );

      log('📥 Send OTP response received');
      return SendEmailOtpResponse.fromJson(response);
    } catch (e) {
      log('❌ Send OTP error: $e');
      rethrow;
    }
  }

  // Verify email OTP
  Future<VerifyEmailOtpResponse> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      log('📤 Verifying OTP for: $email');

      final request = VerifyEmailOtpRequest(email: email, otp: otp);
      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/verify-admin-otp',
        body: request.toJson(),
      );

      log('📥 Verify OTP response received');
      return VerifyEmailOtpResponse.fromJson(response);
    } catch (e) {
      log('❌ Verify OTP error: $e');
      rethrow;
    }
  }

  // Check if user exists
  Future<CheckUserExistsResponse> checkUserExists(String email) async {
    try {
      log('📤 Checking if user exists: $email');

      final request = CheckUserExistsRequest(email: email);
      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/check-user-exists-email',
        body: request.toJson(),
      );

      log('📥 Check user response received');
      return CheckUserExistsResponse.fromJson(response);
    } catch (e) {
      log('❌ Check user error: $e');
      rethrow;
    }
  }

  /// Google / social login via Firebase ID token.
  Future<EmailLoginResponse> googleLogin({
    required String idToken,
    required String email,
  }) async {
    try {
      log('📤 Google login for: $email');
      final fcmToken = await FCM().getFCMToken();
      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/google-login',
        body: {'idToken': idToken, 'email': email},
        headers: {'fcm-token': fcmToken ?? ''},
      );
      log('📥 Google login response received');
      return EmailLoginResponse.fromJson(response);
    } catch (e) {
      log('❌ Google login error: $e');
      rethrow;
    }
  }

  // Email login
  Future<EmailLoginResponse> emailLogin({
    required String email,
    required String otp,
  }) async {
    try {
      log('📤 Email login for: $email');
      final fcmToken = await FCM().getFCMToken();
      final request = EmailLoginRequest(email: email, otp: otp);
      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/user-email-login',
        body: request.toJson(),
        headers: {'fcm-token': fcmToken ?? ''},
      );

      log('📥 Email login response received');
      return EmailLoginResponse.fromJson(response);
    } catch (e) {
      log('❌ Email login error: $e');
      rethrow;
    }
  }

  // Email signup
  Future<EmailLoginResponse> emailSignup(EmailSignupRequest request) async {
    try {
      log('📤 Email signup for: ${request.email}');
      final fcmToken = await FCM().getFCMToken();
      final response = await _apiService.getPostApiResponse(
        '/api/v1/auth/user-email-signup',
        body: request.toJson(),
        headers: {'fcm-token': fcmToken ?? ''},
      );

      log('📥 Email signup response received');
      return EmailLoginResponse.fromJson(response);
    } catch (e) {
      log('❌ Email signup error: $e');
      rethrow;
    }
  }
}
