import 'dart:developer';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/services/analytics_service.dart';
import 'package:everqpidapp/Data/services/logger_service.dart';
import 'package:everqpidapp/Features/onboarding/repository/auth_api_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LogoutViewModel extends ChangeNotifier {
  final AuthApiRepository _repository = AuthApiRepository();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> logout() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final refreshToken = LoggedInUser.refreshToken;

      log('🚪 Starting logout process...');

      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          log('📤 Calling backend logout API');
          final response = await _repository.logout(refreshToken);

          if (response.statusCode == 200) {
            log('✅ Backend logout success: ${response.message}');
          }
        } catch (e) {
          log('⚠️ Backend logout failed: $e');
          log('⚠️ Continuing with local cleanup');
        }
      }

      try {
        await _firebaseAuth.signOut();
        log('✅ Firebase signed out');
      } catch (e) {
        log('⚠️ Firebase sign out failed: $e');
      }

      await LoggedInUser.clearUserData();
      log('✅ SharedPreferences cleared');
      AnalyticsService.instance.logLogout();
      AnalyticsService.instance.setUserId(null);
      LoggerService.instance.setUserId(null);

      LoggedInUser.id = null;
      LoggedInUser.refreshToken = null;
      LoggedInUser.accessToken = null;
      LoggedInUser.name = null;
      LoggedInUser.email = null;
      LoggedInUser.profilePic = null;
      LoggedInUser.userName = null;
      LoggedInUser.gender = null;
      LoggedInUser.age = null;
      LoggedInUser.bio = null;
      LoggedInUser.coinBalance = null;
      LoggedInUser.earnedBalance = null;
      LoggedInUser.isOnline = null;
      LoggedInUser.isBusy = null;
      LoggedInUser.acceptCalls = null;
      LoggedInUser.isVerified = null;
      LoggedInUser.lat = null;
      LoggedInUser.long = null;
      LoggedInUser.countryCode = null;
      LoggedInUser.mobileNumber = null;
      log('✅ Static user data cleared');

      _isLoading = false;
      notifyListeners();

      log('🎉 Logout completed successfully');
      return true;
    } catch (e) {
      log('❌ Logout failed: $e');
      _error = 'Failed to logout. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset ViewModel state
  void reset() {
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
