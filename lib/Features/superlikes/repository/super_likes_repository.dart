import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/superlikes/model/super_likes_model.dart';

class SuperLikesRepository {
  final NetworkApiServiceV2 _apiService =
      NetworkApiServiceV2.instance; // NetworkApiServiceV2 instance

  SuperLikesRepository();

  /// Send super like
  Future<SuperLikeResponse> sendSuperLike({
    required String userId,
    required String toUserId,
  }) async {
    try {
      final response = await _apiService.getPostApiResponse(
        '/api/v1/matching/superLike-send',
        body: {
          'userId': userId,
          'toUserId': toUserId,
        },
      );

      return SuperLikeResponse.fromJson(response);
    } catch (e) {
      log('Error sending super like: $e');
      // Return error response
      return SuperLikeResponse(
        status: false,
        statusCode: 500,
        message: 'Failed to send super like',
      );
    }
  }
}
