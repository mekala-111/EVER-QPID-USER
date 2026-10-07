import 'package:everqpidapp/Features/common_widgets/base_profile.dart';

class LikedProfilesResponse {
  final List<LikedProfileData> likedProfiles;
  final bool hasNext;
  final int totalCount;

  LikedProfilesResponse({
    required this.likedProfiles,
    required this.hasNext,
    required this.totalCount,
  });

  factory LikedProfilesResponse.fromJson(Map<String, dynamic> json) {
    return LikedProfilesResponse(
      likedProfiles: (json['likedProfiles'] as List<dynamic>?)
              ?.map((e) => LikedProfileData.fromJson(e))
              .toList() ??
          [],
      hasNext: json['hasNext'] ?? false,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

class LikedProfileData implements BaseProfile {
  @override
  final String id;

  @override
  final String fullName;

  final String? _profileImageUrl;

  final String gender;
  final String dateOfBirth;

  @override
  final String? aboutMe;

  @override
  final String? locationString;
  final double? lat;
  final double? lng;

  final List<String> relationshipGoals;
  @override
  final String? relationshipStatus;
  @override
  final String? religion;

  @override
  final int? height;

  @override
  final List<String> otherLanguages;

  @override
  final List<String> interests;
  @override
  final String? zodiacSign;
  @override
  final String? alcoholConsumption;
  @override
  final String? smokingHabit;
  @override
  final String? workoutFrequency;

  @override
  final String currentProfession;

  final String? companyName;
  final String? roleInCompany;
  final String? employmentType;

  @override
  final String? education;

  final String? collegeName;
  final int? graduationYear;
  final bool currentlyStudying;

  @override
  final List<String> profilePhotos;

  @override
  final bool isVerified;

  final bool isOnline;
  final String? lastActive;

  LikedProfileData({
    required this.id,
    required this.fullName,
    String? profileImageUrl,
    required this.gender,
    required this.dateOfBirth,
    this.aboutMe,
    this.locationString,
    this.lat,
    this.lng,
    required this.zodiacSign,
    required this.alcoholConsumption,
    required this.smokingHabit,
    required this.workoutFrequency,
    required this.relationshipGoals,
    this.relationshipStatus,
    this.religion,
    this.height,
    required this.otherLanguages,
    required this.interests,
    required this.currentProfession,
    this.companyName,
    this.roleInCompany,
    this.employmentType,
    this.education,
    this.collegeName,
    this.graduationYear,
    this.currentlyStudying = false,
    required this.profilePhotos,
    required this.isVerified,
    this.isOnline = false,
    this.lastActive,
  }) : _profileImageUrl = profileImageUrl;

  // -------- BaseProfile getters --------

  @override
  String get profileImageUrl => _profileImageUrl ?? '';

  /// 🔥 Calculate age from DOB
  @override
  int get age {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month ||
          (now.month == dob.month && now.day < dob.day)) {
        age--;
      }
      return age;
    } catch (_) {
      return 0;
    }
  }

  // -------- Factory --------

  factory LikedProfileData.fromJson(Map<String, dynamic> json) {
    return LikedProfileData(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      gender: json['gender'] ?? '',
      zodiacSign: json['zodiacSign'] ?? '',
      alcoholConsumption: json['alcoholConsumption'] ?? '',
      smokingHabit: json['smokingHabit'] ?? '',
      workoutFrequency: json['workoutFrequency'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      aboutMe: json['aboutMe'],
      locationString: json['locationString'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      relationshipGoals: List<String>.from(json['relationshipGoals'] ?? []),
      relationshipStatus: json['relationshipStatus'],
      religion: json['religion'],
      height: json['height'],
      otherLanguages: List<String>.from(json['otherLanguages'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      currentProfession: json['currentProfession'] ?? '',
      companyName: json['companyName'],
      roleInCompany: json['roleInCompany'],
      employmentType: json['employmentType'],
      education: json['education'],
      collegeName: json['collegeName'],
      graduationYear: json['graduationYear'],
      currentlyStudying: json['currentlyStudying'] ?? false,
      profilePhotos: List<String>.from(json['profilePhotos'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'],
    );
  }
}
