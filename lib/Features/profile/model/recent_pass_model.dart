import 'package:everqpidapp/Features/common_widgets/base_profile.dart';

class RecentPassResponse {
  final List<RecentPassItem> users;
  final int count;
  final bool hasNext;
  final bool isSubscribed;

  RecentPassResponse({
    required this.users,
    required this.count,
    required this.hasNext,
    required this.isSubscribed,
  });

  factory RecentPassResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return RecentPassResponse(
      users: (data['users'] as List? ?? [])
          .map((e) => RecentPassItem.fromJson(e))
          .toList(),
      count: data['count'] ?? 0,
      hasNext: data['hasNext'] ?? false,
      isSubscribed: data['isSubscribed'] ?? false,
    );
  }
}

class RecentPassItem {
  final String id;
  final RecentPassUser user;

  RecentPassItem({required this.id, required this.user});

  factory RecentPassItem.fromJson(Map<String, dynamic> json) {
    return RecentPassItem(
      id: json['_id'] ?? '',
      user: RecentPassUser.fromJson(json['recentPassUser'] ?? {}),
    );
  }
}

class RecentPassUser implements BaseProfile {
  @override
  final String id;

  @override
  final String fullName;

  final String gender;
  final String dateOfBirth;

  @override
  final String? aboutMe;

  @override
  final String? locationString;
  final double? lat;
  final double? lng;
  @override
  final String? zodiacSign;
  @override
  final String? alcoholConsumption;
  @override
  final String? smokingHabit;
  @override
  final String? workoutFrequency;
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
  final String? roleInCompany;
  final String? employmentType;

  @override
  final String? education;

  final String? collegeName;
  final int? graduationYear;
  final bool currentlyStudying;

  final String? _profileImageUrl;

  @override
  final List<String> profilePhotos;

  @override
  final bool isVerified;

  final bool isOnline;
  final String? lastActive;

  /// 🔹 Extra but useful
  final Map<String, dynamic>? clanActivity;

  RecentPassUser({
    required this.id,
    required this.fullName,
    required this.gender,
    required this.dateOfBirth,
    this.aboutMe,
    this.locationString,
    this.lat,
    this.lng,
    required this.relationshipGoals,
    this.relationshipStatus,
    this.religion,
    this.zodiacSign,
    this.alcoholConsumption,
    this.smokingHabit,
    this.workoutFrequency,
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
    String? profileImageUrl,
    required this.profilePhotos,
    required this.isVerified,
    this.isOnline = false,
    this.lastActive,
    this.clanActivity,
  }) : _profileImageUrl = profileImageUrl;

  // -------- BaseProfile --------

  @override
  String get profileImageUrl => _profileImageUrl ?? '';

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

  factory RecentPassUser.fromJson(Map<String, dynamic> json) {
    return RecentPassUser(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      aboutMe: json['aboutMe'],
      locationString: json['locationString'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      relationshipGoals: List<String>.from(json['relationshipGoals'] ?? []),
      relationshipStatus: json['relationshipStatus'],
      religion: json['religion'],
      zodiacSign: json['zodiacSign'],
      alcoholConsumption: json['alcoholConsumption'],
      smokingHabit: json['smokingHabit'],
      workoutFrequency: json['workoutFrequency'],
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
      profileImageUrl: json['profileImageUrl'],
      profilePhotos: List<String>.from(json['profilePhotos'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastActive: json['lastActive'],
      clanActivity: json['clanActivity'],
    );
  }
}
