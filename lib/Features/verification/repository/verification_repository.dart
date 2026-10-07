// features/verification/repository/verification_repository.dart

import 'dart:developer';
import 'dart:typed_data';

import 'package:everqpidapp/Settings/helper/upload_validation.dart';

import '../../../Data/Network/network_api_service_v2.dart';
import '../model/face_verification_response.dart';

/// Repository responsible for verification-related API calls
class VerificationRepository {
  final NetworkApiServiceV2 _api = NetworkApiServiceV2.instance;

  /// Upload selfie image bytes to S3 and return permanent URL
  Future<String> uploadSelfieToS3(Uint8List bytes) async {
    try {
      UploadValidation.assertValidImage(bytes);
      final mime = UploadValidation.imageContentType(bytes)!;
      final fileName = UploadValidation.sanitizeFileName(
        'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      log('📤 Requesting signed URL for selfie: $fileName');

      final signedUrlResponse = await _api.getPostApiResponse(
        '/api/v1/signed-url/get-signed-url',
        body: {'fileName': fileName, 'fieldName': fileName},
      );

      if (signedUrlResponse['data'] == null ||
          signedUrlResponse['data']['signedUrl'] == null) {
        throw Exception('Failed to get signed URL');
      }

      final signedUrl = signedUrlResponse['data']['signedUrl'];
      log('✅ Got signed URL for selfie');

      await _api.putMethod(
        signedUrl,
        body: bytes,
        headers: {'Content-Type': mime},
      );

      log('✅ Selfie uploaded to S3');

      final permanentUrl = signedUrl.split('?').first;
      log('📥 Permanent selfie URL: $permanentUrl');

      return permanentUrl;
    } catch (e) {
      log('❌ Upload selfie error: $e');
      throw Exception('Failed to upload selfie: $e');
    }
  }

  /// Call face recognition API to verify user
  ///
  /// Parameters:
  /// - [profileImageUrl]: User's existing profile image URL
  /// - [selfieImageUrl]: Newly captured selfie image URL
  /// - [gender]: User's gender ("Male" or "Female")
  Future<FaceVerificationResponse> verifyFaceRecognition({
    required String profileImageUrl,
    required String selfieImageUrl,
    required String gender,
  }) async {
    try {
      log('📤 Calling face recognition API');
      log('   Profile Image: $profileImageUrl');
      log('   Selfie Image: $selfieImageUrl');
      log('   Gender: $gender');

      final response = await _api.getPostApiResponse(
        '/api/v1/auth/check-face-recognition',
        body: {
          'imageUrl1': profileImageUrl,
          'imageUrl2': selfieImageUrl,
          'gender': gender,
        },
      );

      log('📥 Face verification response received');

      return FaceVerificationResponse.fromJson(response);
    } catch (e) {
      log('❌ Face verification API error: $e');
      throw Exception('Verification failed: $e');
    }
  }
}
