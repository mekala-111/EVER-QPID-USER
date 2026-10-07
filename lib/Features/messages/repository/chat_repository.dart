import 'dart:developer';
import 'dart:typed_data';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/messages/model/chat_model.dart';
import 'package:everqpidapp/Features/messages/model/other_user_profile_model.dart';
import 'package:everqpidapp/Settings/helper/upload_validation.dart';

class ChatRepository {
  final NetworkApiServiceV2 _api = NetworkApiServiceV2.instance;

  /// ✅ Get recent chats with pagination
  Future<RecentChatsResponse> getRecentChats({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      log('📡 Fetching recent chats - pageSize: $pageSize, pageNumber: $page');

      final response = await _api.getGetApiResponse(
        '/api/v1/chat-Message/recent-chat-list',
        queryParameters: {
          'pageNumber': page,
          'pageSize': pageSize, // ✅ fixed
        },
      );

      if (response is Map<String, dynamic>) {
        log('✅ Recent chats response received');
        return RecentChatsResponse.fromJson(response);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Error in getRecentChats: $e');
      rethrow;
    }
  }

  /// ✅ FIXED: Returns ChatHistoryResponse (single object, not list)
  Future<ChatHistoryResponse> getChatHistory(
    String receiverId, {
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      log('📡 Fetching chat history for: $receiverId (page: $pageNumber, size: $pageSize)');

      final response = await _api.getGetApiResponse(
          '/api/v1/chat-Message/chat-history/$receiverId',
          queryParameters: {
            'pageNumber': pageNumber,
            'pageSize': pageSize,
          });

      if (response is Map<String, dynamic>) {
        log('✅ Chat history response received - page $pageNumber');
        return ChatHistoryResponse.fromJson(response);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Error in getChatHistory: $e');
      rethrow;
    }
  }

  /// Upload audio bytes to S3 (web + mobile; no `dart:io` [File]).
  Future<String> uploadAudioBytes(
    Uint8List bytes, {
    String fileName = 'audio.m4a',
  }) async {
    try {
      UploadValidation.assertValidAudio(bytes);
      final safeName = UploadValidation.sanitizeFileName(fileName);
      log('📤 Uploading audio to S3: $safeName (${bytes.length} bytes)');

      final signedUrlResponse = await _api.getPostApiResponse(
        '/api/v1/signed-url/get-signed-url',
        body: {'fileName': safeName, 'fieldName': safeName},
      );

      final signedUrl = signedUrlResponse['data']['signedUrl'] as String;
      log('✅ Got signed URL for audio');

      await _api.uploadToSignedUrl(
        signedUrl,
        bytes,
        contentType: 'audio/m4a',
      );

      log('✅ Audio uploaded to S3');

      final publicUrl = signedUrl.split('?').first;
      log('✅ Audio public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      log('❌ Error uploading audio to S3: $e');
      rethrow;
    }
  }

  /// Upload image bytes to S3 (web + mobile; no `dart:io` [File]).
  Future<String> uploadImageBytes(
    Uint8List bytes, {
    String fileName = 'image.jpg',
  }) async {
    try {
      UploadValidation.assertValidImage(bytes);
      final mime = UploadValidation.imageContentType(bytes)!;
      final safeName = UploadValidation.sanitizeFileName(fileName);
      log('📤 Uploading image to S3: $safeName (${bytes.length} bytes)');

      final signedUrlResponse = await _api.getPostApiResponse(
        '/api/v1/signed-url/get-signed-url',
        body: {'fileName': safeName, 'fieldName': safeName},
      );

      final signedUrl = signedUrlResponse['data']['signedUrl'] as String;
      log('✅ Got signed URL for image');

      await _api.uploadToSignedUrl(
        signedUrl,
        bytes,
        contentType: mime,
      );

      log('✅ Image uploaded to S3');

      final publicUrl = signedUrl.split('?').first;
      log('✅ Image public URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      log('❌ Error uploading image to S3: $e');
      rethrow;
    }
  }

  Future<OtherProfileDetails> getProfile({required String profileId}) async {
    final response = await _api.getGetApiResponse(
      "/api/v1/profile/users/get-other-profile/$profileId",
    );

    return OtherProfileDetails.fromJson(
      response["data"]["profileDetails"],
    );
  }
}
