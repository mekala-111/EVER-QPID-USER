// lib/features/home/repository/profile_repository.dart

import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/home/model/discovery_profile_model.dart';
import 'package:everqpidapp/Features/home/view_model/matching_view_model.dart';
import 'package:everqpidapp/Features/subscription/view/subscription_bottom_sheet.dart';
import 'package:everqpidapp/Settings/constants/app_url.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeProfileRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  HomeProfileRepository();

  /// Fetches all profiles with pagination
  ///
  /// [pageNumber] - The page number to fetch (starts from 1)
  /// [pageSize] - Number of profiles per page
  ///
  /// Returns [DiscoveryProfilesResponse] containing list of profiles and pagination info
  /// Throws exception if the request fails
  Future<DiscoveryProfilesResponse> getAllProfiles({
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      log('📡 Fetching profiles - Page: $pageNumber, Size: $pageSize');

      // Prepare query parameters
      final queryParameters = {
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      // Make GET request using your NetworkApiServiceV2
      // The service automatically adds the Bearer token from LoggedInUser.accessToken
      final response = await _apiService.getGetApiResponse(
        AppUrl.getAllProfiles, // Define this in your AppUrl class
        queryParameters: queryParameters,
      );

      log('✅ Profiles fetched successfully');

      // Check if response is successful
      if (response['status'] == true && response['statusCode'] == 200) {
        // Parse the response data
        final profilesResponse =
            DiscoveryProfilesResponse.fromJson(response['data']);
        log(
          '📊 Loaded ${profilesResponse.users.length} profiles, Has more: ${profilesResponse.hasNext}',
        );
        return profilesResponse;
      } else {
        // Handle unsuccessful response
        throw Exception(response['message'] ?? 'Failed to fetch profiles');
      }
    } catch (e) {
      log('❌ Error fetching profiles: $e');
      // Re-throw the error to be handled by ViewModel
      rethrow;
    }
  }

  /// Fetches more profiles for pagination (load more functionality)
  /// This is a convenience method that calls getAllProfiles
  Future<DiscoveryProfilesResponse> loadMoreProfiles({
    required int pageNumber,
    required int pageSize,
  }) async {
    return await getAllProfiles(pageNumber: pageNumber, pageSize: pageSize);
  }

  /// Future implementation: Save swipe action (like/dislike)
  ///
  /// [profileId] - The ID of the profile that was swiped
  /// [isLike] - true if liked, false if disliked
  Future<bool> saveSwipeAction({
    required String profileId,
    required bool isLike,
    // required MatchingViewModel matchingVM,
    required BuildContext context,
  }) async {
    try {
      final matchingVM = context.read<MatchingViewModel>();
      log('💗 Saving swipe action - Profile: $profileId, Like: $isLike');

      // final body = {
      //   'profileId': profileId,
      //   'action': isLike ? 'like' : 'dislike',
      // };
      late final Map<String, dynamic> response;
      isLike
          ? response = await matchingVM.sendLike(profileId)
          : response = await matchingVM.sendUnlike(profileId, context);
      // : log('User disliked profile: $profileId');

      // TODO: Update with your actual endpoint
      // final response = await _apiService.getPostApiResponse(
      //   '/api/v1/swipe/action', // Replace with actual endpoint
      //   body: body,
      // );

      if (response['status'] == true) {
        log('✅ Swipe action saved successfully');
        return true;
      } else {
        log('⚠️ Failed to save swipe action: ${response['message']}');
        response['statusCode'] == 400
            ? showSubscriptionBottomSheet(context: context)
            : null;
        return false;
      }
    } catch (e) {
      log('❌ Error saving swipe action: $e');
      return false;
    }
  }

  /// Future implementation: Report a profile
  ///
  /// [profileId] - The ID of the profile to report
  /// [reason] - Reason for reporting
  Future<bool> reportProfile({
    required String profileId,
    required String reason,
  }) async {
    try {
      log('🚨 Reporting profile: $profileId');

      final body = {'profileId': profileId, 'reason': reason};

      // TODO: Update with your actual endpoint
      final response = await _apiService.getPostApiResponse(
        '/api/v1/profile/report', // Replace with actual endpoint
        body: body,
      );

      if (response['status'] == true) {
        log('✅ Profile reported successfully');
        return true;
      } else {
        log('⚠️ Failed to report profile: ${response['message']}');
        return false;
      }
    } catch (e) {
      log('❌ Error reporting profile: $e');
      return false;
    }
  }
}
