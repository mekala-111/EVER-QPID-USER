// features/clan/repository/clan_repository.dart

import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/clan2.0/model/clan_photo_model.dart';
import 'package:everqpidapp/Features/clan2.0/model/clan_profile_model.dart';

class ClanRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  /// Fetch clan profiles with pagination
  Future<Map<String, dynamic>> fetchClanProfiles({
    required String userId,
    required String clanType,
    required double lat,
    required double lng,
    required int pageNumber,
    required int pageSize,
  }) async {
    try {
      final response = await _apiService.getPostApiResponse(
        '/api/v1/clan/fetch-location-profiles',
        queryParameters: {'pageNumber': pageNumber, 'pageSize': pageSize},
        body: {'userId': userId, 'clanType': clanType, 'lat': lat, 'lng': lng},
      );

      // if (response['profiles'] != null) {
      //   final profiles = (response['profiles'] as List)
      //       .map((item) => ClanProfile.fromJson(item))
      //       .toList();
      //   log('✅ Fetched ${profiles.length} profiles for $clanType');
      //   return profiles;
      // }
      // return [];
      final List<ClanProfile> profiles =
          (response['profiles'] as List<dynamic>? ?? [])
              .map((e) => ClanProfile.fromJson(e))
              .toList();

      final bool isSubscribed = response['isSubscribed'] ?? true;

      return {
        'profiles': profiles,
        'isSubscribed': isSubscribed,
        'totalCount': response['totalCount'] ?? 0,
        'totalPages': response['totalPages'] ?? 0,
        'currentPage': response['currentPage'] ?? pageNumber,
      };
    } catch (e) {
      log('❌ Error fetching clan profiles: $e');
      rethrow;
    }
  }

  Future<ClanSearchResponse> searchClanProfiles({
    required String targetCity,
    required String clanType,
  }) async {
    try {
      log('🔍 Searching clan profiles: $targetCity, $clanType');

      final response = await _apiService.getPostApiResponse(
        '/api/v1/clan/search',
        body: {
          'targetCity': targetCity,
          'clanType': clanType,
        },
      );

      final searchResponse = ClanSearchResponse.fromJson(response);
      log('✅ Found ${searchResponse.data.users.length} profiles');

      return searchResponse;
    } catch (e) {
      log('❌ Error searching clan profiles: $e');
      rethrow;
    }
  }

  /// Fetch stacked avatar photos for clan cards
  Future<List<ClanPhoto>> fetchClanPhotos({
    required String userId,
    required String clanType,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiService.getPostApiResponse(
        '/api/v1/clan/fetch-location-profiles-photos',
        body: {'userId': userId, 'clanType': clanType, 'lat': lat, 'lng': lng},
      );

      if (response['status'] == true && response['data'] != null) {
        final photos = (response['data'] as List)
            .map((item) => ClanPhoto.fromJson(item))
            .toList();
        return photos;
      }
      return [];
    } catch (e) {
      log('❌ Error fetching clan photos: $e');
      return [];
    }
  }

  /// Fetch most active profiles
  Future<Map<String, dynamic>> fetchMostActiveProfiles({
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await _apiService.getGetApiResponse(
        '/api/v1/clan/most-active',
        queryParameters: {'lat': lat, 'lng': lng},
      );

      if (response['status'] == true && response['data'] != null) {
        final profiles = (response['data'] as List)
            .map((item) => ClanProfile.fromJson(item))
            .toList();
        final bool isSubscribed = response['isSubscribed'] ?? true;

        return {
          'profiles': profiles,
          'isSubscribed': isSubscribed,
        };
      }
      return {};
    } catch (e) {
      log('❌ Error fetching most active profiles: $e');
      return {};
    }
  }

  /// Update user's clan location with city and state
  Future<void> updateClanLocation({
    required String userId,
    required String clanType,
    required double lat,
    required double lng,
    String? city,
    String? state,
  }) async {
    try {
      final body = {
        'userId': userId,
        'clanType': clanType,
        'lat': lat,
        'lng': lng,
      };

      // Add city and state if available
      if (city != null && city.isNotEmpty) {
        body['city'] = city;
      }
      if (state != null && state.isNotEmpty) {
        body['state'] = state;
      }

      final response = await _apiService.getPostApiResponse(
        '/api/v1/clan/update-location',
        body: body,
      );

      log('✅ Clan location updated: ${response['message']}');
    } catch (e) {
      log('❌ Error updating clan location: $e');
      rethrow;
    }
  }
}
