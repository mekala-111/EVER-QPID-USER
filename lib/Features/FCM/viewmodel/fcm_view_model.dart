import 'dart:developer';
import 'package:everqpidapp/Data/services/fcm_service.dart';
import 'package:everqpidapp/Features/FCM/repository/fcm_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FCMViewModel extends ChangeNotifier {
  final FCMRepository _fcmRepository = FCMRepository();
  final FCM _fcmService = FCM();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  FCMViewModel();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _tokenSaved = false;
  bool get tokenSaved => _tokenSaved;

  /// Save FCM token to backend
  Future<bool> saveFCMTokenToBackend() async {
    try {
      _setLoading(true);
      _clearError();

      // Get current user's auth token
      // final authToken = await _firebaseAuth.currentUser?.getIdToken();
      // if (authToken == null) {
      //   throw Exception('No authentication token. Please login first.');
      // }

      // Get FCM token
      final fcmToken = await _fcmService.getFCMToken();
      if (fcmToken == null) {
        throw Exception('Failed to get FCM token');
      }

      log('Saving FCM token to backend...');

      // Save to backend
      final response = await _fcmRepository.saveFCMToken(
        fcmToken: fcmToken,
        // authToken: authToken,
      );

      if (response['status'] == true) {
        _tokenSaved = true;
        log('✅ FCM token saved successfully');
        _setLoading(false);
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to save FCM token');
      }
    } catch (e) {
      _setError(e.toString());
      log('❌ Error in saveFCMTokenToBackend: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update FCM token (when token refreshes)
  Future<bool> updateFCMToken(String newToken) async {
    try {
      _setLoading(true);
      _clearError();

      final authToken = await _firebaseAuth.currentUser?.getIdToken();
      if (authToken == null) {
        throw Exception('No authentication token');
      }

      log('Updating FCM token in backend...');

      final response = await _fcmRepository.updateFCMToken(
        fcmToken: newToken,
        authToken: authToken,
      );

      if (response['status'] == true) {
        log('✅ FCM token updated successfully');
        _setLoading(false);
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to update FCM token');
      }
    } catch (e) {
      _setError(e.toString());
      log('❌ Error in updateFCMToken: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Save token after user login (with delay to ensure token is ready)
  Future<void> saveTokenAfterLogin() async {
    // Wait a bit to ensure FCM token is generated
    await Future.delayed(const Duration(seconds: 1));
    await saveFCMTokenToBackend();
  }

  /// Delete FCM token (call on logout)
  Future<bool> deleteFCMToken() async {
    try {
      await _fcmService.deleteToken();
      _tokenSaved = false;
      log('FCM token deleted locally');
      notifyListeners();
      return true;
    } catch (e) {
      log('Error deleting FCM token: $e');
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    _tokenSaved = false;
    notifyListeners();
  }
}
