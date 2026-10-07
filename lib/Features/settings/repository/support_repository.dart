import 'dart:developer';

import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';

class SupportRepository {
  final _api = NetworkApiServiceV2.instance;

  Future<List<dynamic>> getSupportCategories(String userId) async {
    final response = await _api.getGetApiResponse(
      "/api/v1/support/get-supports?loginUserId=$userId&pageNumber=1&pageSize=50&status=active",
    );
    log('response at support repository: $response');

    return response["data"]["tickets"] ?? [];
  }

  Future<Map<String, dynamic>> sendSupportRequest(
    Map<String, dynamic> body,
  ) async {
    return await _api.getPostApiResponse(
      "/api/v1/support/sent-support",
      body: body,
    );
  }
}
