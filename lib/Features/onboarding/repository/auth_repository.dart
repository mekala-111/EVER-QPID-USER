import 'dart:async';
import 'dart:developer';

import 'package:everqpidapp/config/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../model/auth_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static bool isInitialized = false;
  String? _verificationId;
  int? _resendToken;

  /// Web-only confirmation handle from [signInWithPhoneNumber].
  ConfirmationResult? _webConfirmationResult;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get current auth model
  AuthModel get currentAuthModel => AuthModel.fromFirebase(currentUser);

  // Send OTP to phone number
  Future<void> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    bool isResend = false,
  }) async {
    try {
      log('📱 Sending OTP to: $phoneNumber (resend: $isResend, web: $kIsWeb)');

      if (kIsWeb) {
        await _sendOtpWeb(phoneNumber, onCodeSent, onError);
      } else {
        await _sendOtpNative(phoneNumber, onCodeSent, onError, isResend);
      }
    } catch (e) {
      log('💥 Send OTP exception: $e');
      onError(_mapSendOtpError(e));
    }
  }

  /// Web must use [signInWithPhoneNumber] + reCAPTCHA (invisible by default).
  Future<void> _sendOtpWeb(
    String phoneNumber,
    Function(String verificationId) onCodeSent,
    Function(String error) onError,
  ) async {
    try {
      // Clear any previous verifier/session so tokens don't expire mid-flow.
      _webConfirmationResult = null;

      final confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
      _webConfirmationResult = confirmationResult;
      _verificationId = confirmationResult.verificationId;

      log('📨 Web code sent! VerificationId: $_verificationId');
      onCodeSent(confirmationResult.verificationId);
    } on FirebaseAuthException catch (e) {
      log('❌ Web verification failed: ${e.code} - ${e.message}');
      onError(_mapFirebaseAuthError(e));
    }
  }

  Future<void> _sendOtpNative(
    String phoneNumber,
    Function(String verificationId) onCodeSent,
    Function(String error) onError,
    bool isResend,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification is intentionally ignored — manual OTP entry required
        log('ℹ️ Auto-verification triggered but ignored (manual OTP entry required)');
      },
      verificationFailed: (FirebaseAuthException e) {
        log('❌ Verification failed: ${e.code} - ${e.message}');
        onError(_mapFirebaseAuthError(e));
      },
      codeSent: (String verificationId, int? resendToken) {
        log('📨 Code sent! VerificationId: $verificationId');
        _verificationId = verificationId;
        _resendToken = resendToken;
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log('⏰ Auto retrieval timeout');
        _verificationId = verificationId;
      },
      forceResendingToken: isResend ? _resendToken : null,
    );
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number';
      case 'too-many-requests':
        return 'Too many requests. Please try again later';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Try again later';
      case 'invalid-app-credential':
        return 'reCAPTCHA verification failed. On local web, use http://127.0.0.1 '
            '(not localhost), ensure it is an Authorized domain in Firebase, '
            'or use a Firebase Auth test phone number.';
      case 'captcha-check-failed':
        return 'reCAPTCHA check failed. Please try again.';
      default:
        return e.message ?? 'Verification failed';
    }
  }

  String _mapSendOtpError(Object e) {
    if (e is FirebaseAuthException) return _mapFirebaseAuthError(e);
    return e.toString();
  }

  // Verify OTP
  Future<AuthModel?> verifyOtp({
    required String verificationId,
    required String otp,
  }) async {
    try {
      log('🔍 Verifying OTP');
      log('   VerificationId present: ${verificationId.isNotEmpty} (web: $kIsWeb)');

      if (kIsWeb) {
        return await _verifyOtpWeb(otp);
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      log('🔐 Signing in with credential...');
      final userCredential = await _auth.signInWithCredential(credential);

      log('✅ Sign in successful! UID: ${userCredential.user?.uid}');
      return AuthModel.fromFirebase(userCredential.user);
    } on FirebaseAuthException catch (e) {
      log('❌ Firebase Auth Exception: ${e.code} - ${e.message}');

      switch (e.code) {
        case 'invalid-verification-code':
          throw Exception('Invalid OTP. Please try again');
        case 'session-expired':
          throw Exception('OTP expired. Please request a new one');
        case 'invalid-verification-id':
          throw Exception('Invalid session. Please restart the process');
        default:
          throw Exception(e.message ?? 'Verification failed');
      }
    } catch (e) {
      log('💥 Verify OTP exception: $e');
      throw Exception(e.toString());
    }
  }

  Future<AuthModel?> _verifyOtpWeb(String otp) async {
    final confirmation = _webConfirmationResult;
    if (confirmation == null) {
      throw Exception('Verification session expired. Please request OTP again');
    }

    log('🔐 Confirming web OTP…');
    final userCredential = await confirmation.confirm(otp);
    _webConfirmationResult = null;
    log('✅ Web sign in successful! UID: ${userCredential.user?.uid}');
    return AuthModel.fromFirebase(userCredential.user);
  }

  // Sign in with credential (for auto verification)
  Future<AuthModel?> signInWithCredential(
    PhoneAuthCredential credential,
  ) async {
    try {
      log('🔐 Signing in with auto-verified credential...');
      final userCredential = await _auth.signInWithCredential(credential);
      log('✅ Auto sign in successful!');
      return AuthModel.fromFirebase(userCredential.user);
    } catch (e) {
      log('❌ Auto sign in failed: $e');
      throw Exception(e.toString());
    }
  }

  static Future<void> initSignIn() async {
    if (!isInitialized) {
      await _googleSignIn.initialize(
        clientId: kIsWeb ? AppConfig.googleWebClientId : null,
        serverClientId: AppConfig.googleWebClientId,
      );
      isInitialized = true;
    }
  }

  /// Google → Firebase Auth. Web uses popup; native uses google_sign_in 7.
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile')
        ..setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(provider);
    }

    await initSignIn();
    final account = await _googleSignIn.authenticate(
      scopeHint: const ['email', 'profile'],
    );
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google sign-in failed: missing ID token');
    }

    GoogleSignInClientAuthorization? authz;
    try {
      authz = await account.authorizationClient.authorizationForScopes(
        const ['email', 'profile'],
      );
    } catch (_) {
      // Access token optional for Firebase on some platforms.
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: authz?.accessToken,
    );
    return _auth.signInWithCredential(credential);
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      if (isInitialized) await _googleSignIn.signOut();
    } catch (_) {}
    _webConfirmationResult = null;
    log('👋 User signed out');
  }

  // Listen to auth state changes
  Stream<AuthModel> authStateChanges() {
    return _auth.authStateChanges().map((user) => AuthModel.fromFirebase(user));
  }
}
