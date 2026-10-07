// features/profile/view_model/update_profile_view_model.dart

import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../model/profile_model.dart';
import '../repository/profile_repository.dart';
import '../../../Data/LocalStorage/loggedin_user.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  bool _isLoading = false;
  bool _isUploadingPhotos = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  UserProfile? _userProfile;

  // Original profile data (deep copy for comparison)
  Map<String, dynamic> _originalData = {};

  // Current draft data
  String? _fullName;
  String? _countryCode;
  String? _mobileNumber;
  String? _dateOfBirth;
  String? _gender;
  String? _aboutMe;
  String? _relationshipStatus;
  String? _religion;
  String? _zodiacSign;
  String? _alcoholConsumption;
  String? _smokingHabit;
  String? _workoutFrequency;
  int? _height;
  List<String> _otherLanguages = [];
  List<String> _interests = [];
  List<String> _relationshipGoals = [];
  String? _currentProfession;
  String? _companyName;
  String? _roleInCompany;
  String? _employmentType;
  String? _education;
  String? _collegeName;
  int? _graduationYear;
  bool _currentlyStudying = false;
  List<String> _profilePhotos = [];

  double? _latitude;
  double? _longitude;
  String? _locationString;

  // Getters
  bool get isLoading => _isLoading;
  bool get isUploadingPhotos => _isUploadingPhotos;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;

  String? get fullName => _fullName;
  String? get countryCode => _countryCode;
  String? get mobileNumber => _mobileNumber;
  String? get dateOfBirth => _dateOfBirth;
  String? get gender => _gender;
  String? get aboutMe => _aboutMe;
  String? get relationshipStatus => _relationshipStatus;
  String? get religion => _religion;
  String? get zodiacSign => _zodiacSign;
  String? get alcoholConsumption => _alcoholConsumption;
  String? get smokingHabit => _smokingHabit;
  String? get workoutFrequency => _workoutFrequency;
  int? get height => _height;
  List<String> get otherLanguages => _otherLanguages;
  List<String> get interests => _interests;
  List<String> get relationshipGoals => _relationshipGoals;
  String? get currentProfession => _currentProfession;
  String? get companyName => _companyName;
  String? get roleInCompany => _roleInCompany;
  String? get employmentType => _employmentType;
  String? get education => _education;
  String? get collegeName => _collegeName;
  int? get graduationYear => _graduationYear;
  bool get currentlyStudying => _currentlyStudying;
  List<String> get profilePhotos => _profilePhotos;
  String? get locationString => _locationString;

  // Load from profile and create deep copy of original data
  void loadFromProfile(dynamic profile) {
    if (profile == null) return;

    Map<String, dynamic> data = {};

    if (profile is Map<String, dynamic>) {
      data = profile;
    } else {
      data = {
        'fullName': profile.fullName,
        'countryCode': profile.countryCode,
        'mobileNumber': profile.phoneNumber ?? profile.mobileNumber,
        'dateOfBirth': profile.dateOfBirth,
        'gender': profile.gender,
        'aboutMe': profile.aboutMe,
        'relationshipStatus': profile.relationshipStatus,
        'religion': profile.religion,
        'height': profile.height,
        'otherLanguages': profile.otherLanguages,
        'interests': profile.interests,
        'relationshipGoals': profile.relationshipGoals,
        'currentProfession': profile.currentProfession,
        'companyName': profile.companyName,
        'roleInCompany': profile.roleInCompany,
        'employmentType': profile.employmentType,
        'education': profile.education,
        'collegeName': profile.collegeName,
        'graduationYear': profile.graduationYear,
        'currentlyStudying': profile.currentlyStudying,
        'profilePhotos': profile.profilePhotos,
        'lat': profile.lat,
        'lng': profile.lng,
        'locationString': profile.locationString,
      };
    }

    // Parse height safely - handle both String and int from backend
    int? parsedHeight;
    if (data['height'] != null) {
      if (data['height'] is int) {
        parsedHeight = data['height'];
      } else if (data['height'] is String) {
        final heightStr = data['height'] as String;
        final numericPart = heightStr.replaceAll(RegExp(r'[^0-9]'), '');
        parsedHeight = int.tryParse(numericPart);
      }
    }

    // Deep copy original data
    _originalData = {
      'fullName': data['fullName'],
      'countryCode': data['countryCode'],
      'mobileNumber': data['mobileNumber'],
      'dateOfBirth': data['dateOfBirth'],
      'gender': data['gender'],
      'aboutMe': data['aboutMe'],
      'relationshipStatus': data['relationshipStatus'],
      'religion': data['religion'],
      'height': parsedHeight,
      'otherLanguages': data['otherLanguages'] != null
          ? List<String>.from(data['otherLanguages'])
          : <String>[],
      'interests': data['interests'] != null
          ? List<String>.from(data['interests'].where((x) => x != null))
          : <String>[],
      'relationshipGoals': data['relationshipGoals'] != null
          ? List<String>.from(data['relationshipGoals'])
          : <String>[],
      'currentProfession': data['currentProfession'],
      'companyName': data['companyName'],
      'roleInCompany': data['roleInCompany'],
      'employmentType': data['employmentType'],
      'education': data['education'],
      'collegeName': data['collegeName'],
      'graduationYear': data['graduationYear'],
      'currentlyStudying': data['currentlyStudying'],
      'profilePhotos': data['profilePhotos'] != null
          ? List<String>.from(data['profilePhotos'])
          : <String>[],
      'lat': data['lat'],
      'lng': data['lng'],
      'locationString': data['locationString'],
    };

    // Load current draft
    _fullName = data['fullName'];
    _countryCode = data['countryCode'] ?? '+91';
    _mobileNumber = data['mobileNumber'];
    _dateOfBirth = data['dateOfBirth'];
    _gender = data['gender'];
    _aboutMe = data['aboutMe'];
    _relationshipStatus = data['relationshipStatus'];
    _religion = data['religion'];
    _height = parsedHeight;
    _otherLanguages = List<String>.from(_originalData['otherLanguages']);
    _interests = List<String>.from(_originalData['interests']);
    _relationshipGoals = List<String>.from(_originalData['relationshipGoals']);
    _currentProfession = data['currentProfession'];
    _companyName = data['companyName'];
    _roleInCompany = data['roleInCompany'];
    _employmentType = data['employmentType'];
    _education = data['education'];
    _collegeName = data['collegeName'];
    _graduationYear = data['graduationYear'];
    _currentlyStudying = data['currentlyStudying'] ?? false;
    _profilePhotos = List<String>.from(_originalData['profilePhotos']);
    _latitude = data['lat']?.toDouble();
    _longitude = data['lng']?.toDouble();
    _locationString = data['locationString'];

    log(
      '📋 Profile loaded - Name: $_fullName, Phone: $_mobileNumber, Height: $_height, Photos: ${_profilePhotos.length}',
    );
    notifyListeners();
  }

  // Deep comparison for lists
  bool _listsEqual(List? a, List? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Check if field changed
  bool _hasChanged(String key, dynamic currentValue) {
    final originalValue = _originalData[key];

    if (currentValue is List && originalValue is List) {
      return !_listsEqual(currentValue, originalValue);
    }

    if (currentValue is String && currentValue.isEmpty) {
      return originalValue != null && originalValue != '';
    }

    return currentValue != originalValue;
  }

  // Build update payload with only changed fields
  Map<String, dynamic> _getChangedFields() {
    final changes = <String, dynamic>{};

    final userId = LoggedInUser.id;
    if (userId != null) {
      changes['userId'] = userId;
    }

    if (_hasChanged('fullName', _fullName) &&
        _fullName != null &&
        _fullName!.isNotEmpty) {
      changes['fullName'] = _fullName;
      log('   Changed: fullName = $_fullName');
    }
    if (_hasChanged('zodiacSign', _zodiacSign) &&
        _zodiacSign != null &&
        _zodiacSign!.isNotEmpty) {
      changes['zodiacSign'] = _zodiacSign;
      log('   Changed: zodiacSign = $_zodiacSign');
    }
    if (_hasChanged('alcoholConsumption', _alcoholConsumption) &&
        _alcoholConsumption != null &&
        _alcoholConsumption!.isNotEmpty) {
      changes['alcoholConsumption'] = _alcoholConsumption;
      log('   Changed: alcoholConsumption = $_alcoholConsumption');
    }
    if (_hasChanged('smokingHabit', _smokingHabit) &&
        _smokingHabit != null &&
        _smokingHabit!.isNotEmpty) {
      changes['smokingHabit'] = _smokingHabit;
      log('   Changed: smokingHabit = $_smokingHabit');
    }
    if (_hasChanged('workoutFrequency', _workoutFrequency) &&
        _workoutFrequency != null &&
        _workoutFrequency!.isNotEmpty) {
      changes['workoutFrequency'] = _workoutFrequency;
      log('   Changed: workoutFrequency = $_workoutFrequency');
    }

    if (_hasChanged('mobileNumber', _mobileNumber)) {
      changes['countryCode'] = _countryCode;
      changes['mobileNumber'] = _mobileNumber;
      log('   Changed: mobileNumber = $_countryCode $_mobileNumber');
    }

    if (_hasChanged('dateOfBirth', _dateOfBirth) && _dateOfBirth != null) {
      changes['dateOfBirth'] = _dateOfBirth;
      log('   Changed: dateOfBirth = $_dateOfBirth');
    }

    if (_hasChanged('gender', _gender) && _gender != null) {
      changes['gender'] = _gender;
      log('   Changed: gender = $_gender');
    }

    if (_hasChanged('aboutMe', _aboutMe)) {
      changes['aboutMe'] = _aboutMe ?? '';
      log('   Changed: aboutMe');
    }

    if (_hasChanged('relationshipStatus', _relationshipStatus)) {
      changes['relationshipStatus'] = _relationshipStatus;
      log('   Changed: relationshipStatus = $_relationshipStatus');
    }

    if (_hasChanged('religion', _religion)) {
      changes['religion'] = _religion;
      log('   Changed: religion = $_religion');
    }

    if (_hasChanged('height', _height)) {
      changes['height'] = _height;
      log('   Changed: height = $_height');
    }

    if (_hasChanged('otherLanguages', _otherLanguages)) {
      changes['otherLanguages'] = _otherLanguages;
      log('   Changed: otherLanguages = ${_otherLanguages.join(", ")}');
    }

    if (_hasChanged('interests', _interests)) {
      changes['interests'] = _interests;
      log('   Changed: interests = ${_interests.join(", ")}');
    }

    if (_hasChanged('relationshipGoals', _relationshipGoals)) {
      changes['relationshipGoals'] = _relationshipGoals;
      log('   Changed: relationshipGoals = ${_relationshipGoals.join(", ")}');
    }

    if (_hasChanged('currentProfession', _currentProfession)) {
      changes['currentProfession'] = _currentProfession;
      log('   Changed: currentProfession = $_currentProfession');
    }

    if (_hasChanged('companyName', _companyName)) {
      changes['companyName'] = _companyName;
      log('   Changed: companyName = $_companyName');
    }

    if (_hasChanged('roleInCompany', _roleInCompany)) {
      changes['roleInCompany'] = _roleInCompany;
      log('   Changed: roleInCompany = $_roleInCompany');
    }

    if (_hasChanged('employmentType', _employmentType)) {
      changes['employmentType'] = _employmentType;
      log('   Changed: employmentType = $_employmentType');
    }

    if (_hasChanged('education', _education)) {
      changes['education'] = _education;
      log('   Changed: education = $_education');
    }

    if (_hasChanged('collegeName', _collegeName)) {
      changes['collegeName'] = _collegeName;
      log('   Changed: collegeName = $_collegeName');
    }

    if (_hasChanged('graduationYear', _graduationYear)) {
      changes['graduationYear'] = _graduationYear;
      log('   Changed: graduationYear = $_graduationYear');
    }

    if (_hasChanged('currentlyStudying', _currentlyStudying)) {
      changes['currentlyStudying'] = _currentlyStudying;
      log('   Changed: currentlyStudying = $_currentlyStudying');
    }

    if (_hasChanged('profilePhotos', _profilePhotos)) {
      if (_profilePhotos.isNotEmpty) {
        changes['profilePhotos'] = _profilePhotos;
        changes['profileImageUrl'] = _profilePhotos.first;
        log('   Changed: profilePhotos (${_profilePhotos.length} photos)');
      }
    }

    if (_hasChanged('lat', _latitude) ||
        _hasChanged('lng', _longitude) ||
        _hasChanged('locationString', _locationString)) {
      changes['isCurrentLocationAndHomeSame'] = true;
      if (_locationString != null) {
        changes['currentLocationString'] = _locationString;
        changes['locationString'] = _locationString;
      }
      if (_latitude != null) {
        changes['currentLat'] = _latitude;
        changes['lat'] = _latitude;
      }
      if (_longitude != null) {
        changes['currentLng'] = _longitude;
        changes['lng'] = _longitude;
      }
      log('   Changed: location');
    }

    return changes;
  }

  // Setters
  void setFullName(String name) {
    _fullName = name;
    notifyListeners();
  }

  void setPhoneNumber(String countryCode, String number) {
    _countryCode = countryCode;
    _mobileNumber = number;
    notifyListeners();
  }

  void setAboutMe(String about) {
    _aboutMe = about;
    notifyListeners();
  }

  void setDateOfBirth(String dob) {
    _dateOfBirth = dob;
    notifyListeners();
  }

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }

  void setRelationshipStatus(String status) {
    _relationshipStatus = status;
    notifyListeners();
  }

  void setReligion(String religion) {
    _religion = religion;
    notifyListeners();
  }

  void setZodiacSign(String sign) {
    _zodiacSign = sign;
    notifyListeners();
  }

  void setAlcoholConsumption(String consumption) {
    _alcoholConsumption = consumption;
    notifyListeners();
  }

  void setSmokingHabit(String habit) {
    _smokingHabit = habit;
    notifyListeners();
  }

  void setWorkoutFrequency(String frequency) {
    _workoutFrequency = frequency;
    notifyListeners();
  }

  void setHeight(int height) {
    _height = height;
    notifyListeners();
  }

  void setLanguages(List<String> languages) {
    _otherLanguages = List<String>.from(languages);
    notifyListeners();
  }

  void setInterests(List<String> interests) {
    _interests = List<String>.from(interests);
    notifyListeners();
  }

  void setRelationshipGoals(List<String> goals) {
    _relationshipGoals = List<String>.from(goals);
    notifyListeners();
  }

  void setWorkInfo({
    String? profession,
    String? company,
    String? role,
    String? employmentType,
  }) {
    if (profession != null) _currentProfession = profession;
    if (company != null) _companyName = company;
    if (role != null) _roleInCompany = role;
    if (employmentType != null) _employmentType = employmentType;
    notifyListeners();
  }

  void setEducationInfo({
    String? education,
    String? college,
    int? graduationYear,
    bool? currentlyStudying,
  }) {
    if (education != null) _education = education;
    if (college != null) _collegeName = college;
    if (graduationYear != null) _graduationYear = graduationYear;
    if (currentlyStudying != null) _currentlyStudying = currentlyStudying;
    notifyListeners();
  }

  void setLocation(double lat, double lng, String locationStr) {
    _latitude = lat;
    _longitude = lng;
    _locationString = locationStr;
    notifyListeners();
  }

  // NEW: Set profile photos directly (called from UI after building final list)
  void setProfilePhotos(List<String> photoUrls) {
    _profilePhotos = List<String>.from(photoUrls);
    log('📸 Profile photos updated: ${_profilePhotos.length} photos');
    notifyListeners();
  }

  // NEW: Upload single photo (slot-specific upload)
  Future<String?> uploadSinglePhoto(Uint8List bytes) async {
    _isUploadingPhotos = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final url = await _repository.uploadPhotoToS3(
        bytes,
        fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      _uploadProgress = 1.0;
      _isUploadingPhotos = false;
      notifyListeners();

      log('✅ Single photo uploaded: $url');
      return url;
    } catch (e) {
      log('❌ Single photo upload error: $e');
      _errorMessage = e.toString();
      _isUploadingPhotos = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return null;
    }
  }

  // DEPRECATED: Use uploadSinglePhoto() instead
  // Kept for backwards compatibility
  @deprecated
  Future<List<String>> uploadPhotos(List<Uint8List?> files) async {
    _isUploadingPhotos = true;
    _uploadProgress = 0.0;
    _errorMessage = null;
    notifyListeners();

    try {
      final validFiles =
          files.whereType<Uint8List>().where((b) => b.isNotEmpty).toList();
      if (validFiles.isEmpty) {
        throw Exception('No valid files to upload');
      }

      final urls = <String>[];
      for (int i = 0; i < validFiles.length; i++) {
        final url = await _repository.uploadPhotoToS3(
          validFiles[i],
          fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        urls.add(url);
        _uploadProgress = (i + 1) / validFiles.length;
        notifyListeners();
      }

      _profilePhotos = urls;
      log('✅ Photos uploaded: ${urls.length}');

      _isUploadingPhotos = false;
      notifyListeners();
      return urls;
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Photo upload error: $e');
      _isUploadingPhotos = false;
      _uploadProgress = 0.0;
      notifyListeners();
      return [];
    }
  }

  // Update profile
  Future<bool> updateProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userId = LoggedInUser.id;
      if (userId == null) {
        throw Exception('User ID not found');
      }

      final changedFields = _getChangedFields();

      if (changedFields.length <= 1) {
        log('⚠️ No changes detected');
        _isLoading = false;
        notifyListeners();
        return true;
      }

      log('🚀 Updating profile...');
      log('   Changed fields: ${changedFields.keys.join(", ")}');

      final response = await _repository.updateProfilePartial(changedFields);

      if (response.status && response.data != null) {
        _userProfile = response.data!.updatedProfile;

        // Update original data with new values
        _syncOriginalData();

        log('✅ Profile updated successfully');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        log('❌ Update failed: ${response.message}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      log('❌ Update error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sync original data after successful update
  void _syncOriginalData() {
    _originalData = {
      'fullName': _fullName,
      'countryCode': _countryCode,
      'mobileNumber': _mobileNumber,
      'dateOfBirth': _dateOfBirth,
      'gender': _gender,
      'aboutMe': _aboutMe,
      'relationshipStatus': _relationshipStatus,
      'religion': _religion,
      'height': _height,
      'otherLanguages': List<String>.from(_otherLanguages),
      'interests': List<String>.from(_interests),
      'relationshipGoals': List<String>.from(_relationshipGoals),
      'currentProfession': _currentProfession,
      'companyName': _companyName,
      'roleInCompany': _roleInCompany,
      'employmentType': _employmentType,
      'education': _education,
      'collegeName': _collegeName,
      'graduationYear': _graduationYear,
      'currentlyStudying': _currentlyStudying,
      'profilePhotos': List<String>.from(_profilePhotos),
      'lat': _latitude,
      'lng': _longitude,
      'locationString': _locationString,
    };
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearData() {
    _fullName = null;
    _aboutMe = null;
    _dateOfBirth = null;
    _gender = null;
    _relationshipStatus = null;
    _religion = null;
    _height = null;
    _otherLanguages = [];
    _interests = [];
    _relationshipGoals = [];
    _currentProfession = null;
    _companyName = null;
    _roleInCompany = null;
    _employmentType = null;
    _education = null;
    _collegeName = null;
    _graduationYear = null;
    _currentlyStudying = false;
    _profilePhotos = [];
    _errorMessage = null;
    _originalData = {};
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isUploadingPhotos = false;
    _uploadProgress = 0.0;
    _errorMessage = null;
    _userProfile = null;
    _originalData = {};
    _fullName = null;
    _countryCode = null;
    _mobileNumber = null;
    _dateOfBirth = null;
    _gender = null;
    _aboutMe = null;
    _relationshipStatus = null;
    _religion = null;
    _height = null;
    _otherLanguages = [];
    _interests = [];
    _relationshipGoals = [];
    _currentProfession = null;
    _companyName = null;
    _roleInCompany = null;
    _employmentType = null;
    _education = null;
    _collegeName = null;
    _graduationYear = null;
    _currentlyStudying = false;
    _profilePhotos = [];
    notifyListeners();
  }
}
