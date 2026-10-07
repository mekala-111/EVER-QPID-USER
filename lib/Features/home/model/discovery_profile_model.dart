// lib/features/home/model/user_profile_model.dart

class DiscoveryProfile {
  final String id;
  final String name;
  final int age;
  final String education;
  final String bio;
  final String imageUrl;
  final List<String> interests;
  final List<String> languages;
  final List<String> basics;
  final List<String> profession;
  final List<String> moreEducation;
  final List<String> additionalImages;
  final bool isVerified;
  final String locationString;
  final String religion;
  final int height;
  final String relationshipStatus;
  final String zodiacSign;
  final String smokingHabit;
  final String alcoholConsumption;
  final String workoutFrequency;

  DiscoveryProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.education,
    required this.bio,
    required this.imageUrl,
    required this.interests,
    required this.languages,
    required this.basics,
    required this.profession,
    required this.moreEducation,
    required this.additionalImages,
    required this.zodiacSign,
    required this.smokingHabit,
    required this.alcoholConsumption,
    required this.workoutFrequency,
    this.isVerified = false,
    this.locationString = '',
    this.religion = '',
    this.height = 0,
    this.relationshipStatus = '',
  });

  // Factory constructor to create DiscoveryProfile from API JSON
  factory DiscoveryProfile.fromJson(Map<String, dynamic> json) {
    // Calculate age from dateOfBirth if age is not provided
    int calculatedAge = json['age'] ?? 0;

    // Extract basics information with proper type casting
    List<String> basics = [
      json['relationshipStatus']?.toString() ?? 'Single',
      json['height']?.toString() ?? '',
      json['religion']?.toString() ?? '',
      json['locationString']?.toString() ?? '',
    ].where((element) => element.isNotEmpty).toList();

    // Extract profession information with proper type casting
    List<String> profession = [
      json['currentProfession']?.toString() ?? '',
      json['companyName']?.toString() ?? '',
    ].where((element) => element.isNotEmpty).toList();

    // Extract education information with proper type casting
    List<String> moreEducation = [
      json['education']?.toString() ?? '',
      json['collegeName']?.toString() ?? '',
      // json['graduationYear']?.toString() ?? '',
    ].where((element) => element.isNotEmpty).toList();

    // Helper function to safely convert dynamic list to List<String>
    List<String> toStringList(dynamic list) {
      if (list == null) return [];
      if (list is List) {
        return list
            .map((e) => e?.toString() ?? '')
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    return DiscoveryProfile(
      id: json['_id']?.toString() ?? '',
      name: json['fullName']?.toString() ?? 'Unknown',
      age: calculatedAge,
      education: json['education']?.toString() ?? 'Not specified',
      bio: json['aboutMe']?.toString() ?? 'No bio available',
      imageUrl: json['profileImageUrl']?.toString() ?? '',
      interests: toStringList(json['interests']),
      languages: toStringList(json['otherLanguages']),
      zodiacSign: json['zodiacSign']?.toString() ?? '',
      smokingHabit: json['smokingHabit']?.toString() ?? '',
      alcoholConsumption: json['alcoholConsumption']?.toString() ?? '',
      workoutFrequency: json['workoutFrequency']?.toString() ?? '',
      basics: basics,
      profession: profession,
      moreEducation: moreEducation,
      additionalImages: toStringList(json['profilePhotos']),
      isVerified: json['isVerified'] == true,
      locationString: json['locationString']?.toString() ?? '',
      religion: json['religion']?.toString() ?? '',
      height: json['height'] ?? 0,
      relationshipStatus: json['relationshipStatus']?.toString() ?? '',
    );
  }

  // Convert DiscoveryProfile to JSON (for future use)
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': name,
      'age': age,
      'education': education,
      'aboutMe': bio,
      'profileImageUrl': imageUrl,
      'interests': interests,
      'otherLanguages': languages,
      'profilePhotos': additionalImages,
      'isVerified': isVerified,
      'locationString': locationString,
      'religion': religion,
      'height': height,
      'relationshipStatus': relationshipStatus,
    };
  }
}

// Response model for API pagination
class DiscoveryProfilesResponse {
  final List<DiscoveryProfile> users;
  final bool hasNext;
  final int totalCount;

  DiscoveryProfilesResponse({
    required this.users,
    required this.hasNext,
    required this.totalCount,
  });

  factory DiscoveryProfilesResponse.fromJson(Map<String, dynamic> json) {
    return DiscoveryProfilesResponse(
      users: (json['users'] as List)
          .map((user) => DiscoveryProfile.fromJson(user))
          .toList(),
      hasNext: json['hasNext'] ?? false,
      totalCount: json['totalCount'] ?? 0,
    );
  }
}
