// import 'package:everqpidapp/Features/common_widgets/base_profile.dart';

// class ClanProfile implements BaseProfile {
//   @override
//   final String id;
//   @override
//   final String fullName;
//   final String? email;

//   @override
//   final String? profileImageUrl;
//   final String gender;
//   final String dateOfBirth;
//   @override
//   final String? aboutMe;
//   final String? locationString;
//   final double? lat;
//   final double? lng;
//   final List<String> relationshipGoals;
//   final String? relationshipStatus;
//   final String? religion;
//   final int? height;
//   @override
//   final List<String> otherLanguages;
//   @override
//   final List<String> interests;

//   @override
//   final String currentProfession;
//   final String? companyName;
//   @override
//   final String? education;
//   final String? collegeName;
//   final int? graduationYear;
//    @override
//   final String? zodiacSign;
//   @override
//   final String? alcoholConsumption;
//   @override
//   final String? smokingHabit;
//   @override
//   final String? workoutFrequency;
//   @override
//   final List<String> profilePhotos;
//   @override
//   final bool isVerified;
//   final bool isOnline;
//   final String? lastActive;
//   final double? distance;

//   ClanProfile({
//     required this.id,
//     required this.fullName,
//     this.email,
//    required this.profileImageUrl,
//     required this.gender,
//     required this.dateOfBirth,
//     this.aboutMe,
//     this.zodiacSign,
//     this.alcoholConsumption,
//     this.smokingHabit,
//     this.workoutFrequency,
//     this.locationString,
//     this.lat,
//     this.lng,
//     required this.relationshipGoals,
//     this.relationshipStatus,
//     this.religion,
//     this.height,
//     required this.otherLanguages,
//     required this.interests,
//    required this.currentProfession,
//     this.companyName,
//     this.education,
//     this.collegeName,
//     this.graduationYear,
//     required this.profilePhotos,
//     required this.isVerified,
//     required this.isOnline,
//     this.lastActive,
//     this.distance,
//   });

//   factory ClanProfile.fromJson(Map<String, dynamic> json) {
//     return ClanProfile(
//       id: json['_id'] ?? '',
//       fullName: json['fullName'] ?? '',
//       email: json['email'],
//       profileImageUrl: json['profileImageUrl'],
//       gender: json['gender'] ?? '',
//       dateOfBirth: json['dateOfBirth'] ?? '',
//       aboutMe: json['aboutMe'],
//       locationString: json['locationString'],
//       lat: json['lat']?.toDouble(),
//       lng: json['lng']?.toDouble(),
//       zodiacSign: json['zodiacSign'],
//       alcoholConsumption: json['alcoholConsumption'],
//       smokingHabit: json['smokingHabit'],
//       workoutFrequency: json['workoutFrequency'],

//       relationshipGoals: List<String>.from(json['relationshipGoals'] ?? []),
//       relationshipStatus: json['relationshipStatus'],
//       religion: json['religion'],
//       height: json['height'],
//       otherLanguages: List<String>.from(json['otherLanguages'] ?? []),
//       interests: List<String>.from(json['interests'] ?? []),
//       currentProfession: json['currentProfession'],
//       companyName: json['companyName'],
//       education: json['education'],
//       collegeName: json['collegeName'],
//       graduationYear: json['graduationYear'],
//       profilePhotos: List<String>.from(json['profilePhotos'] ?? []),
//       isVerified: json['isVerified'] ?? false,
//       isOnline: json['isOnline'] ?? false,
//       lastActive: json['lastActive'],
//       distance: json['distance']?.toDouble(),
//     );
//   }

//   // Calculate age from dateOfBirth
//   int get age {
//     try {
//       final dob = DateTime.parse(dateOfBirth);
//       final today = DateTime.now();
//       int age = today.year - dob.year;
//       if (today.month < dob.month ||
//           (today.month == dob.month && today.day < dob.day)) {
//         age--;
//       }
//       return age;
//     } catch (e) {
//       return 0;
//     }
//   }
// }
// features/clan/model/clan_profile_model.dart

import 'package:everqpidapp/Features/common_widgets/base_profile.dart';

class ClanProfile implements BaseProfile {
  @override
  final String id;
  @override
  final String fullName;
  final String? email;

  @override
  final String? profileImageUrl;
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
  final String currentProfession;
  final String? companyName;
  @override
  final String? education;
  final String? collegeName;
  final int? graduationYear;
  @override
  final String? zodiacSign;
  @override
  final String? alcoholConsumption;
  @override
  final String? smokingHabit;
  @override
  final String? workoutFrequency;
  @override
  final List<String> profilePhotos;
  @override
  final bool isVerified;
  final bool isOnline;
  final String? lastActive;
  final double? distance;

  // New fields for search API
  final String? clanType;
  final String? city;
  final String? state;

  ClanProfile({
    required this.id,
    required this.fullName,
    this.email,
    required this.profileImageUrl,
    required this.gender,
    required this.dateOfBirth,
    this.aboutMe,
    this.zodiacSign,
    this.alcoholConsumption,
    this.smokingHabit,
    this.workoutFrequency,
    this.locationString,
    this.lat,
    this.lng,
    required this.relationshipGoals,
    this.relationshipStatus,
    this.religion,
    this.height,
    required this.otherLanguages,
    required this.interests,
    required this.currentProfession,
    this.companyName,
    this.education,
    this.collegeName,
    this.graduationYear,
    required this.profilePhotos,
    required this.isVerified,
    required this.isOnline,
    this.lastActive,
    this.distance,
    this.clanType,
    this.city,
    this.state,
  });

  factory ClanProfile.fromJson(Map<String, dynamic> json) {
    return ClanProfile(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      aboutMe: json['aboutMe'],
      locationString: json['locationString'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      zodiacSign: json['zodiacSign'],
      alcoholConsumption: json['alcoholConsumption'],
      smokingHabit: json['smokingHabit'],
      workoutFrequency: json['workoutFrequency'],
      relationshipGoals: List<String>.from(json['relationshipGoals'] ?? []),
      relationshipStatus: json['relationshipStatus'],
      religion: json['religion'],
      height: json['height'],
      otherLanguages: List<String>.from(json['otherLanguages'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      currentProfession: json['currentProfession'] ?? '',
      companyName: json['companyName'],
      education: json['education'],
      collegeName: json['collegeName'],
      graduationYear: json['graduationYear'],
      profilePhotos: List<String>.from(json['profilePhotos'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'],
      distance: json['distance']?.toDouble(),
      clanType: json['clanType'],
      city: json['city'],
      state: json['state'],
    );
  }

  @override
  int get age {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final today = DateTime.now();
      int age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}

// Response model for search API
class ClanSearchResponse {
  final bool status;
  final int statusCode;
  final String message;
  final ClanSearchData data;

  ClanSearchResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory ClanSearchResponse.fromJson(Map<String, dynamic> json) {
    return ClanSearchResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: ClanSearchData.fromJson(json['data'] ?? {}),
    );
  }
}

class ClanSearchData {
  final List<ClanProfile> users;
  final int totalCount;
  final int totalPages;

  ClanSearchData({
    required this.users,
    required this.totalCount,
    required this.totalPages,
  });

  factory ClanSearchData.fromJson(Map<String, dynamic> json) {
    return ClanSearchData(
      users: (json['users'] as List?)
              ?.map((item) => ClanProfile.fromJson(item))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}
