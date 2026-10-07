import 'package:everqpidapp/Data/LocalStorage/loggedin_user.dart';
import 'package:everqpidapp/Data/services/analytics_service.dart';
import 'package:flutter/material.dart';
import '../model/user_profile_model.dart';
import '../repository/profile_repository.dart';

class GetProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repo = ProfileRepository();

  bool isDeleting = false;
  String? deleteError;
  bool isLoading = false;
  String? errorMessage;
  UserProfileModel? profile;

  Future<void> fetchProfile() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      profile = await _repo.getProfile();
      // Keep sidebar / chrome in sync with API profile.
      if (profile != null) {
        final n = profile!.fullName.trim();
        if (n.isNotEmpty) LoggedInUser.name = n;
        if ((profile!.profileImageUrl ?? '').isNotEmpty) {
          LoggedInUser.profilePic = profile!.profileImageUrl;
        }
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount({
    required String userId,
    required String reason,
  }) async {
    try {
      isDeleting = true;
      deleteError = null;
      notifyListeners();

      final success = await _repo.deleteProfile(userId, reason);

      isDeleting = false;
      notifyListeners();
      if (success) {
        AnalyticsService.instance.logDeleteAccount();
      }
      return success;
    } catch (e) {
      deleteError = e.toString();
      isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    isDeleting = false;
    deleteError = null;
    isLoading = false;
    errorMessage = null;
    profile = null;
    notifyListeners();
  }
}
