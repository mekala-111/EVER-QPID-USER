import 'dart:async';
import 'dart:developer';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/services/analytics_service.dart';
import 'package:everqpidapp/Data/services/logger_service.dart';
import 'package:everqpidapp/Features/onboarding/model/login_model.dart';
import 'package:everqpidapp/Features/onboarding/repository/auth_api_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/auth_model.dart';
import '../repository/auth_repository.dart';

enum AuthState { initial, loading, success, error }

enum GoogleSignInStatus { success, cancelled, error }

class GoogleSignInOutcome {
  const GoogleSignInOutcome._(this.status, {this.email, this.idToken, this.message});

  factory GoogleSignInOutcome.success({
    required String email,
    required String idToken,
  }) =>
      GoogleSignInOutcome._(
        GoogleSignInStatus.success,
        email: email,
        idToken: idToken,
      );

  factory GoogleSignInOutcome.cancelled() =>
      const GoogleSignInOutcome._(GoogleSignInStatus.cancelled);

  factory GoogleSignInOutcome.error(String message) =>
      GoogleSignInOutcome._(GoogleSignInStatus.error, message: message);

  final GoogleSignInStatus status;
  final String? email;
  final String? idToken;
  final String? message;
}

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final AuthApiRepository _authApiRepository = AuthApiRepository();
  bool isloading = false;
  AuthState _state = AuthState.initial;
  String? _errorMessage;
  String? _verificationId;
  AuthModel? _authModel;
  String? _phoneNumber;
  String? _countryCode;
  String? _completePhoneNumber;

  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  String? get verificationId => _verificationId;
  AuthModel? get authModel => _authModel;
  bool get isLoading => _state == AuthState.loading;
  String? get phoneNumber => _phoneNumber;
  String? get countryCode => _countryCode;
  String? get completePhoneNumber => _completePhoneNumber;
  void setPhoneDetails({
    required String phoneNumber,
    required String countryCode,
    required String completePhoneNumber,
  }) {
    _phoneNumber = phoneNumber;
    _countryCode = countryCode;
    _completePhoneNumber = completePhoneNumber;
    notifyListeners();

    log('📱 Phone details stored in AuthViewModel:');
    log('   Phone: $_phoneNumber');
    log('   Country Code: $_countryCode');
    log('   Complete: $_completePhoneNumber');
  }

  // Send OTP
  Future<bool> sendOtp(String phoneNumber, {bool isResend = false}) async {
    log('🚀 AuthViewModel: Sending OTP to $phoneNumber (resend: $isResend)');

    _setState(AuthState.loading);
    _errorMessage = null;
    // NOTE: Do NOT clear _verificationId here. Keep the old one valid until
    // a new verificationId actually arrives, so the user can still retry with
    // the old code while we wait for the new SMS.

    // Use Completer to handle async callbacks
    final completer = Completer<bool>();

    try {
      await _repository.sendOtp(
        phoneNumber: phoneNumber,
        isResend: isResend,
        onCodeSent: (verificationId) {
          log('✅ AuthViewModel: Code sent callback received');
          // Only now do we overwrite the verificationId
          _verificationId = verificationId;
          _setState(AuthState.success);

          if (!completer.isCompleted) {
            completer.complete(true);
          }
        },
        onError: (error) {
          log('❌ AuthViewModel: Error callback - $error');
          _errorMessage = error;
          _setState(AuthState.error);

          if (!completer.isCompleted) {
            completer.complete(false);
          }
        },
      );

      // Timeout must be > Firebase's 60s timeout so codeSent always wins
      final result = await completer.future.timeout(
        const Duration(seconds: 65),
        onTimeout: () {
          log('⏰ AuthViewModel: Timeout waiting for OTP');
          _errorMessage = 'Request timeout. Please try again';
          _setState(AuthState.error);
          return false;
        },
      );

      log('📊 AuthViewModel: Send OTP result = $result');
      return result;
    } catch (e) {
      log('💥 AuthViewModel: Send OTP exception - $e');
      _errorMessage = e.toString();
      _setState(AuthState.error);
      return false;
    }
  }

  Future<bool> loginUser({
    required String countryCode,
    required String mobileNumber,
  }) async {
    try {
      isloading = true;
      _errorMessage = null;
      notifyListeners();

      final request = LoginRequest(
        countryCode: countryCode,
        mobileNumber: mobileNumber,
      );

      final response = await _authApiRepository.login(request);

      if (response.status && response.data != null) {
        final user = response.data!.user;
        final tokens = response.data!.tokens;

        // 🔐 Save session
        LoggedInUser.id = user.id;
        LoggedInUser.accessToken = tokens.access.token;
        LoggedInUser.refreshToken = tokens.refresh.token;

        await LoggedInUser.storeUserLocally();

        log('✅ Login success - userId: ${user.id}');
        // ignore: unawaited_futures
        AnalyticsService.instance.logLogin(method: 'phone');
        // ignore: unawaited_futures
        AnalyticsService.instance.setUserId(user.id);
        // ignore: unawaited_futures
        LoggerService.instance.setUserId(user.id);
        return true;
      } else {
        _errorMessage = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      isloading = false;
      notifyListeners();
    }
  }

  // Verify OTP - FIXED VERSION
  Future<bool> verifyOtp(String otp) async {
    log('🔍 AuthViewModel: Verifying OTP');

    if (_verificationId == null) {
      log('❌ AuthViewModel: No verification ID found');
      _errorMessage = 'Verification ID not found. Please request OTP again';
      _setState(AuthState.error);
      return false;
    }

    _setState(AuthState.loading);
    _errorMessage = null;

    try {
      _authModel = await _repository.verifyOtp(
        verificationId: _verificationId!,
        otp: otp,
      );

      log('✅ AuthViewModel: OTP verified successfully');
      AnalyticsService.instance.logOtpVerified(method: 'phone');
      _setState(AuthState.success);
      return true;
    } catch (e) {
      log('❌ AuthViewModel: Verify OTP failed - $e');
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _setState(AuthState.error);
      return false;
    }
  }

  // backend login - phonenumber
  Future<bool> loginWithPhoneNumber(
    String countryCode,
    String mobileNumber,
  ) async {
    try {
      // 1. Check if user exists
      final checkResponse = await _authApiRepository.checkUserExists(
        countryCode: countryCode,
        mobileNumber: mobileNumber,
      );

      final userExists = checkResponse['data']['userExists'] ?? false;

      // 2. Call user-auth API
      // final authResponse = await _authApiRepository.userAuth(
      //   countryCode: countryCode,
      //   mobileNumber: mobileNumber,
      // );

      // log('authResponse:::: $authResponse');

      // // 3. Store user data and tokens
      // _currentUser = UserModel.fromJson(authResponse['data']['user']);
      // _tokens = TokensModel.fromJson(authResponse['data']['tokens']);

      // // 4. Save to LoggedInUser
      // LoggedInUser.accessToken = _tokens!.accessToken;
      // LoggedInUser.refreshToken = _tokens!.refreshToken;
      // LoggedInUser.storeUserLocally();

      return userExists; // true = go to main, false = continue onboarding
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  // google sign in
  Future<GoogleSignInOutcome> signInWithGoogle() async {
    _setState(AuthState.loading);
    _errorMessage = null;
    try {
      final credential = await _repository.signInWithGoogle();
      final user = credential.user;
      final email = user?.email;
      if (user == null || email == null || email.isEmpty) {
        _errorMessage = 'Google account has no email';
        _setState(AuthState.error);
        return GoogleSignInOutcome.error(_errorMessage!);
      }

      final idToken = await user.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        _errorMessage = 'Failed to get Google ID token';
        _setState(AuthState.error);
        return GoogleSignInOutcome.error(_errorMessage!);
      }

      _authModel = AuthModel.fromFirebase(user);
      _setState(AuthState.success);
      return GoogleSignInOutcome.success(email: email, idToken: idToken);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        _setState(AuthState.initial);
        return GoogleSignInOutcome.cancelled();
      }
      _errorMessage = e.message ?? e.code;
      _setState(AuthState.error);
      return GoogleSignInOutcome.error(_errorMessage!);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('canceled') || msg.contains('cancelled')) {
        _setState(AuthState.initial);
        return GoogleSignInOutcome.cancelled();
      }
      _errorMessage = msg.replaceAll('Exception: ', '');
      _setState(AuthState.error);
      return GoogleSignInOutcome.error(_errorMessage!);
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _repository.signOut();
    _authModel = null;
    _verificationId = null;
    _setState(AuthState.initial);
  }

  // Reset state
  void resetState() {
    _state = AuthState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  // Get current user
  AuthModel? getCurrentUser() {
    return _repository.currentAuthModel;
  }

  void reset() {
    _authModel = null;
    _verificationId = null;
    _state = AuthState.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
