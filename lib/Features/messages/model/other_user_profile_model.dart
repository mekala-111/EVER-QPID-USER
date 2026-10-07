class OtherProfileDetails {
  final String id;
  final String fullName;
  final String email;
  final String countryCode;
  final String mobileNumber;
  final String profileImageUrl;

  final String gender;
  final String zodiacSign;

  final String alcoholConsumption;
  final String smokingHabit;
  final String workoutFrequency;

  final DateTime dateOfBirth;
  final String aboutMe;

  final GeoLocation location;
  final String locationString;
  final double lat;
  final double lng;

  // Relationship
  final List<String> relationshipGoals;
  final String relationshipStatus;

  // Personal
  final String religion;
  final int height;

  // Languages & interests
  final List<String> otherLanguages;
  final List<String> interests;

  // Profession
  final String currentProfession;
  final String companyName;
  final String roleInCompany;
  final String employmentType;

  // Education
  final String education;
  final String collegeName;
  final int graduationYear;
  final bool currentlyStudying;

  // Images
  final List<String> profilePhotos;

  // Status
  final bool isVerified;
  final bool isActive;
  final bool isBlocked;
  final bool isOnline;
  final bool isFavorite;

  final int age;
  final String customerStatus;

  OtherProfileDetails({
    required this.id,
    required this.fullName,
    required this.email,
    required this.countryCode,
    required this.mobileNumber,
    required this.profileImageUrl,
    required this.gender,
    required this.zodiacSign,
    required this.alcoholConsumption,
    required this.smokingHabit,
    required this.workoutFrequency,
    required this.dateOfBirth,
    required this.aboutMe,
    required this.location,
    required this.locationString,
    required this.lat,
    required this.lng,
    required this.relationshipGoals,
    required this.relationshipStatus,
    required this.religion,
    required this.height,
    required this.otherLanguages,
    required this.interests,
    required this.currentProfession,
    required this.companyName,
    required this.roleInCompany,
    required this.employmentType,
    required this.education,
    required this.collegeName,
    required this.graduationYear,
    required this.currentlyStudying,
    required this.profilePhotos,
    required this.isVerified,
    required this.isActive,
    required this.isBlocked,
    required this.isOnline,
    required this.isFavorite,
    required this.age,
    required this.customerStatus,
  });

  factory OtherProfileDetails.fromJson(Map<String, dynamic> json) {
    return OtherProfileDetails(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      countryCode: json['countryCode'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      gender: json['gender'] ?? '',
      zodiacSign: json['zodiacSign'] ?? '',
      alcoholConsumption: json['alcoholConsumption'] ?? '',
      smokingHabit: json['smokingHabit'] ?? '',
      workoutFrequency: json['workoutFrequency'] ?? '',
      dateOfBirth:
          DateTime.tryParse(json['dateOfBirth'] ?? '') ?? DateTime(2000),
      aboutMe: json['aboutMe'] ?? '',
      location: GeoLocation.fromJson(json['location'] ?? {}),
      locationString: json['locationString'] ?? '',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      relationshipGoals: List<String>.from(json['relationshipGoals'] ?? []),
      relationshipStatus: json['relationshipStatus'] ?? '',
      religion: json['religion'] ?? '',
      height: json['height'] ?? 0,
      otherLanguages: List<String>.from(json['otherLanguages'] ?? []),
      interests: List<String>.from(json['interests'] ?? []),
      currentProfession: json['currentProfession'] ?? '',
      companyName: json['companyName'] ?? '',
      roleInCompany: json['roleInCompany'] ?? '',
      employmentType: json['employmentType'] ?? '',
      education: json['education'] ?? '',
      collegeName: json['collegeName'] ?? '',
      graduationYear: json['graduationYear'] ?? 0,
      currentlyStudying: json['currentlyStudying'] ?? false,
      profilePhotos: List<String>.from(json['profilePhotos'] ?? []),
      isVerified: json['isVerified'] ?? false,
      isActive: json['isActive'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      isOnline: json['isOnline'] ?? false,
      isFavorite: json['isFavorite'] ?? false,
      age: json['age'] ?? 0,
      customerStatus: json['customerStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'countryCode': countryCode,
      'mobileNumber': mobileNumber,
      'profileImageUrl': profileImageUrl,
      'gender': gender,
      'zodiacSign': zodiacSign,
      'alcoholConsumption': alcoholConsumption,
      'smokingHabit': smokingHabit,
      'workoutFrequency': workoutFrequency,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'aboutMe': aboutMe,
      'location': location.toJson(),
      'locationString': locationString,
      'lat': lat,
      'lng': lng,
      'relationshipGoals': relationshipGoals,
      'relationshipStatus': relationshipStatus,
      'religion': religion,
      'height': height,
      'otherLanguages': otherLanguages,
      'interests': interests,
      'currentProfession': currentProfession,
      'companyName': companyName,
      'roleInCompany': roleInCompany,
      'employmentType': employmentType,
      'education': education,
      'collegeName': collegeName,
      'graduationYear': graduationYear,
      'currentlyStudying': currentlyStudying,
      'profilePhotos': profilePhotos,
      'isVerified': isVerified,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'isOnline': isOnline,
      'isFavorite': isFavorite,
      'age': age,
      'customerStatus': customerStatus,
    };
  }
}

class GeoLocation {
  final String type;
  final List<double> coordinates;

  GeoLocation({
    required this.type,
    required this.coordinates,
  });

  factory GeoLocation.fromJson(Map<String, dynamic> json) {
    return GeoLocation(
      type: json['type'] ?? '',
      coordinates: List<double>.from(
        (json['coordinates'] ?? []).map((e) => (e ?? 0).toDouble()),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
}
