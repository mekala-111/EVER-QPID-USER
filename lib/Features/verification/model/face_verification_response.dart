// features/verification/model/face_verification_response.dart

/// Response model for face verification API
class FaceVerificationResponse {
  final bool status;
  final int statusCode;
  final String message;
  final FaceVerificationData? data;

  FaceVerificationResponse({
    required this.status,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory FaceVerificationResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return FaceVerificationResponse(
      status: _asBool(json['status']),
      statusCode: _asInt(json['statusCode'] ?? json['status_code']) ?? 500,
      message: (json['message'] ?? 'Unknown error').toString(),
      data: rawData is Map<String, dynamic>
          ? FaceVerificationData.fromJson(rawData)
          : null,
    );
  }

  /// Check if verification was successful
  bool get isVerified =>
      status && data != null && data!.isFaceMatch && data!.genderMatches;
}

/// Data payload containing verification results
class FaceVerificationData {
  final bool isFaceMatch;
  final bool genderMatches;

  FaceVerificationData({
    required this.isFaceMatch,
    required this.genderMatches,
  });

  factory FaceVerificationData.fromJson(Map<String, dynamic> json) {
    return FaceVerificationData(
      isFaceMatch: _asBool(
        json['isFaceMatch'] ?? json['faceMatch'] ?? json['is_face_match'],
      ),
      genderMatches: _asBool(
        json['genderMatches'] ?? json['genderMatch'] ?? json['gender_matches'],
      ),
    );
  }
}

bool _asBool(dynamic v) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
  return false;
}

int? _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}
