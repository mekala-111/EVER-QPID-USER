import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';

class FCMRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  FCMRepository();

  /// Save FCM token to backend
  Future<Map<String, dynamic>> saveFCMToken({
    required String fcmToken,
  }) async {
    return await _apiService.getPostApiResponse(
      '/api/v1/fcm/register-fcm',
      body: {'fcmToken': fcmToken},
    );
  }

  /// Update FCM token (same as save but more semantic)
  Future<Map<String, dynamic>> updateFCMToken({
    required String fcmToken,
    required String authToken,
  }) async {
    return await saveFCMToken(fcmToken: fcmToken);
  }
}
