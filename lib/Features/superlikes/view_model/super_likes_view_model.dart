import 'package:everqpidapp/Features/superlikes/model/super_likes_model.dart';
import 'package:everqpidapp/Features/superlikes/repository/super_likes_repository.dart';
import 'package:flutter/material.dart';

class SuperLikesViewModel extends ChangeNotifier {
  final SuperLikesRepository _repository = SuperLikesRepository();

  SuperLikesViewModel();

  // State
  bool _isSendingSuperLike = false;
  String? _errorMessage;

  // Getters
  bool get isSendingSuperLike => _isSendingSuperLike;
  String? get errorMessage => _errorMessage;

  /// Send super like
  Future<SuperLikeResponse> sendSuperLike({
    required String userId,
    required String toUserId,
  }) async {
    _isSendingSuperLike = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.sendSuperLike(
        userId: userId,
        toUserId: toUserId,
      );

      _isSendingSuperLike = false;

      if (!response.isSuccess) {
        _errorMessage = response.message;
      }

      notifyListeners();
      return response;
    } catch (e) {
      _isSendingSuperLike = false;
      _errorMessage = e.toString();
      notifyListeners();

      return SuperLikeResponse(
        status: false,
        statusCode: 500,
        message: 'Failed to send super like',
      );
    }
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _isSendingSuperLike = false;
    _errorMessage = null;
    notifyListeners();
  }
}
