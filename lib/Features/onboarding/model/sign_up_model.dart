class SignupRequest {
  final String fullName;
  final String? email;
  final String countryCode;
  final String mobileNumber;
  final String? profileImageUrl;
  final List<String>? profilePhotos;
  final String gender;
  final String dateOfBirth;
  final String? aboutMe;
  final bool isCurrentLocationAndHomeSame;
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
  final String? motherTongue;
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
  final bool isVerified;

  SignupRequest({
    required this.fullName,
    this.email,
    required this.countryCode,
    required this.mobileNumber,
    this.profilePhotos,
    this.profileImageUrl,
    required this.gender,
    required this.dateOfBirth,
    this.aboutMe,
    this.isCurrentLocationAndHomeSame = true,
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
    this.motherTongue,
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
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      if (email != null) 'email': email ?? 'test@gmail.com',
      'countryCode': countryCode,
      'mobileNumber': mobileNumber,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (profilePhotos != null) 'profilePhotos': profilePhotos,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      if (aboutMe != null) 'aboutMe': aboutMe,
      'isCurrentLocationAndHomeSame': isCurrentLocationAndHomeSame,
      if (currentLocationString != null)
        'currentLocationString': currentLocationString,
      if (currentLat != null) 'currentLat': currentLat,
      if (currentLng != null) 'currentLng': currentLng,
      if (locationString != null) 'locationString': locationString,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (relationshipGoals != null) 'relationshipGoals': relationshipGoals,
      if (relationshipStatus != null) 'relationshipStatus': relationshipStatus,
      if (religion != null) 'religion': religion,
      if (height != null) 'height': height,
      if (motherTongue != null) 'motherTongue': motherTongue,
      if (otherLanguages != null) 'otherLanguages': otherLanguages,
      if (interests != null) 'interests': interests,
      if (currentProfession != null) 'currentProfession': currentProfession,
      if (companyName != null) 'companyName': companyName,
      if (roleInCompany != null) 'roleInCompany': roleInCompany,
      if (employmentType != null) 'employmentType': employmentType,
      if (education != null) 'education': education,
      if (collegeName != null) 'collegeName': collegeName,
      if (graduationYear != null) 'graduationYear': graduationYear,
      if (currentlyStudying != null) 'currentlyStudying': currentlyStudying,
      'isVerified': isVerified,
    };
  }
}

class SignupResponse {
  final bool status;
  final int statusCode;
  final String message;
  final SignupData? data;

  SignupResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? SignupData.fromJson(json['data']) : null,
    );
  }
}

class SignupData {
  final User user;
  final Tokens tokens;

  SignupData({required this.user, required this.tokens});

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      user: User.fromJson(
        json['user'] is Map
            ? Map<String, dynamic>.from(json['user'] as Map)
            : <String, dynamic>{},
      ),
      tokens: json['tokens'] is Map
          ? Tokens.fromJson(Map<String, dynamic>.from(json['tokens'] as Map))
          : Tokens(
              access: Token(token: '', expires: ''),
              refresh: Token(token: '', expires: ''),
            ),
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String? email;
  final String countryCode;
  final String mobileNumber;
  final String? profileImageUrl;
  final String gender;
  final String dateOfBirth;
  final String? aboutMe;
  final Location? location;
  final String? locationString;
  final double? lat;
  final double? lng;
  final List<String>? relationshipGoals;
  final String? relationshipStatus;
  final String? religion;
  final int? height;
  final String? motherTongue;
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
  final List<dynamic> profilePhotos;
  final String customerStatus;
  final bool isVerified;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  User({
    required this.id,
    required this.fullName,
    this.email,
    required this.countryCode,
    required this.mobileNumber,
    this.profileImageUrl,
    required this.gender,
    required this.dateOfBirth,
    this.aboutMe,
    this.location,
    this.locationString,
    this.lat,
    this.lng,
    this.relationshipGoals,
    this.relationshipStatus,
    this.religion,
    this.height,
    this.motherTongue,
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
    required this.profilePhotos,
    required this.customerStatus,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      countryCode: json['countryCode']?.toString() ?? '',
      mobileNumber: json['mobileNumber']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString(),
      gender: json['gender']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      aboutMe: json['aboutMe']?.toString(),
      location: json['location'] is Map
          ? Location.fromJson(Map<String, dynamic>.from(json['location']))
          : null,
      locationString: json['locationString']?.toString(),
      lat: _asDouble(json['lat']),
      lng: _asDouble(json['lng']),
      relationshipGoals: json['relationshipGoals'] is List
          ? List<String>.from(
              (json['relationshipGoals'] as List).map((e) => e.toString()),
            )
          : null,
      relationshipStatus: json['relationshipStatus']?.toString(),
      religion: json['religion']?.toString(),
      height: _asInt(json['height']),
      motherTongue: json['motherTongue']?.toString(),
      otherLanguages: json['otherLanguages'] is List
          ? List<String>.from(
              (json['otherLanguages'] as List).map((e) => e.toString()),
            )
          : null,
      interests: json['interests'] is List
          ? List<String>.from(
              (json['interests'] as List).map((e) => e.toString()),
            )
          : null,
      currentProfession: json['currentProfession']?.toString(),
      companyName: json['companyName']?.toString(),
      roleInCompany: json['roleInCompany']?.toString(),
      employmentType: json['employmentType']?.toString(),
      education: json['education']?.toString(),
      collegeName: json['collegeName']?.toString(),
      graduationYear: _asInt(json['graduationYear']),
      currentlyStudying: json['currentlyStudying'] is bool
          ? json['currentlyStudying'] as bool
          : null,
      profilePhotos: json['profilePhotos'] is List
          ? List<dynamic>.from(json['profilePhotos'] as List)
          : const [],
      customerStatus: json['customerStatus']?.toString() ?? 'Active',
      isVerified: json['isVerified'] == true,
      isActive: json['isActive'] != false,
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }
}

double? _asDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});

  factory Location.fromJson(Map<String, dynamic> json) {
    final coords = <double>[];
    if (json['coordinates'] is List) {
      for (final x in json['coordinates'] as List) {
        final d = _asDouble(x);
        if (d != null) coords.add(d);
      }
    }
    return Location(
      type: json['type']?.toString() ?? 'Point',
      coordinates: coords,
    );
  }
}

class Tokens {
  final Token access;
  final Token refresh;

  Tokens({required this.access, required this.refresh});

  factory Tokens.fromJson(Map<String, dynamic> json) {
    return Tokens(
      access: json['access'] is Map
          ? Token.fromJson(Map<String, dynamic>.from(json['access'] as Map))
          : Token(token: '', expires: ''),
      refresh: json['refresh'] is Map
          ? Token.fromJson(Map<String, dynamic>.from(json['refresh'] as Map))
          : Token(token: '', expires: ''),
    );
  }
}

class Token {
  final String token;
  final String expires;

  Token({required this.token, required this.expires});

  factory Token.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Token(token: '', expires: '');
    }
    return Token(token: json['token'] ?? '', expires: json['expires'] ?? '');
  }
}
