import 'dart:developer';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/services/analytics_service.dart';
import 'package:everqpidapp/Data/services/logger_service.dart';
import 'package:everqpidapp/Features/onboarding/model/sign_up_model.dart';
import 'package:everqpidapp/Features/onboarding/repository/sign_up_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';

class SignupViewModel extends ChangeNotifier {
  final SignupRepository _repository = SignupRepository();

  bool _isLoading = false;
  String? _errorMessage;
  SignupResponse? _signupResponse;

  // Onboarding data collection
  String? _fullName;
  String? _dateOfBirth;
  String? _gender;
  String? _lookingFor;
  String? _profileImageUrl;
  List<String>? _profilePhotos;
  // Location data
  double? _latitude;
  double? _longitude;
  String? _locationString;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SignupResponse? get signupResponse => _signupResponse;
  String? get fullName => _fullName;
  String? get dateOfBirth => _dateOfBirth;
  String? get gender => _gender;
  String? get lookingFor => _lookingFor;
  String? get profileImageUrl => _profileImageUrl;
  List<String>? get profilePhotos => _profilePhotos;
  String? get locationString => _locationString;

  // Setters for onboarding data
  void setFullName(String name) {
    _fullName = name;
    notifyListeners();
  }

  void setDateOfBirth(String dob) {
    // Accept either yyyy-MM-dd or DateTime.toString() leftovers.
    final parsed = DateTime.tryParse(dob);
    _dateOfBirth = parsed != null
        ? '${parsed.year.toString().padLeft(4, '0')}-'
            '${parsed.month.toString().padLeft(2, '0')}-'
            '${parsed.day.toString().padLeft(2, '0')}'
        : dob;
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setLookingFor(String lookingFor) {
    _lookingFor = lookingFor;
    notifyListeners();
  }

  void setProfileImageUrl(String url) {
    _profileImageUrl = url;
    notifyListeners();
  }

  void setProfilePhotos(List<String> photos) {
    _profilePhotos = photos;
    notifyListeners();
  }

  void setLocation(double lat, double lng, String locationStr) {
    _latitude = lat;
    _longitude = lng;
    _locationString = locationStr;
    notifyListeners();
  }

  Future<void> _ensureLocation() async {
    if (_latitude != null &&
        _longitude != null &&
        _locationString != null &&
        _locationString!.trim().isNotEmpty) {
      return;
    }
    // Prefer coords from the login/signup Allow prompt.
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

  // Main signup method
  Future<bool> performSignup({
    required String countryCode,
    required String mobileNumber,
    String? email,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate required fields
      if (_fullName == null || _fullName!.isEmpty) {
        throw Exception('Full name is required');
      }
      if (_dateOfBirth == null || _dateOfBirth!.isEmpty) {
        throw Exception('Date of birth is required');
      }
      if (_gender == null || _gender!.isEmpty) {
        throw Exception('Gender is required');
      }

      await _ensureLocation();

      // Create signup request
      final request = SignupRequest(
        fullName: _fullName!,
        email: email,
        countryCode: countryCode,
        mobileNumber: mobileNumber,
        profileImageUrl: _profileImageUrl,
        profilePhotos: _profilePhotos,
        gender: _gender!,
        dateOfBirth: _dateOfBirth!,
        aboutMe: '', // Can be added later in profile completion
        isCurrentLocationAndHomeSame: true,
        currentLocationString: _locationString,
        currentLat: _latitude,
        currentLng: _longitude,
        locationString: _locationString,
        lat: _latitude,
        lng: _longitude,
        relationshipGoals: _lookingFor != null ? [_lookingFor!] : null,
        isVerified: false,
      );

      log('🚀 Starting signup process...');
      AppLogger.d('🚀 Starting signup process...');

      final response = await _repository.signup(request);
      AppLogger.d(
        '📥 Signup parsed: status=${response.status}, '
        'code=${response.statusCode}, message=${response.message}, '
        'hasData=${response.data != null}',
      );

      if (response.status && response.data != null) {
        _signupResponse = response;

        final access = response.data!.tokens.access.token;
        final refresh = response.data!.tokens.refresh.token;

        LoggedInUser.id = response.data!.user.id;
        LoggedInUser.accessToken = access;
        LoggedInUser.refreshToken = refresh;
        LoggedInUser.name = response.data!.user.fullName;

        // Must finish before navigating — otherwise MainScreen APIs can 401
        // and the auth interceptor sends the user back to login/splash.
        await LoggedInUser.storeUserLocally();

        if (access.isEmpty || refresh.isEmpty) {
          throw Exception('Signup succeeded but tokens were missing');
        }

        AppLogger.d('✅ Signup successful! userId=${LoggedInUser.id}');
        log('✅ Signup successful!');
        AnalyticsService.instance.logSignup(method: 'phone');
        AnalyticsService.instance.logProfileCompleted();
        AnalyticsService.instance.setUserId(LoggedInUser.id);
        LoggerService.instance.setUserId(LoggedInUser.id);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response.message.isNotEmpty ? response.message : 'Signup failed';
        AppLogger.d('❌ Signup failed: $_errorMessage');
        log('❌ Signup failed: ${response.message}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e, st) {
      _errorMessage = e.toString();
      AppLogger.d('❌ Signup error: $e');
      AppLogger.d('$st');
      log('❌ Signup error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear all data
  void clearData() {
    _fullName = null;
    _dateOfBirth = null;
    _gender = null;
    _lookingFor = null;
    _profilePhotos = null;
    _latitude = null;
    _longitude = null;
    _locationString = null;
    _errorMessage = null;
    _signupResponse = null;
    notifyListeners();
  }
}
