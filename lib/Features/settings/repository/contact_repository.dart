import 'dart:developer';

import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/Network/network_api_service_v2.dart';
import 'package:everqpidapp/Features/settings/model/contact_model.dart';

class ContactsRepository {
  final NetworkApiServiceV2 _apiService = NetworkApiServiceV2.instance;

  // Import and hide contacts
  Future<ImportContactsResponse> importContacts({
    required String loginUserId,
    required List<String> contacts,
  }) async {
    try {
      log('📤 Importing ${contacts.length} contacts');

      final request = ImportContactsRequest(
        loginUserId: loginUserId,
        contacts: contacts,
      );

      final response = await _apiService.getPostApiResponse(
        '/api/v1/contacts/import-contacts',
        body: request.toJson(),
      );

      log('📥 Import contacts response: $response');

      return ImportContactsResponse.fromJson(response);
    } catch (e) {
      log('❌ Import contacts error: $e');
      rethrow;
    }
  }

  // Get hidden contacts
  Future<GetHiddenContactsResponse> getHiddenContacts() async {
    try {
      log('📤 Fetching hidden contacts');

      final response = await _apiService.getGetApiResponse(
        '/api/v1/contacts/hidden-contacts',
        // body: {'loginUserId': LoggedInUser.id ?? ''},
      );

      log('📥 Hidden contacts response: $response and ${LoggedInUser.id}');

      return GetHiddenContactsResponse.fromJson(response);
    } catch (e) {
      log('❌ Get hidden contacts error: $e');
      rethrow;
    }
  }

  // Remove hidden contacts
  Future<RemoveHiddenContactsResponse> removeHiddenContacts({
    required String loginUserId,
    required List<String> contacts,
  }) async {
    try {
      log('📤 Removing ${contacts.length} hidden contacts');

      final request = RemoveHiddenContactsRequest(
        loginUserId: loginUserId,
        contacts: contacts,
      );

      final response = await _apiService.getPostApiResponse(
        '/api/v1/contacts/remove-hidden-contacts',
        body: request.toJson(),
      );

      log('📥 Remove hidden contacts response: $response');

      return RemoveHiddenContactsResponse.fromJson(response);
    } catch (e) {
      log('❌ Remove hidden contacts error: $e');
      rethrow;
    }
  }
}
