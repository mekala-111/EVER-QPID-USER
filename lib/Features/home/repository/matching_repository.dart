import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';

class MatchingRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  Future<dynamic> likeUser(String toUserId) async {
    return await _apiService.getPostApiResponse(
      '/api/v1/matching/like-send',
      body: {"toUserId": toUserId},
    );
  }

  Future<dynamic> unlikeUser(String toUserId) async {
    return await _apiService.getDeleteApiResponse(
      '/api/v1/matching/unlike/$toUserId',
      body: {"toUserId": toUserId},
    );
  }
}
