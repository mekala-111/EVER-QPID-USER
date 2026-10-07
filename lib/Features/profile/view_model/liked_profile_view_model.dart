import 'package:everqpidapp/Features/profile/model/liked_profile_model.dart';
import 'package:everqpidapp/Features/profile/repository/liked_profile_repository.dart';
import 'package:flutter/material.dart';

class LikedProfilesViewModel extends ChangeNotifier {
  final LikedProfilesRepository _repo = LikedProfilesRepository();

  bool isLoading = false;
  String? errorMessage;

  List<LikedProfileData> likedProfiles = [];
  bool hasNext = false;

  Future<void> fetchLikedProfiles() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final res = await _repo.getMyLikedProfiles(
        pageNumber: 1,
        pageSize: 100,
      );

      likedProfiles = res.likedProfiles;
      hasNext = res.hasNext;
    } catch (e) {
      errorMessage = _friendlyError(e);
    }

    isLoading = false;
    notifyListeners();
  }

  String _friendlyError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('timeout') || s.contains('connection')) {
      return 'Network problem loading liked profiles.';
    }
    if (s.contains('401') || s.contains('unauthorized')) {
      return 'Session expired. Please sign in again.';
    }
    if (s.contains('404')) {
      return 'Liked profiles are temporarily unavailable.';
    }
    return 'Could not load liked profiles.';
  }

  void clear() {
    likedProfiles.clear();
    hasNext = false;
    notifyListeners();
  }

  void reset() {
    isLoading = false;
    errorMessage = null;
    likedProfiles = [];
    hasNext = false;
    notifyListeners();
  }
}
