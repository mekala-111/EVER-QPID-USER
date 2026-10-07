import 'package:flutter/material.dart';
import '../model/block_reason_model.dart';
import '../repository/profile_actions_repository.dart';

class ProfileActionsViewModel extends ChangeNotifier {
  final ProfileActionsRepository _repository = ProfileActionsRepository();

  ProfileActionsViewModel();

  // State
  List<BlockedUser> _blockedUsers = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;
  int _totalCount = 0;

  // Getters
  List<BlockedUser> get blockedUsers => _blockedUsers;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  int get totalCount => _totalCount;

  /// Submit report
  Future<bool> submitReport({
    required String reporterId,
    required String reportedUserId,
    required String reason,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.submitReport(
        reporterId: reporterId,
        reportedUserId: reportedUserId,
        reason: reason,
      );

      _isSubmitting = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Block user
  Future<bool> blockUser({
    required String blockedAccountId,
    required List<String> selectedReasons,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _repository.blockUser(
        blockedAccountId: blockedAccountId,
        selectedReasons: selectedReasons,
      );

      _isSubmitting = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isSubmitting = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Unblock user
  Future<bool> unblockUser({required String blockedUserId}) async {
    _errorMessage = null;

    try {
      final success = await _repository.unblockUser(
        blockedUserId: blockedUserId,
      );

      if (success) {
        // Remove from local list
        _blockedUsers.removeWhere((user) => user.id == blockedUserId);
        _totalCount--;
        notifyListeners();
      }

      return success;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Fetch blocked users list
  Future<void> fetchBlockedUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _blockedUsers = [];
      _hasMoreData = true;
    }

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isLoadingMore = true;
    }
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.fetchBlockedUsers(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      if (_currentPage == 1) {
        _blockedUsers = response.blockedUsers;
      } else {
        _blockedUsers.addAll(response.blockedUsers);
      }

      _hasMoreData = response.hasNext;
      _totalCount = response.totalCount;
      _currentPage++;

      _isLoading = false;
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _isLoadingMore = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Load more blocked users
  Future<void> loadMoreBlockedUsers() async {
    if (!_hasMoreData || _isLoadingMore) return;
    await fetchBlockedUsers();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _blockedUsers = [];
    _currentPage = 1;
    _hasMoreData = true;
    _isLoading = false;
    _isLoadingMore = false;
    _isSubmitting = false;
    _errorMessage = null;
    _totalCount = 0;
    notifyListeners();
  }
}
