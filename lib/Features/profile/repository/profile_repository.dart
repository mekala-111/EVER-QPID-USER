import 'dart:developer';
import 'dart:typed_data';

import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/profile/model/profile_model.dart';
import 'package:everqpidapp/Settings/helper/upload_validation.dart';
import '../model/user_profile_model.dart';

class ProfileRepository {
  final NetworkApiServiceV2 _api = NetworkApiServiceV2.instance;

  Future<UserProfileModel> getProfile() async {
    final response = await _api.getGetApiResponse(
      "/api/v1/profile/get-profile",
    );
    return UserProfileModel.fromJson(response["data"]);
  }

  // Update profile with only changed fields (partial update)
  Future<UpdateProfileResponse> updateProfilePartial(
    Map<String, dynamic> changedFields,
  ) async {
    try {
      log('📤 Partial profile update');
      log('   Fields: ${changedFields.values.join(", ")}');
      log('ChangedFields from repository: $changedFields');

      final response = await _api.getPutApiResponse(
        '/api/v1/profile/update-profile',
        body: changedFields,
      );

      log('📥 Profile update response: $response');

      return UpdateProfileResponse.fromJson(response);
    } catch (e) {
      log('❌ Partial update error: $e');
      rethrow;
    }
  }

  // Upload photo to S3 (bytes — works on web + mobile)
  Future<String> uploadPhotoToS3(
    List<int> bytes, {
    String fileName = 'profile.jpg',
  }) async {
    try {
      UploadValidation.assertValidImage(bytes);
      final mime = UploadValidation.imageContentType(
            bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
          ) ??
          'image/jpeg';
      final safeName = UploadValidation.sanitizeFileName(fileName);
      log('📤 Requesting signed URL for: $safeName');

      // Step 1: Get signed URL
      final signedUrlResponse = await _api.getPostApiResponse(
        '/api/v1/signed-url/get-signed-url',
        body: {'fileName': safeName, 'fieldName': safeName},
      );

      final signedUrl = signedUrlResponse['data']['signedUrl'];
      log('✅ Got signed URL');

      await _api.putMethod(
        signedUrl,
        body: bytes,
        headers: {'Content-Type': mime},
      );

      log('✅ File uploaded to S3');

      // Step 3: Extract permanent URL
      final permanentUrl = signedUrl.split('?').first;
      log('📥 Permanent URL: $permanentUrl');

      return permanentUrl;
    } catch (e) {
      log('❌ Upload photo error: $e');
      rethrow;
    }
  }

  // Upload multiple photos
  Future<List<String>> uploadMultiplePhotos(List<List<int>?> images) async {
    try {
      final urls = <String>[];
      final validImages =
          images.whereType<List<int>>().where((b) => b.isNotEmpty).toList();

      log('📤 Uploading ${validImages.length} photos');

      for (int i = 0; i < validImages.length; i++) {
        final bytes = validImages[i];
        log('📸 Uploading photo ${i + 1}/${validImages.length}');

        final url = await uploadPhotoToS3(
          bytes,
          fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        urls.add(url);

        log('✅ Photo ${i + 1} uploaded');
      }

      log('✅ All photos uploaded successfully');
      return urls;
    } catch (e) {
      log('❌ Upload multiple photos error: $e');
      rethrow;
    }
  }

  Future<bool> deleteProfile(String userId, String reason) async {
    try {
      final response = await _api.getPostApiResponse(
        '/api/v1/profile/delete-profile-user',
        body: {"userId": userId, "reason": reason},
      );

      return response["status"] == true;
    } catch (e) {
      rethrow;
    }
  }
}
