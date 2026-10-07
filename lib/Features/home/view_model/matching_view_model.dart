// lib/features/matching/view_model/matching_view_model.dart

import 'dart:developer';
import 'package:everqpidapp/Data/services/analytics_service.dart';
import 'package:everqpidapp/Features/profile/view_model/recent_pass_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repository/matching_repository.dart';

class MatchingViewModel extends ChangeNotifier {
  final MatchingRepository _repository = MatchingRepository();

  bool isLoading = false;
  String? errorMessage;

  Future<Map<String, dynamic>> sendLike(String toUserId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await _repository.likeUser(toUserId);

      if (response["status"] == true) {
        log("Liked: $toUserId");
        final data = response['data'];
        final matched = data is Map &&
            (data['isMatch'] == true ||
                data['matched'] == true ||
                data['isMatched'] == true);
        if (matched || response['isMatch'] == true) {
          AnalyticsService.instance.logMatchCreated();
        }
        return response;
      } else {
        errorMessage = response["message"];
        return response;
      }
    } catch (e) {
      log("Like error: $e");
      errorMessage = e.toString();
      return {"status": false, "message": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> sendUnlike(
    String toUserId,
    BuildContext context,
  ) async {
    try {
      final recentPassVm = context.read<RecentPassViewModel>();
      isLoading = true;
      notifyListeners();

      final response = await _repository.unlikeUser(toUserId);
      await recentPassVm.savePass(toUserId);

      if (response["status"] == true) {
        log("Unliked: $toUserId");
        log("Unlike response: $response");
        return response;
      } else {
        errorMessage = response["message"];
        return response;
      }
    } catch (e) {
      log("Unlike error: $e");
      errorMessage = e.toString();
      return {"status": false, "message": e.toString()};
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
