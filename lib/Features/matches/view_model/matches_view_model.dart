// lib/features/matches/viewmodel/matches_view_model.dart

import 'dart:developer';
import 'package:everqpidapp/Features/matches/model/match_response_model.dart';
import 'package:everqpidapp/Features/matches/repository/matches_repository.dart';
import 'package:flutter/material.dart';

class MatchesViewModel extends ChangeNotifier {
  final MatchesRepository _repo = MatchesRepository();

  // State variables
  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;

  List<MatchUserProfile> matches = [];
  bool hasNext = false;
  int totalCount = 0;
  int _currentPage = 1;
  final int _pageSize = 10;

  // Track if initial fetch is done to prevent duplicate calls
  bool _hasInitialLoad = false;

  /// Fetches matches with proper state management
  ///
  /// [refresh] - If true, clears existing data and fetches from page 1
  /// [loadMore] - If true, loads next page (for pagination)
  Future<void> fetchMatches(
      {bool refresh = false, bool loadMore = false}) async {
    log('🎬 fetchMatches called - refresh: $refresh, loadMore: $loadMore, hasInitialLoad: $_hasInitialLoad');

    // Prevent duplicate initial loads
    if (!refresh && !loadMore && _hasInitialLoad) {
      log('⚠️ Skipping fetch - already loaded');
      return;
    }

    // Prevent multiple simultaneous requests
    if (isLoading || (loadMore && isLoadingMore)) {
      log('⚠️ Already loading, skipping');
      return;
    }

    // Handle refresh
    if (refresh) {
      log('🔄 Refreshing matches from page 1');
      matches.clear();
      _currentPage = 1;
      _hasInitialLoad = false;
      hasNext = false;
      totalCount = 0;
      errorMessage = null;
    }

    // Handle pagination
    if (loadMore && !hasNext) {
      log('⚠️ No more data to load');
      return;
    }

    // Set loading state
    if (loadMore) {
      isLoadingMore = true;
    } else {
      isLoading = true;
    }
    errorMessage = null;
    notifyListeners();

    try {
      log('📞 Calling API - page: $_currentPage, size: $_pageSize');

      final response = await _repo.getMatches(
        pageNumber: _currentPage,
        pageSize: _pageSize,
      );

      log('✅ Received ${response.matches.length} matches, hasNext: ${response.hasNext}');

      if (refresh || _currentPage == 1) {
        // Replace all matches on refresh or first load
        matches = response.matches;
        log('📝 Replaced matches list - total: ${matches.length}');
      } else {
        // Append for pagination
        matches.addAll(response.matches);
        log('➕ Appended matches - total: ${matches.length}');
      }

      hasNext = response.hasNext;
      totalCount = response.totalCount;

      // Increment page only if there's more data
      if (hasNext) {
        _currentPage++;
        log('📄 Incremented page to $_currentPage');
      }

      _hasInitialLoad = true;
      errorMessage = null;
    } catch (e) {
      log('❌ Error fetching matches: $e');
      errorMessage = _getErrorMessage(e);

      // Revert page increment if pagination failed
      if (loadMore && _currentPage > 1) {
        _currentPage--;
      }
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Load more matches (pagination)
  Future<void> loadMoreMatches() async {
    if (hasNext && !isLoadingMore) {
      await fetchMatches(loadMore: true);
    }
  }

  /// Refresh matches (pull to refresh)
  Future<void> refreshMatches() async {
    await fetchMatches(refresh: true);
  }

  /// Helper to format error messages
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'No internet connection';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorString.contains('404')) {
      return 'No matches found';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Reset the view model state
  void reset() {
    log('🔄 Resetting MatchesViewModel');
    matches.clear();
    _currentPage = 1;
    _hasInitialLoad = false;
    hasNext = false;
    totalCount = 0;
    errorMessage = null;
    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  @override
  void dispose() {
    log('🗑️ Disposing MatchesViewModel');
    super.dispose();
  }
}
