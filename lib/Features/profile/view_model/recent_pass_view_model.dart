import 'package:flutter/material.dart';
import '../../../Data/LocalStorage/loggedin_user.dart';
import '../model/recent_pass_model.dart';
import '../repository/recent_pass_repository.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';

class RecentPassViewModel extends ChangeNotifier {
  final _repo = RecentPassRepository();

  bool isLoading = false;
  bool hasNext = false;
  bool isSubscribed = false;

  int _page = 1;
  final int _pageSize = 10;

  final List<RecentPassUser> passedUsers = [];

  void reset() {
    _page = 1;
    hasNext = false;
    passedUsers.clear();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadRecentPasses({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) reset();

    try {
      isLoading = true;
      notifyListeners();

      final response = await _repo.getRecentPassUsers(
        pageNumber: _page,
        pageSize: _pageSize,
      );

      passedUsers.addAll(response.users.map((e) => e.user));
      hasNext = response.hasNext;
      isSubscribed = response.isSubscribed;

      if (hasNext) _page++;
    } catch (e) {
      AppLogger.d('Recent pass error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> savePass(String passedUserId) async {
    try {
      await _repo.saveRecentPassUsers(
        userId: LoggedInUser.id!,
        passedUserIds: [passedUserId],
      );
    } catch (_) {}
  }
}
