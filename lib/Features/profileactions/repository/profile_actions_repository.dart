import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/profileactions/model/block_reason_model.dart';

class ProfileActionsRepository {
  final NetworkApiServiceV2 _apiService =
      NetworkApiServiceV2.instance; // NetworkApiServiceV2 instance

  ProfileActionsRepository();

  /// Submit report
  Future<bool> submitReport({
    required String reporterId,
    required String reportedUserId,
    required String reason,
  }) async {
    try {
      final response = await _apiService.getPostApiResponse(
        '/api/v1/report/report-user',
        body: {
          'reporter': reporterId,
          'reported': reportedUserId,
          'reason': reason,
        },
      );

      if (response != null && response['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      log('Error submitting report: $e');
      throw Exception('Failed to submit report $e');
    }
  }

  /// Block user
  Future<bool> blockUser({
    required String blockedAccountId,
    required List<String> selectedReasons,
  }) async {
    try {
      final response = await _apiService.getPostApiResponse(
        '/api/v1/block/block-user',
        body: {
          'blockedAccountId': blockedAccountId,
          'selectedReasons': selectedReasons,
        },
      );

      if (response != null && response['status'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      log('Error blocking user: $e');
      throw Exception('Failed to block user');
    }
  }

  /// Unblock user
  Future<bool> unblockUser({required String blockedUserId}) async {
    try {
      final response = await _apiService.getDeleteApiResponse(
        '/api/v1/block/unblock-user/$blockedUserId',
        // appned: blockedUserId,
      );
      log(
        'unblock status : type: ${response['data']['unblockStatus'].runtimeType}....${response['data']['unblockStatus']}',
      );
      if (response != null && response['status'] == true) {
        return response['data']['unblockStatus'];
      }
      return false;
    } catch (e) {
      log('Error unblocking user: $e');
      throw Exception('Failed to unblock user');
    }
  }

  /// Fetch blocked users list
  Future<BlockedUsersResponse> fetchBlockedUsers({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await _apiService.getGetApiResponse(
        '/api/v1/block/users/blocked-list/get-all',
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
      );

      if (response != null) {
        return BlockedUsersResponse.fromJson(response);
      }
      return BlockedUsersResponse(
        status: false,
        statusCode: 0,
        message: 'No data',
        blockedUsers: [],
        hasNext: false,
        totalCount: 0,
      );
    } catch (e) {
      log('Error fetching blocked users: $e');
      throw Exception('Failed to fetch blocked users');
    }
  }
}
