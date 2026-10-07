// features/verification/view_model/verification_view_model.dart

import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../model/face_verification_response.dart';
import '../repository/verification_repository.dart';

/// ViewModel managing verification flow state and business logic
class VerificationViewModel extends ChangeNotifier {
  final VerificationRepository _repo = VerificationRepository();

  // State properties
  bool _isUploading = false;
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _selfieImageUrl;
  String? _errorMessage;
  FaceVerificationResponse? _verificationResponse;

  // Getters
  bool get isUploading => _isUploading;
  bool get isVerifying => _isVerifying;
  bool get isVerified => _isVerified;
  String? get selfieImageUrl => _selfieImageUrl;
  String? get errorMessage => _errorMessage;
  FaceVerificationResponse? get verificationResponse => _verificationResponse;

  /// Combined loading state for UI
  bool get isLoading => _isUploading || _isVerifying;

  /// Upload selfie image bytes to S3
  Future<bool> uploadSelfie(Uint8List imageBytes) async {
    try {
      _isUploading = true;
      _errorMessage = null;
      notifyListeners();

      log('📤 Starting selfie upload...');
      _selfieImageUrl = await _repo.uploadSelfieToS3(imageBytes);

      log('✅ Selfie uploaded successfully: $_selfieImageUrl');
      _isUploading = false;
      notifyListeners();

      return true;
    } catch (e) {
      log('❌ Selfie upload failed: $e');
      _errorMessage = 'Failed to upload selfie. Please try again.';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Verify face recognition using profile image and selfie
  Future<bool> verifyFace({
    required String profileImageUrl,
    required String gender,
  }) async {
    try {
      if (_selfieImageUrl == null) {
        _errorMessage = 'Please capture a selfie first';
        notifyListeners();
        return false;
      }

      _isVerifying = true;
      _errorMessage = null;
      _isVerified = false;
      notifyListeners();

      log('🔍 Starting face verification...');
      _verificationResponse = await _repo.verifyFaceRecognition(
        profileImageUrl: profileImageUrl,
        selfieImageUrl: _selfieImageUrl!,
        gender: gender,
      );

      _isVerified = _verificationResponse!.isVerified;

      if (!_isVerified) {
        // Set appropriate error message based on verification result
        if (_verificationResponse!.data != null) {
          if (!_verificationResponse!.data!.isFaceMatch) {
            _errorMessage = 'Face does not match your profile photo';
          } else if (!_verificationResponse!.data!.genderMatches) {
            _errorMessage = 'Gender verification failed';
          } else {
            _errorMessage = _verificationResponse!.message;
          }
        } else {
          _errorMessage = _verificationResponse!.message;
        }
      }

      log(
        _isVerified
            ? '✅ Verification successful'
            : '❌ Verification failed: $_errorMessage',
      );

      _isVerifying = false;
      notifyListeners();

      return _isVerified;
    } catch (e) {
      log('❌ Verification error: $e');
      _errorMessage = 'Verification failed. Please try again.';
      _isVerifying = false;
      _isVerified = false;
      notifyListeners();
      return false;
    }
  }

  /// Upload selfie and verify in one step (convenience method)
  Future<bool> uploadAndVerify({
    required Uint8List selfieBytes,
    required String profileImageUrl,
    required String gender,
  }) async {
    final uploadSuccess = await uploadSelfie(selfieBytes);
    if (!uploadSuccess) return false;

    return await verifyFace(profileImageUrl: profileImageUrl, gender: gender);
  }

  /// Reset verification state (for retry)
  void reset() {
    _isUploading = false;
    _isVerifying = false;
    _isVerified = false;
    _selfieImageUrl = null;
    _errorMessage = null;
    _verificationResponse = null;
    notifyListeners();
  }

  /// Clear only error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
