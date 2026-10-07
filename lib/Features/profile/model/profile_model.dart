// features/profile/model/profile_model.dart

class UpdateProfileRequest {
  final String userId;
  final String? fullName;
  final String? countryCode;
  final String? mobileNumber;
  final String? profileImageUrl;
  final String? gender;
  final String? dateOfBirth;
  final String? aboutMe;
  final bool? isCurrentLocationAndHomeSame;
  final String? currentLocationString;
  final double? currentLat;
  final double? currentLng;
  final String? locationString;
  final double? lat;
  final double? lng;
  final List<String>? relationshipGoals;
  final String? relationshipStatus;
  final String? religion;
  final int? height;
  final List<String>? otherLanguages;
  final List<String>? interests;
  final String? currentProfession;
  final String? companyName;
  final String? roleInCompany;
  final String? employmentType;
  final String? education;
  final String? collegeName;
  final int? graduationYear;
  final bool? currentlyStudying;
  final List<String>? profilePhotos;

  UpdateProfileRequest({
    required this.userId,
    this.fullName,
    this.countryCode,
    this.mobileNumber,
    this.profileImageUrl,
    this.gender,
    this.dateOfBirth,
    this.aboutMe,
    this.isCurrentLocationAndHomeSame,
    this.currentLocationString,
    this.currentLat,
    this.currentLng,
    this.locationString,
    this.lat,
    this.lng,
    this.relationshipGoals,
    this.relationshipStatus,
    this.religion,
    this.height,
    this.otherLanguages,
    this.interests,
    this.currentProfession,
    this.companyName,
    this.roleInCompany,
    this.employmentType,
    this.education,
    this.collegeName,
    this.graduationYear,
    this.currentlyStudying,
    this.profilePhotos,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    map['userId'] = userId;

    if (fullName != null) map['fullName'] = fullName;
    if (countryCode != null) map['countryCode'] = countryCode;
    if (mobileNumber != null) map['mobileNumber'] = mobileNumber;
    if (profileImageUrl != null) map['profileImageUrl'] = profileImageUrl;
    if (gender != null) map['gender'] = gender;
    if (dateOfBirth != null) map['dateOfBirth'] = dateOfBirth;
    if (aboutMe != null) map['aboutMe'] = aboutMe;

    if (isCurrentLocationAndHomeSame != null) {
      map['isCurrentLocationAndHomeSame'] = isCurrentLocationAndHomeSame;
    }
    if (currentLocationString != null) {
      map['currentLocationString'] = currentLocationString;
    }
    if (currentLat != null) map['currentLat'] = currentLat;
    if (currentLng != null) map['currentLng'] = currentLng;
    if (locationString != null) map['locationString'] = locationString;
    if (lat != null) map['lat'] = lat;
    if (lng != null) map['lng'] = lng;

    if (relationshipGoals != null && relationshipGoals!.isNotEmpty) {
      map['relationshipGoals'] = relationshipGoals;
    }
    if (relationshipStatus != null) {
      map['relationshipStatus'] = relationshipStatus;
    }
    if (religion != null) map['religion'] = religion;
    if (height != null) map['height'] = height;

    if (otherLanguages != null && otherLanguages!.isNotEmpty) {
      map['otherLanguages'] = otherLanguages;
    }
    if (interests != null && interests!.isNotEmpty) {
      map['interests'] = interests;
    }

    if (currentProfession != null) map['currentProfession'] = currentProfession;
    if (companyName != null) map['companyName'] = companyName;
    if (roleInCompany != null) map['roleInCompany'] = roleInCompany;
    if (employmentType != null) map['employmentType'] = employmentType;
    if (education != null) map['education'] = education;
    if (collegeName != null) map['collegeName'] = collegeName;
    if (graduationYear != null && graduationYear! > 0) {
      map['graduationYear'] = graduationYear;
    }
    if (currentlyStudying != null) map['currentlyStudying'] = currentlyStudying;

    if (profilePhotos != null && profilePhotos!.isNotEmpty) {
      map['profilePhotos'] = profilePhotos;
    }

    return map;
  }
}

class UpdateProfileResponse {
  final bool status;
  final int statusCode;
  final String message;
  final UpdateProfileData? data;

  UpdateProfileResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 500,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? UpdateProfileData.fromJson(json['data'])
          : null,
    );
  }
}

class UpdateProfileData {
  final UserProfile updatedProfile;

  UpdateProfileData({required this.updatedProfile});

  factory UpdateProfileData.fromJson(Map<String, dynamic> json) {
    return UpdateProfileData(
      updatedProfile: UserProfile.fromJson(json['updatedProfile']),
    );
  }
}

class UserProfile {
  final String id;
  final String fullName;
  final String? email;
  final String countryCode;
  final String mobileNumber;
  final String? profileImageUrl;
  final String gender;
  final String dateOfBirth;
  final String? aboutMe;
  final String? locationString;
  final double? lat;
  final double? lng;
  final List<String> relationshipGoals;
  final String? relationshipStatus;
  final String? religion;
  final int? height;
  final List<String> otherLanguages;
  final List<String> interests;
  final String? currentProfession;
  final String? companyName;
  final String? roleInCompany;
  final String? employmentType;
  final String? education;
  final String? collegeName;
  final int? graduationYear;
  final bool currentlyStudying;
  final List<String> profilePhotos;

  UserProfile({
    required this.id,
    required this.fullName,
    this.email,
    required this.countryCode,
    required this.mobileNumber,
    this.profileImageUrl,
    required this.gender,
    required this.dateOfBirth,
    this.aboutMe,
    this.locationString,
    this.lat,
    this.lng,
    this.relationshipGoals = const [],
    this.relationshipStatus,
    this.religion,
    this.height,
    this.otherLanguages = const [],
    this.interests = const [],
    this.currentProfession,
    this.companyName,
    this.roleInCompany,
    this.employmentType,
    this.education,
    this.collegeName,
    this.graduationYear,
    this.currentlyStudying = false,
    this.profilePhotos = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      countryCode: json['countryCode'] ?? '+91',
      mobileNumber: json['mobileNumber'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      aboutMe: json['aboutMe'],
      locationString: json['locationString'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      relationshipGoals: json['relationshipGoals'] != null
          ? List<String>.from(json['relationshipGoals'])
          : [],
      relationshipStatus: json['relationshipStatus'],
      religion: json['religion'],
      height: json['height'],
      otherLanguages: json['otherLanguages'] != null
          ? List<String>.from(json['otherLanguages'])
          : [],
      interests:
          json['interests'] != null ? List<String>.from(json['interests']) : [],
      currentProfession: json['currentProfession'],
      companyName: json['companyName'],
      roleInCompany: json['roleInCompany'],
      employmentType: json['employmentType'],
      education: json['education'],
      collegeName: json['collegeName'],
      graduationYear: json['graduationYear'],
      currentlyStudying: json['currentlyStudying'] ?? false,
      profilePhotos: json['profilePhotos'] != null
          ? List<String>.from(json['profilePhotos'])
          : [],
    );
  }
}
