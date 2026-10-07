import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/profile/model/liked_profile_model.dart';
import 'package:everqpidapp/Settings/constants/app_url.dart';

class LikedProfilesRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  Future<LikedProfilesResponse> getMyLikedProfiles({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      log("📡 Fetching liked profiles page $pageNumber");

      final queryParams = {
        "pageNumber": pageNumber.toString(),
        "pageSize": pageSize.toString(),
      };

      final response = await _apiService.getGetApiResponse(
        AppUrl.getMyLikedProfiles, // add in AppUrl class
        queryParameters: queryParams,
      );

      if (response["status"] == true && response["statusCode"] == 200) {
        return LikedProfilesResponse.fromJson(response["data"]);
      } else {
        throw Exception(response["message"] ?? "Failed to load liked profiles");
      }
    } catch (e) {
      log("❌ Error fetching liked profiles: $e");
      rethrow;
    }
  }
}
