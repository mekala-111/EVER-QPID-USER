import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import '../model/recent_pass_model.dart';

class RecentPassRepository {
  final _api = NetworkApiServiceV2.instance;

  Future<RecentPassResponse> getRecentPassUsers({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      log('📡 Fetching recent passes');

      final response = await _api.getGetApiResponse(
        '/api/v1/profile/get-recent-pass-users',
        queryParameters: {
          'pageNumber': pageNumber.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      return RecentPassResponse.fromJson(response);
    } catch (e) {
      log('❌ Recent pass fetch error: $e');
      rethrow;
    }
  }

  Future<void> saveRecentPassUsers({
    required String userId,
    required List<String> passedUserIds,
  }) async {
    try {
      await _api.getPostApiResponse(
        '/api/v1/profile/save-recent-pass-users',
        body: {
          'userId': userId,
          'recentPassUsers': passedUserIds,
        },
      );
      log('✅ Recent passes saved');
    } catch (e) {
      log('❌ Save recent pass error: $e');
      rethrow;
    }
  }
}
