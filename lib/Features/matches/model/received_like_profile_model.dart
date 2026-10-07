import 'package:everqpidapp/Features/common_widgets/base_profile.dart';

class ReceivedLikeProfile implements BaseProfile {
  @override
  final String id;
  @override
  final String fullName;
  @override
  final String profileImageUrl;
  @override
  final List<String> profilePhotos;
  @override
  final int age;
  @override
  final String? education;
  @override
  final String? aboutMe;
  @override
  final String? locationString;
  @override
  final int? height;
  @override
  final String relationshipStatus;
  @override
  final List<String> otherLanguages;
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
  final List<String> interests;
  @override
  final String currentProfession;
  final String companyName;
  final String roleInCompany;
  final String gender;
  final bool isLiked;
  @override
  final bool isVerified; // Added isVerified field

  ReceivedLikeProfile({
    required this.id,
    required this.fullName,
    required this.profileImageUrl,
    required this.profilePhotos,
    required this.age,
    required this.education,
    required this.aboutMe,
    required this.locationString,
    required this.height,
    required this.relationshipStatus,
    required this.otherLanguages,
    required this.interests,
    required this.zodiacSign,
    required this.alcoholConsumption,
    required this.smokingHabit,
    required this.workoutFrequency,
    required this.currentProfession,
    required this.companyName,
    required this.roleInCompany,
    required this.gender,
    required this.isLiked,
    required this.isVerified,
    required this.religion,
  });

  factory ReceivedLikeProfile.fromJson(Map<String, dynamic> json) {
    return ReceivedLikeProfile(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      profilePhotos:
          (json['profilePhotos'] as List?)?.map((e) => e.toString()).toList() ??
              [],
      age: json['age'] ?? 0,
      zodiacSign: json['zodiacSign'] ?? '',
      alcoholConsumption: json['alcoholConsumption'] ?? '',
      smokingHabit: json['smokingHabit'] ?? '',
      workoutFrequency: json['workoutFrequency'] ?? '',
      education: json['education'],
      aboutMe: json['aboutMe'],
      locationString: json['locationString'],
      height: json['height'],
      relationshipStatus: json['relationshipStatus'] ?? '',
      otherLanguages: (json['otherLanguages'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      interests:
          (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? [],
      currentProfession: json['currentProfession'] ?? '',
      companyName: json['companyName'] ?? '',
      roleInCompany: json['roleInCompany'] ?? '',
      gender: json['gender'] ?? '',
      isLiked: json['isLiked'] ?? false,
      isVerified: json['isVerified'] ?? false,
      religion: json['religion'],
    );
  }
}
