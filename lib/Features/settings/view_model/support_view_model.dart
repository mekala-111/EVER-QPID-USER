import 'dart:typed_data';

import 'package:everqpidapp/Features/settings/model/support_category_model.dart';
import 'package:everqpidapp/Features/settings/repository/support_repository.dart';
import 'package:flutter/material.dart';
import 'package:everqpidapp/Features/onboarding/view_model/photo_upload_view_model.dart';
import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';

class SupportViewModel extends ChangeNotifier {
  final SupportRepository _repo = SupportRepository();

  bool isLoading = false;
  bool isSending = false;

  List<SupportCategory> categories = [];
  String? errorMessage;

  // Future<void> fetchCategories(String userId) async {
  //   try {
  //     isLoading = true;
  //     notifyListeners();

  //     // final userId = LoggedInUser.id ?? "";
  //     log('user id at support view model: $userId');
  //     final list = await _repo.getSupportCategories(userId);

  //     categories = list.map((e) {
  //       return SupportCategory(
  //         id: e["category"] ?? "",
  //         name: e["categoryName"] ?? "Unknown",
  //       );
  //     }).toList();
  //   } catch (e) {
  //     errorMessage = e.toString();
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<bool> sendSupportRequest({
    required String email,
    required String firstName,
    required String subject,
    required String category,
    required String description,
    required List<Uint8List> attachments,
  }) async {
    try {
      isSending = true;
      notifyListeners();

      final userId = LoggedInUser.id ?? "";

      // Upload attachments first (bytes — works on web + mobile)
      final uploadVM = PhotoUploadViewModel();
      final uploadedFiles = await uploadVM.uploadImages(attachments);

      final body = {
        "userId": userId,
        "email": email,
        "firstName": firstName,
        "category": category,
        "subject": subject,
        "description": description,
        "attachments": uploadedFiles,
      };

      final response = await _repo.sendSupportRequest(body);

      return response["status"] == true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSending = false;
      notifyListeners();
    }
  }

  void reset() {
    isLoading = false;
    isSending = false;
    categories = [];
    errorMessage = null;
    notifyListeners();
  }
}
