// lib/features/preferences/repository/preferences_repository.dart

import 'dart:developer';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/profile/model/preferences_model.dart';

class PreferencesRepository {
  final NetworkApiServiceV2 _api = NetworkApiServiceV2.instance;

  /// Get user's search filter preferences
  Future<PreferencesResponse> getPreferences() async {
    try {
      log('📡 Fetching user preferences');

      final response = await _api.getGetApiResponse(
        '/api/v1/profile/get-search-filter',
      );

      log('📦 Response type: ${response.runtimeType}');

      if (response is Map<String, dynamic>) {
        final parsedResponse = PreferencesResponse.fromJson(response);

        if (parsedResponse.preferences != null) {
          log('✅ Preferences loaded successfully');
        } else {
          log('⚠️ No preferences found');
        }

        return parsedResponse;
      } else {
        log('❌ Response is not a Map');
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Error in getPreferences: $e');
      rethrow;
    }
  }

  /// Save/Update user's search filter preferences
  Future<SavePreferencesResponse> savePreferences(
    UserPreferences preferences,
  ) async {
    try {
      log('📤 Saving preferences');
      log('📊 Data: ${preferences.toJson()}');

      final response = await _api.getPostApiResponse(
        '/api/v1/profile/add-preference',
        body: preferences.toJson(),
      );

      log('📦 Response type: ${response.runtimeType}');

      if (response is Map<String, dynamic>) {
        final parsedResponse = SavePreferencesResponse.fromJson(response);

        if (parsedResponse.status) {
          log('✅ Preferences saved successfully');
        } else {
          log('⚠️ Save failed: ${parsedResponse.message}');
        }

        return parsedResponse;
      } else {
        log('❌ Response is not a Map');
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Error in savePreferences: $e');
      rethrow;
    }
  }

  /// Update specific preference fields (partial update)
  Future<SavePreferencesResponse> updatePartialPreferences(
    Map<String, dynamic> updates,
  ) async {
    try {
      log('📤 Updating partial preferences');
      log('📊 Updates: $updates');

      final response = await _api.getPostApiResponse(
        '/api/v1/profile/add-search-filter',
        body: updates,
      );

      if (response is Map<String, dynamic>) {
        return SavePreferencesResponse.fromJson(response);
      } else {
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Error in updatePartialPreferences: $e');
      rethrow;
    }
  }

  /// Reset user preferences to default
  Future<SavePreferencesResponse> resetPreferences(String userId) async {
    try {
      log('🔄 Resetting user preferences for userId: $userId');

      final response = await _api.getPostApiResponse(
        '/api/v1/profile/reset-preference',
        body: {'userId': userId},
      );

      log('📦 Response type: ${response.runtimeType}');

      if (response is Map<String, dynamic>) {
        final parsedResponse = SavePreferencesResponse.fromJson(response);

        if (parsedResponse.status) {
          log('✅ Preferences reset successfully');
        } else {
          log('⚠️ Reset failed: ${parsedResponse.message}');
        }

        return parsedResponse;
      } else {
        log('❌ Response is not a Map');
        throw Exception('Unexpected response format');
      }
    } catch (e) {
      log('❌ Error in resetPreferences: $e');
      rethrow;
    }
  }
}
