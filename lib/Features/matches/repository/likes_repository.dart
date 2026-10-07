import 'dart:developer';

import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/matches/model/received_likes_response_model.dart';
import 'package:everqpidapp/Settings/constants/app_url.dart';

class LikesRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  Future<ReceivedLikesResponse> getReceivedLikes({
    required int pageNumber,
    required int pageSize,
    int maxDistance = 100,
    bool allowOutOfDistance = true,
  }) async {
    try {
      log('📡 Fetching received likes - Page: $pageNumber, Size: $pageSize');

      final queryParameters = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'maxDistance': maxDistance.toString(),
        'allowOutOfDistance': allowOutOfDistance.toString(),
      };

      final response = await _apiService.getGetApiResponse(
        AppUrl.getReceivedLikes,
        queryParameters: queryParameters,
      );

      log('✅ Received likes API call success');

      if (response['status'] == true) {
        final data = response as Map<String, dynamic>;
        final result = ReceivedLikesResponse.fromJson(data);

        log(
          '📊 Loaded ${result.receivedProfiles.length} liked profiles, '
          'hasNext: ${result.hasNext}, total: ${result.totalCount}',
        );

        return result;
      } else {
        final message = response['message'] ?? 'Failed to fetch received likes';
        log('❌ API error: $message');
        throw Exception(message);
      }
    } catch (e) {
      log('❌ Exception in getReceivedLikes: $e');
      rethrow;
    }
  }
}
