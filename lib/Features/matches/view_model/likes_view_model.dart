import 'dart:developer';

import 'package:everqpidapp/Data/Exceptions/app_exceptions.dart';
import 'package:everqpidapp/Features/matches/model/received_like_profile_model.dart';
import 'package:everqpidapp/Features/matches/model/received_likes_response_model.dart';
import 'package:flutter/material.dart';
import 'package:everqpidapp/features/matches/repository/likes_repository.dart';

class LikesViewModel extends ChangeNotifier {
  final LikesRepository _repo = LikesRepository();

  bool isLoading = false;
  bool isLoadingMore = false;
  String? errorMessage;
  int? statusCode;
  List<ReceivedLikeProfile> receivedLikes = [];
  bool hasNext = false;
  int totalCount = 0;
  bool isSubscribed = false;
  int _currentPage = 1;
  static const int _pageSize = 10;

  /// Coalesce parallel page-1 fetches (MainScreen + MatchesScreen both call).
  Future<void>? _page1InFlight;

  Future<void> fetchReceivedLikes({
    int pageNumber = 1,
    int pageSize = 10,
    bool isRefresh = false,
  }) async {
    final isFirstPage = isRefresh || pageNumber == 1;
    if (isFirstPage && _page1InFlight != null) {
      return _page1InFlight!;
    }

    final run = _fetchReceivedLikesBody(
      pageNumber: pageNumber,
      pageSize: pageSize,
      isRefresh: isRefresh,
    );
    if (isFirstPage) {
      _page1InFlight = run.whenComplete(() => _page1InFlight = null);
      return _page1InFlight!;
    }
    return run;
  }

  Future<void> _fetchReceivedLikesBody({
    required int pageNumber,
    required int pageSize,
    required bool isRefresh,
  }) async {
    try {
      if (isRefresh) {
        isLoading = true;
        _currentPage = 1;
        receivedLikes.clear();
      } else if (pageNumber == 1) {
        isLoading = true;
      } else {
        isLoadingMore = true;
      }
      errorMessage = null;
      notifyListeners();

      final response = await _getReceivedLikesWithSoftRetry(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      if (isRefresh || pageNumber == 1) {
        receivedLikes = response.receivedProfiles;
      } else {
        receivedLikes.addAll(response.receivedProfiles);
      }

      statusCode = response.statusCode;
      hasNext = response.hasNext;
      totalCount = response.totalCount;
      isSubscribed = response.isSubscribed;
      _currentPage = pageNumber;
    } catch (e) {
      log('❌ LikesViewModel error: $e');
      errorMessage = _friendlyError(e);
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Dio already retries once; a couple delayed app-level retries for cold-start
  /// stampede / flaky matching route.
  Future<ReceivedLikesResponse> _getReceivedLikesWithSoftRetry({
    required int pageNumber,
    required int pageSize,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await _repo.getReceivedLikes(
          pageNumber: pageNumber,
          pageSize: pageSize,
        );
      } catch (e) {
        lastError = e;
        if (!_isTransient(e) || attempt == 2) rethrow;
        final waitMs = 900 * (attempt + 1);
        log('⏳ Received likes timed out — soft retry ${attempt + 1} in ${waitMs}ms');
        await Future<void>.delayed(Duration(milliseconds: waitMs));
      }
    }
    throw lastError ?? Exception('Failed to fetch received likes');
  }

  bool _isTransient(Object e) {
    if (e is NetworkTimeoutException) return true;
    final s = e.toString().toLowerCase();
    return s.contains('timeout') ||
        s.contains('connection') ||
        s.contains('network');
  }

  String _friendlyError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('401') || s.contains('unauthorized')) {
      return 'Session expired. Please sign in again.';
    }
    if (s.contains('403') || s.contains('forbidden')) {
      return 'You do not have access to likes right now.';
    }
    if (s.contains('404')) {
      return 'Likes are temporarily unavailable.';
    }
    if (s.contains('timeout') || s.contains('connection')) {
      return 'Network problem loading likes. Pull to retry.';
    }
    if (s.contains('500') || s.contains('502') || s.contains('503')) {
      return 'Server error loading likes. Try again later.';
    }
    return 'Could not load likes. Pull to retry.';
  }

  Future<void> loadMoreLikes() async {
    if (!hasNext || isLoadingMore || isLoading) return;

    await fetchReceivedLikes(
      pageNumber: _currentPage + 1,
      pageSize: _pageSize,
    );
  }

  void reset() {
    isLoading = false;
    isLoadingMore = false;
    errorMessage = null;
    statusCode = null;
    receivedLikes = [];
    hasNext = false;
    totalCount = 0;
    isSubscribed = false;
    _currentPage = 1;
    _page1InFlight = null;
    notifyListeners();
  }
}
