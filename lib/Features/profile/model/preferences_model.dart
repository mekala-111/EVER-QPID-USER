// lib/features/preferences/model/preferences_model.dart

class UserPreferences {
  final String id;
  final String userId;
  final String? locationString;
  final double? lat;
  final double? lng;
  final int? distance; // Distance in meters
  final int? minAge;
  final int? maxAge;
  final int? minHeight;
  final int? maxHeight;
  final List<String>? looking;
  final List<String>? otherLanguages;
  final String? religion;
  final String? maritalStatus;
  final String? profession;
  final String? education;
  final String? interestedIn;
  final bool? allowOutOfDistance;
  final bool? allowOutOfAgeRange;

  UserPreferences({
    required this.id,
    required this.userId,
    this.locationString,
    this.lat,
    this.lng,
    this.distance,
    this.minAge,
    this.maxAge,
    this.minHeight,
    this.maxHeight,
    this.looking,
    this.otherLanguages,
    this.religion,
    this.maritalStatus,
    this.profession,
    this.education,
    this.interestedIn,
    this.allowOutOfDistance,
    this.allowOutOfAgeRange,
  });

  /// Factory constructor to parse API response
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      locationString: json['locationString']?.toString(),
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      distance: json['distance'] as int?,
      minAge: json['minAge'] as int?,
      maxAge: json['maxAge'] as int?,
      minHeight: json['minHeight'] as int?,
      maxHeight: json['maxHeight'] as int?,
      looking: json['looking'] != null
          ? List<String>.from(json['looking'] as List)
          : null,
      otherLanguages: json['otherLanguages'] != null
          ? List<String>.from(json['otherLanguages'] as List)
          : null,
      religion: json['religion']?.toString(),
      maritalStatus: json['maritalStatus']?.toString(),
      profession: json['profession']?.toString(),
      education: json['education']?.toString(),
      interestedIn: json['interestedIn']?.toString(),
      allowOutOfDistance: json['allowOutOfDistance'] as bool?,
      allowOutOfAgeRange: json['allowOutOfAgeRange'] as bool?,
    );
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (locationString != null) data['locationString'] = locationString;
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    if (distance != null) data['distance'] = distance;
    if (minAge != null) data['minAge'] = minAge;
    if (maxAge != null) data['maxAge'] = maxAge;
    if (minHeight != null) data['minHeight'] = minHeight;
    if (maxHeight != null) data['maxHeight'] = maxHeight;
    if (looking != null) data['looking'] = looking;
    if (otherLanguages != null) data['otherLanguages'] = otherLanguages;
    if (religion != null) data['religion'] = religion;
    if (maritalStatus != null) data['maritalStatus'] = maritalStatus;
    if (profession != null) data['profession'] = profession;
    if (education != null) data['education'] = education;
    if (interestedIn != null) data['interestedIn'] = interestedIn;
    if (allowOutOfDistance != null) {
      data['allowOutOfDistance'] = allowOutOfDistance;
    }
    if (allowOutOfAgeRange != null) {
      data['allowOutOfAgeRange'] = allowOutOfAgeRange;
    }

    return data;
  }

  /// Create a copy with updated fields
  UserPreferences copyWith({
    String? id,
    String? userId,
    String? locationString,
    double? lat,
    double? lng,
    int? distance,
    int? minAge,
    int? maxAge,
    int? minHeight,
    int? maxHeight,
    List<String>? looking,
    List<String>? otherLanguages,
    String? religion,
    String? maritalStatus,
    String? profession,
    String? education,
    String? interestedIn,
    bool? allowOutOfDistance,
    bool? allowOutOfAgeRange,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      locationString: locationString ?? this.locationString,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      distance: distance ?? this.distance,
      minAge: minAge ?? this.minAge,
      maxAge: maxAge ?? this.maxAge,
      minHeight: minHeight ?? this.minHeight,
      maxHeight: maxHeight ?? this.maxHeight,
      looking: looking ?? this.looking,
      otherLanguages: otherLanguages ?? this.otherLanguages,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      profession: profession ?? this.profession,
      education: education ?? this.education,
      interestedIn: interestedIn ?? this.interestedIn,
      allowOutOfDistance: allowOutOfDistance ?? this.allowOutOfDistance,
      allowOutOfAgeRange: allowOutOfAgeRange ?? this.allowOutOfAgeRange,
    );
  }

  /// Helper: Get formatted age range
  String get ageRangeText {
    if (minAge != null && maxAge != null) {
      return '$minAge–$maxAge';
    } else if (minAge != null) {
      return '$minAge+';
    } else if (maxAge != null) {
      return 'Up to $maxAge';
    }
    return 'Any';
  }

  /// Helper: Get formatted distance
  String get distanceText {
    if (distance == null) return 'Any';
    final km = (distance! / 1000).round();
    return '$km km';
  }

  /// Helper: Get formatted languages
  String get languagesText {
    if (otherLanguages == null || otherLanguages!.isEmpty) return 'Any';
    return otherLanguages!.join(', ');
  }

  /// Helper: Get formatted height range
  String get heightRangeText {
    if (minHeight != null && maxHeight != null) {
      return '$minHeight cm - $maxHeight cm';
    } else if (minHeight != null) {
      return '$minHeight cm+';
    } else if (maxHeight != null) {
      return 'Up to $maxHeight cm';
    }
    return 'Any';
  }

  /// Helper: Get formatted looking for
  String get lookingForText {
    if (looking == null || looking!.isEmpty) return 'Any';
    return looking!.join(', ');
  }
}

/// Response wrapper for get filter API
class PreferencesResponse {
  final bool status;
  final int statusCode;
  final String message;
  final UserPreferences? preferences;
  final bool isSubscribed;

  PreferencesResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.preferences,
    required this.isSubscribed,
  });

  factory PreferencesResponse.fromJson(Map<String, dynamic> json) {
    UserPreferences? prefs;

    if (json['data'] != null && json['data']['userSearchFilter'] != null) {
      prefs = UserPreferences.fromJson(json['data']['userSearchFilter']);
    }

    return PreferencesResponse(
      status: json['status'] == true,
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message']?.toString() ?? '',
      preferences: prefs,
      isSubscribed: json['data']?['isSubscribed'] == true,
    );
  }
}

/// Response wrapper for save filter API
class SavePreferencesResponse {
  final bool status;
  final int statusCode;
  final String message;
  final UserPreferences? preferences;
  final bool isSubscribed;

  SavePreferencesResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.preferences,
    required this.isSubscribed,
  });

  // factory SavePreferencesResponse.fromJson(Map<String, dynamic> json) {
  //   UserPreferences? prefs;

  //   if (json['data'] != null && json['data']['updatedFilter'] != null) {
  //     prefs = UserPreferences.fromJson(json['data']['updatedFilter']);
  //   }

  //   return SavePreferencesResponse(
  //     status: json['status'] == true,
  //     statusCode: json['statusCode'] as int? ?? 200,
  //     message: json['message']?.toString() ?? '',
  //     preferences: prefs,
  //     isSubscribed: json['data']?['isSubscribed'] == true,
  //   );
  // }
  factory SavePreferencesResponse.fromJson(Map<String, dynamic> json) {
    UserPreferences? prefs;

    // Handle both 'updatedFilter' and 'resetFilter' keys
    if (json['data'] != null) {
      final filterData =
          json['data']['updatedFilter'] ?? json['data']['resetFilter'];
      if (filterData != null) {
        prefs = UserPreferences.fromJson(filterData);
      }
    }

    return SavePreferencesResponse(
      status: json['status'] == true,
      statusCode: json['statusCode'] as int? ?? 200,
      message: json['message']?.toString() ?? '',
      preferences: prefs,
      isSubscribed: json['data']?['isSubscribed'] == true,
    );
  }
}
