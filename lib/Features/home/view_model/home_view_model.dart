// lib/features/home/viewmodel/home_viewmodel.dart

import 'dart:developer';
import 'package:everqpidapp/Features/home/repository/home_profile_repository.dart';
import 'package:everqpidapp/Features/home/model/discovery_profile_model.dart';
import 'package:flutter/material.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeProfileRepository _repository = HomeProfileRepository();

  HomeViewModel();

  // State variables
  List<DiscoveryProfile> _profiles = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;
  int _currentIndex = 0;

  // Getters
  List<DiscoveryProfile> get profiles => _profiles;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;
  int get currentIndex => _currentIndex;
  bool get hasProfiles => _profiles.isNotEmpty;
  DiscoveryProfile? get currentProfile =>
      _currentIndex < _profiles.length ? _profiles[_currentIndex] : null;

  /// Fetches initial profiles
  /// This method is called when the screen is first loaded
  /// Token is automatically handled by NetworkApiServiceV2 from LoggedInUser
  Future<void> fetchProfiles() async {
    log('🎬 Starting to fetch profiles...');

    // Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Reset pagination
      _currentPage = 1;

      log('📞 Calling repository to fetch profiles...');
      // Fetch profiles from repository
      // No need to pass token - NetworkApiServiceV2 handles it automatically
      final response = await _repository.getAllProfiles(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      log('✅ Profiles fetched successfully: ${response.users.length} profiles');

      // Update state with fetched profiles
      _profiles = response.users;
      _hasMoreData = response.hasNext;
      _currentIndex = 0;
      _isLoading = false;
      _errorMessage = null;

      notifyListeners();
    } catch (e) {
      // Handle errors
      log('❌ Error in fetchProfiles: $e');
      _isLoading = false;
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Loads more profiles (pagination)
  /// This method is called when user scrolls to the end or swipes through all profiles
  Future<void> loadMoreProfiles() async {
    // Prevent multiple simultaneous requests
    if (_isLoadingMore || !_hasMoreData) {
      log(
        '⚠️ Skipping loadMoreProfiles - isLoadingMore: $_isLoadingMore, hasMoreData: $_hasMoreData',
      );
      return;
    }

    log('📥 Loading more profiles...');
    _isLoadingMore = true;
    notifyListeners();

    try {
      // Increment page number
      _currentPage++;
      log('📄 Loading page $_currentPage');

      // Fetch next page of profiles
      final response = await _repository.loadMoreProfiles(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      log('✅ Loaded ${response.users.length} more profiles');

      // Append new profiles to existing list
      _profiles.addAll(response.users);
      _hasMoreData = response.hasNext;
      _isLoadingMore = false;

      notifyListeners();
    } catch (e) {
      // Handle errors
      log('❌ Error in loadMoreProfiles: $e');
      _isLoadingMore = false;
      _currentPage--; // Revert page increment
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
    }
  }

  /// Handles swipe action (like or dislike)
  ///
  /// [isLike] - true if user liked the profile, false if disliked
  void onSwipe(bool isLike, BuildContext context) {
    if (_currentIndex >= _profiles.length) {
      log('⚠️ No more profiles to swipe');
      return;
    }

    final currentProfileId = _profiles[_currentIndex].id;
    log(
      '👆 Swiped ${isLike ? "RIGHT (LIKE)" : "LEFT (DISLIKE)"} on profile: $currentProfileId',
    );

    // Save the swipe action in background (don't wait for response)
    _saveSwipeAction(currentProfileId, isLike, context);

    // Move to next profile
    if (_currentIndex < _profiles.length - 1) {
      _currentIndex++;
      log('➡️ Moving to profile index $_currentIndex');
      notifyListeners();
    } else {
      // If reached end of current profiles and more data available, load more
      if (_hasMoreData) {
        log('🔄 Reached end of current profiles, loading more...');
        _currentIndex++;
        notifyListeners();
        loadMoreProfiles();
      } else {
        // No more profiles available
        log('🏁 No more profiles available');
        _currentIndex++;
        notifyListeners();
      }
    }
  }

  /// Saves swipe action to backend (fire and forget)
  Future<void> _saveSwipeAction(
      String profileId, bool isLike, BuildContext context) async {
    try {
      await _repository.saveSwipeAction(
          profileId: profileId, isLike: isLike, context: context);
    } catch (e) {
      // Silently fail - don't disrupt user experience
      log('⚠️ Failed to save swipe action: $e');
    }
  }

  /// Refreshes the profile list (pull to refresh)
  Future<void> refreshProfiles() async {
    log('🔄 Refreshing profiles...');
    _currentPage = 1;
    _hasMoreData = true;
    await fetchProfiles();
  }

  /// Reports a profile
  Future<bool> reportProfile(String profileId, String reason) async {
    try {
      log('🚨 Reporting profile: $profileId');
      final success = await _repository.reportProfile(
        profileId: profileId,
        reason: reason,
      );
      return success;
    } catch (e) {
      log('❌ Error reporting profile: $e');
      return false;
    }
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Helper method to format error messages
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('internet')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized') ||
        errorString.contains('token')) {
      return 'Session expired. Please login again.';
    } else if (errorString.contains('403') ||
        errorString.contains('forbidden')) {
      return 'Access denied. Your account may be inactive.';
    } else if (errorString.contains('404')) {
      return 'No profiles found.';
    } else if (errorString.contains('410')) {
      return 'Your account has been suspended or deleted.';
    } else if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Resets the view model state
  void reset() {
    log('🔄 Resetting HomeViewModel');
    _profiles = [];
    _currentPage = 1;
    _currentIndex = 0;
    _hasMoreData = true;
    _errorMessage = null;
    _isLoading = false;
    _isLoadingMore = false;
    notifyListeners();
  }

  @override
  void dispose() {
    log('🗑️ Disposing HomeViewModel');
    super.dispose();
  }
}
