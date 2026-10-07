// Models for Email Authentication

// Send OTP Request
class SendEmailOtpRequest {
  final String email;

  SendEmailOtpRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class SendEmailOtpResponse {
  final bool status;
  final int statusCode;
  final String message;

  SendEmailOtpResponse({
    required this.status,
    required this.statusCode,
    required this.message,
  });

  factory SendEmailOtpResponse.fromJson(Map<String, dynamic> json) {
    return SendEmailOtpResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
    );
  }
}

// Verify OTP Request
class VerifyEmailOtpRequest {
  final String email;
  final String otp;

  VerifyEmailOtpRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class VerifyEmailOtpResponse {
  final bool status;
  final int statusCode;
  final String message;
  final VerifyEmailOtpData? data;

  VerifyEmailOtpResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory VerifyEmailOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailOtpResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? VerifyEmailOtpData.fromJson(json['data'])
          : null,
    );
  }
}

class VerifyEmailOtpData {
  final bool isVerified;

  VerifyEmailOtpData({required this.isVerified});

  factory VerifyEmailOtpData.fromJson(Map<String, dynamic> json) {
    return VerifyEmailOtpData(
      isVerified: json['isVerified'] ?? false,
    );
  }
}

// Check User Exists Request
class CheckUserExistsRequest {
  final String email;

  CheckUserExistsRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

class CheckUserExistsResponse {
  final bool status;
  final int statusCode;
  final String message;
  final CheckUserExistsData? data;

  CheckUserExistsResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory CheckUserExistsResponse.fromJson(Map<String, dynamic> json) {
    return CheckUserExistsResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CheckUserExistsData.fromJson(json['data'])
          : null,
    );
  }
}

class CheckUserExistsData {
  final bool userExists;

  CheckUserExistsData({required this.userExists});

  factory CheckUserExistsData.fromJson(Map<String, dynamic> json) {
    return CheckUserExistsData(
      userExists: json['userExists'] ?? false,
    );
  }
}

// Email Login Request
class EmailLoginRequest {
  final String email;
  final String otp;

  EmailLoginRequest({required this.email, required this.otp});

  Map<String, dynamic> toJson() => {'email': email, 'otp': otp};
}

class EmailLoginResponse {
  final bool status;
  final int statusCode;
  final String message;
  final EmailLoginData? data;

  EmailLoginResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory EmailLoginResponse.fromJson(Map<String, dynamic> json) {
    return EmailLoginResponse(
      status: json['status'] ?? false,
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? EmailLoginData.fromJson(json['data']) : null,
    );
  }
}

class EmailLoginData {
  final EmailLoginUser user;
  final EmailLoginTokens tokens;

  EmailLoginData({required this.user, required this.tokens});

  factory EmailLoginData.fromJson(Map<String, dynamic> json) {
    return EmailLoginData(
      user: EmailLoginUser.fromJson(json['user']),
      tokens: EmailLoginTokens.fromJson(json['tokens']),
    );
  }
}

class EmailLoginUser {
  final String id;
  final String fullName;
  final String email;
  final bool isVerified;

  EmailLoginUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.isVerified,
  });

  factory EmailLoginUser.fromJson(Map<String, dynamic> json) {
    return EmailLoginUser(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class EmailLoginTokens {
  final EmailLoginToken access;
  final EmailLoginToken refresh;

  EmailLoginTokens({required this.access, required this.refresh});

  factory EmailLoginTokens.fromJson(Map<String, dynamic> json) {
    return EmailLoginTokens(
      access: EmailLoginToken.fromJson(json['access']),
      refresh: EmailLoginToken.fromJson(json['refresh']),
    );
  }
}

class EmailLoginToken {
  final String token;
  final String expires;

  EmailLoginToken({required this.token, required this.expires});

  factory EmailLoginToken.fromJson(Map<String, dynamic> json) {
    return EmailLoginToken(
      token: json['token'] ?? '',
      expires: json['expires'] ?? '',
    );
  }
}

// Email Signup Request (reuse existing SignupRequest from signup_model.dart)
// But create a specific one for email signup without phone

class EmailSignupRequest {
  final String fullName;
  final String email;
  final String? profileImageUrl;
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
  final List<String>? profilePhotos;
  final bool isVerified;

  EmailSignupRequest({
    required this.fullName,
    required this.email,
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
    this.profilePhotos,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
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
      if (profilePhotos != null) 'profilePhotos': profilePhotos,
      'isVerified': isVerified,
    };
  }
}
