class UserProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String? countryCode;
  final String phoneNumber;
  final String? profileImageUrl;
  final String? gender;
  final String? dateOfBirth;
  final String? aboutMe;
  final ProfileLocation? location;
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
  final List<String> profilePhotos;
  final bool isVerified;
  final String customerStatus;
  final bool isActive;

  UserProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.countryCode,
    required this.phoneNumber,
    this.profileImageUrl,
    this.gender,
    this.dateOfBirth,
    this.aboutMe,
    this.location,
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
    this.profilePhotos = const [],
    required this.isVerified,
    required this.customerStatus,
    required this.isActive,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final data = json["userProfile"] ?? json;

    return UserProfileModel(
      id: data["_id"] ?? "",
      fullName: data["fullName"] ?? "",
      email: data["email"] ?? "",
      countryCode: data["countryCode"],
      phoneNumber: data["mobileNumber"] ?? "",
      profileImageUrl: data["profileImageUrl"],
      gender: data["gender"],
      dateOfBirth: data["dateOfBirth"],
      aboutMe: data["aboutMe"],
      location: data["location"] != null
          ? ProfileLocation.fromJson(data["location"])
          : null,
      locationString: data["locationString"],
      lat: data["lat"]?.toDouble(),
      lng: data["lng"]?.toDouble(),
      relationshipGoals: data["relationshipGoals"] != null
          ? List<String>.from(data["relationshipGoals"])
          : null,
      relationshipStatus: data["relationshipStatus"],
      religion: data["religion"],
      height: data["height"],
      otherLanguages: data["otherLanguages"] != null
          ? List<String>.from(data["otherLanguages"])
          : null,
      interests: data["interests"] != null
          ? List<String>.from(data["interests"].where((x) => x != null))
          : null,
      currentProfession: data["currentProfession"],
      companyName: data["companyName"],
      roleInCompany: data["roleInCompany"],
      employmentType: data["employmentType"],
      education: data["education"],
      collegeName: data["collegeName"],
      graduationYear: data["graduationYear"],
      currentlyStudying: data["currentlyStudying"],
      profilePhotos: data["profilePhotos"] != null
          ? List<String>.from(data["profilePhotos"])
          : [],
      isVerified: data["isVerified"] ?? false,
      customerStatus: data["customerStatus"] ?? "Active",
      isActive: data["isActive"] ?? true,
    );
  }
}

class ProfileLocation {
  final String type;
  final List<double> coordinates;

  ProfileLocation({
    required this.type,
    required this.coordinates,
  });

  factory ProfileLocation.fromJson(Map<String, dynamic> json) {
    return ProfileLocation(
      type: json['type'] ?? 'Point',
      coordinates: json['coordinates'] != null
          ? List<double>.from(
              json['coordinates'].map((x) => x.toDouble()),
            )
          : [],
    );
  }
}
