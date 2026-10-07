import 'dart:developer';
import 'package:flutter/material.dart';
import '../model/email_auth_model.dart';
import '../repository/email_auth_repository.dart';
import '../../../Data/LocalStorage/loggedin_user.dart';
import '../../../Data/services/analytics_service.dart';
import '../../../Data/services/logger_service.dart';

class EmailAuthViewModel extends ChangeNotifier {
  final EmailAuthRepository _repository = EmailAuthRepository();

  bool _isLoading = false;
  String? _errorMessage;
  String? _email;
  bool _otpVerified = false;
  bool _userExists = false;

  // Onboarding data (for signup)
  String? _fullName;
  String? _dateOfBirth;
  String? _gender;
  String? _profileImageUrl;
  String? _lookingFor;
  List<String> _profilePhotos = [];
  double? _latitude;
  double? _longitude;
  String? _locationString;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get profileImageUrl => _profileImageUrl;
  String? get email => _email;
  bool get otpVerified => _otpVerified;
  bool get userExists => _userExists;

  /// Prefill email after Google / social verification (skips OTP send).
  void setVerifiedEmail(String email) {
    _email = email.trim();
    _otpVerified = true;
    notifyListeners();
  }

  /// Completes backend session after Firebase Google sign-in.
  Future<bool> googleLogin({
    required String idToken,
    required String email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _email = email.trim();
    notifyListeners();

    try {
      final response = await _repository.googleLogin(
        idToken: idToken,
        email: _email!,
      );
      _isLoading = false;

      if (response.status && response.data != null) {
        LoggedInUser.id = response.data!.user.id;
        LoggedInUser.accessToken = response.data!.tokens.access.token;
        LoggedInUser.refreshToken = response.data!.tokens.refresh.token;
        await LoggedInUser.storeUserLocally();
        AnalyticsService.instance.logLogin(method: 'google');
        AnalyticsService.instance.setUserId(response.data!.user.id);
        LoggerService.instance.setUserId(response.data!.user.id);
        notifyListeners();
        return true;
      }

      _errorMessage = response.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Send OTP to email
  Future<bool> sendEmailOtp(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _email = email;
      final response = await _repository.sendEmailOtp(email);

      _isLoading = false;

      if (response.status) {
        log('✅ OTP sent successfully');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        log('❌ Send OTP failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Send OTP error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (_email == null) {
      _errorMessage = 'Email not found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.verifyEmailOtp(
        email: _email!,
        otp: otp,
      );

      _isLoading = false;

      if (response.status && response.data?.isVerified == true) {
        _otpVerified = true;
        log('✅ OTP verified successfully');
        AnalyticsService.instance.logOtpVerified(method: 'email');
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        log('❌ Verify OTP failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Verify OTP error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Check if user exists
  Future<bool> checkUserExists() async {
    if (_email == null) {
      _errorMessage = 'Email not found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.checkUserExists(_email!);

      _isLoading = false;

      if (response.status) {
        _userExists = response.data?.userExists ?? false;
        log('✅ User exists check: $_userExists');
        notifyListeners();
        return _userExists;
      } else {
        _errorMessage = response.message;
        log('❌ Check user failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Check user error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Email login
  Future<bool> emailLogin(String otp) async {
    if (_email == null) {
      _errorMessage = 'Email not found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.emailLogin(email: _email!, otp: otp);

      _isLoading = false;

      if (response.status && response.data != null) {
        // Save tokens
        LoggedInUser.id = response.data!.user.id;
        LoggedInUser.accessToken = response.data!.tokens.access.token;
        LoggedInUser.refreshToken = response.data!.tokens.refresh.token;
        await LoggedInUser.storeUserLocally();

        log('✅ Email login successful');
        log('   User ID: ${response.data!.user.id}');
        AnalyticsService.instance.logLogin(method: 'email');
        AnalyticsService.instance.setUserId(response.data!.user.id);
        LoggerService.instance.setUserId(response.data!.user.id);

        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        log('❌ Email login failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Email login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Set onboarding data
  void setProfileImageUrl(String url) {
    _profileImageUrl = url;
    notifyListeners();
  }

  void setFullName(String name) => _fullName = name;
  void setDateOfBirth(String dob) => _dateOfBirth = dob;
  void setGender(String gender) => _gender = gender;
  void setLookingFor(String lookingFor) => _lookingFor = lookingFor;
  void setProfilePhotos(List<String> photos) => _profilePhotos = photos;
  void setLocation(double lat, double lng, String locationStr) {
    _latitude = lat;
    _longitude = lng;
    _locationString = locationStr;
  }

  Future<void> _ensureLocation() async {
    if (_latitude != null &&
        _longitude != null &&
        _locationString != null &&
        _locationString!.trim().isNotEmpty) {
      return;
    }
    if (LoggedInUser.lat != null && LoggedInUser.long != null) {
      _latitude = LoggedInUser.lat;
      _longitude = LoggedInUser.long;
      if (_locationString == null || _locationString!.trim().isEmpty) {
        _locationString =
            '${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}';
      }
      return;
    }
    throw Exception(
      'Location is required. Please allow location access and try again.',
    );
  }

  // Email signup
  Future<bool> emailSignup() async {
    if (_email == null) {
      _errorMessage = 'Email not found';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _ensureLocation();

      final request = EmailSignupRequest(
        fullName: _fullName ?? '',
        email: _email!,
        gender: _gender ?? '',
        dateOfBirth: _dateOfBirth ?? '',
        // profileImageUrl: _profilePhotos.isNotEmpty
        // ? _profilePhotos.first
        //     : null,
        profileImageUrl: _profileImageUrl,
        relationshipGoals: _lookingFor != null ? [_lookingFor!] : null,
        profilePhotos: _profilePhotos.isNotEmpty ? _profilePhotos : null,
        currentLat: _latitude,
        currentLng: _longitude,
        currentLocationString: _locationString,
        lat: _latitude,
        lng: _longitude,
        locationString: _locationString,
      );

      final response = await _repository.emailSignup(request);

      _isLoading = false;

      if (response.status && response.data != null) {
        // Save tokens
        LoggedInUser.id = response.data!.user.id;
        LoggedInUser.accessToken = response.data!.tokens.access.token;
        LoggedInUser.refreshToken = response.data!.tokens.refresh.token;
        await LoggedInUser.storeUserLocally();

        log('✅ Email signup successful');
        AnalyticsService.instance.logSignup(method: 'email');
        AnalyticsService.instance.logProfileCompleted();
        AnalyticsService.instance.setUserId(response.data!.user.id);
        LoggerService.instance.setUserId(response.data!.user.id);
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        log('❌ Email signup failed: ${response.message}');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Email signup error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear data
  void clearData() {
    _email = null;
    _otpVerified = false;
    _userExists = false;
    _fullName = null;
    _dateOfBirth = null;
    _gender = null;
    _lookingFor = null;
    _profilePhotos = [];
    _errorMessage = null;
    notifyListeners();
  }
}
