import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';

class PhotoUploadRepository {
  final NetworkApiServiceV2 _api = NetworkApiServiceV2.instance;

  /// STEP 1: Get signed URL from backend
  Future<String> getSignedUrl(String fileName) async {
    final body = {
      "fileName": fileName,
      "fieldName": fileName, // backend requires both same
    };

    final response = await _api.getPostApiResponse(
      "/api/v1/signed-url/get-signed-url",
      body: body,
    );

    return response["data"]["signedUrl"];
  }

  /// STEP 2: Upload bytes to S3 using signed URL (PUT).
  /// Uses [List<int>] so web (blob/`XFile`) and mobile both work.
  Future<void> uploadToS3(
    String signedUrl,
    List<int> bytes, {
    String contentType = 'image/jpeg',
  }) async {
    await _api.uploadToSignedUrl(
      signedUrl,
      bytes,
      contentType: contentType,
    );
  }

  /// STEP 3: Convert signedUrl -> public URL
  String convertSignedUrlToPublicUrl(String signedUrl) {
    final baseUrl = signedUrl.split("?").first;
    return baseUrl;
  }
}
