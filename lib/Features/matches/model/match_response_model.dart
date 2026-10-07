import 'package:everqpidapp/Features/common_widgets/base_profile.dart';

class MatchListResponse {
  final List<MatchUserProfile> matches;
  final bool hasNext;
  final int totalCount;

  MatchListResponse({
    required this.matches,
    required this.hasNext,
    required this.totalCount,
  });

  factory MatchListResponse.fromJson(Map<String, dynamic> json) {
    return MatchListResponse(
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => MatchUserProfile.fromJson(e))
              .toList() ??
          [],
      hasNext: json['hasNext'] ?? false,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

class MatchUserProfile implements BaseProfile {
  @override
  final String id;
  @override
  final String fullName;
  @override
  final String? profileImageUrl;
  @override
  final int age;
  @override
  final String? education;
  @override
  final String? aboutMe;
  @override
  final String? locationString;
  @override
  final String? relationshipStatus;
  @override
  final String? religion;
  @override
  final String? alcoholConsumption;
  @override
  final String? smokingHabit;
  @override
  final String? workoutFrequency;
  @override
  final String? zodiacSign;

  @override
  final int? height;
  @override
  final List<String>? interests;
  @override
  final List<String>? otherLanguages;
  @override
  final List<String>? profilePhotos;
  @override
  final bool isVerified;
  @override
  final String? currentProfession;

  MatchUserProfile({
    required this.locationString,
    required this.id,
    required this.fullName,
    this.profileImageUrl,
    required this.age,
    this.education,
    this.aboutMe,
    this.relationshipStatus,
    this.religion,
    this.alcoholConsumption,
    this.smokingHabit,
    this.workoutFrequency,
    this.zodiacSign,
    this.height,
    this.interests,
    this.otherLanguages,
    this.profilePhotos,
    this.currentProfession,
    required this.isVerified,
  });

  factory MatchUserProfile.fromJson(Map<String, dynamic> json) {
    return MatchUserProfile(
      locationString: json['locationString'],
      id: json['_id'] ?? "",
      currentProfession: json['currentProfession'],
      fullName: json['fullName'] ?? "",
      profileImageUrl: json['profileImageUrl'],
      zodiacSign: json['zodiacSign'],
      alcoholConsumption: json['alcoholConsumption'],
      smokingHabit: json['smokingHabit'],
      workoutFrequency: json['workoutFrequency'],
      age: json['age'] ?? 0,
      education: json['education'],
      aboutMe: json['aboutMe'],
      relationshipStatus: json['relationshipStatus'],
      religion: json['religion'],
      height: json['height'],
      interests:
          (json['interests'] as List?)?.map((e) => e.toString()).toList(),
      otherLanguages:
          (json['otherLanguages'] as List?)?.map((e) => e.toString()).toList(),
      profilePhotos:
          (json['profilePhotos'] as List?)?.map((e) => e.toString()).toList(),
      isVerified: json['isVerified'] ?? false,
    );
  }
}
