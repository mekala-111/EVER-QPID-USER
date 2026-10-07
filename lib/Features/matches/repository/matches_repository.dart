import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/matches/model/match_response_model.dart';
import 'package:everqpidapp/Settings/constants/app_url.dart';

class MatchesRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  Future<MatchListResponse> getMatches({
    required int pageNumber,
    required int pageSize,
  }) async {
    final response = await _apiService.getGetApiResponse(
      AppUrl.getMyMatches,
      queryParameters: {
        "pageNumber": pageNumber.toString(),
        "pageSize": pageSize.toString(),
      },
    );

    if (response["status"] == true && response["statusCode"] == 200) {
      return MatchListResponse.fromJson(response["data"]);
    }
    throw Exception(response["message"] ?? "Failed to fetch matches");
  }
}
