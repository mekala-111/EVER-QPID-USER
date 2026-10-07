import 'dart:developer';
import 'package:everqpidapp/Features/profile/model/preferences_model.dart';
import 'package:everqpidapp/Features/profile/repository/preferences_repository.dart';
import 'package:flutter/material.dart';

class PreferencesViewModel extends ChangeNotifier {
  final PreferencesRepository _repository = PreferencesRepository();

  UserPreferences? _preferences;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _isResetting = false;
  String? _errorMessage;
  String? _successMessage;
  bool _isSubscribed = false;

  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isResetting => _isResetting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get hasPreferences => _preferences != null;
  bool get isSubscribed => _isSubscribed;

  bool canEditField(String fieldName) {
    if (!_isSubscribed) {
      return fieldName == 'age' || fieldName == 'distance';
    }
    return true;
  }

  /// Fetch user preferences
  Future<void> fetchPreferences() async {
    log('🎬 fetchPreferences called');

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getPreferences();

      _preferences = response.preferences;
      _isSubscribed = response.isSubscribed;
      _errorMessage = null;

      log('✅ Preferences loaded: ${_preferences != null}');
      log('📱 Subscription status: $_isSubscribed');
    } catch (e) {
      log('❌ Error fetching preferences: $e');
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save preferences
  Future<bool> savePreferences(UserPreferences newPreferences) async {
    log('💾 savePreferences called');

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.savePreferences(newPreferences);

      if (response.status && response.preferences != null) {
        _preferences = response.preferences;
        _isSubscribed = response.isSubscribed;
        _successMessage = response.message;
        _errorMessage = null;

        log('✅ Preferences saved successfully');
        log('📱 Subscription status: $_isSubscribed');

        _isSaving = false;
        notifyListeners();

        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });

        return true;
      } else {
        _errorMessage = response.message;
        log('⚠️ Save failed: ${response.message}');

        _isSaving = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      log('❌ Error saving preferences: $e');
      _errorMessage = _getErrorMessage(e);

      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Reset preferences to default
  Future<bool> resetPreferences() async {
    if (_preferences == null) {
      _errorMessage = 'No preferences to reset';
      notifyListeners();
      return false;
    }

    log('🔄 resetPreferences called');

    _isResetting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final response = await _repository.resetPreferences(_preferences!.userId);

      if (response.status && response.preferences != null) {
        _preferences = response.preferences;
        _isSubscribed = response.isSubscribed;
        _successMessage = 'Preferences reset successfully';
        _errorMessage = null;

        log('✅ Preferences reset successfully');

        _isResetting = false;
        notifyListeners();

        Future.delayed(const Duration(seconds: 3), () {
          _successMessage = null;
          notifyListeners();
        });

        return true;
      } else {
        _errorMessage = response.message;
        log('⚠️ Reset failed: ${response.message}');

        _isResetting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      log('❌ Error resetting preferences: $e');
      _errorMessage = _getErrorMessage(e);

      _isResetting = false;
      notifyListeners();
      return false;
    }
  }

  /// Update specific fields (partial update)
  Future<bool> updateField(String field, dynamic value) async {
    if (_preferences == null) {
      _errorMessage = 'No preferences to update';
      notifyListeners();
      return false;
    }

    final updates = {field: value};

    try {
      final response = await _repository.updatePartialPreferences(updates);

      if (response.status && response.preferences != null) {
        _preferences = response.preferences;
        _isSubscribed = response.isSubscribed;
        _successMessage = 'Updated successfully';

        log('✅ Field $field updated');

        notifyListeners();

        Future.delayed(const Duration(seconds: 2), () {
          _successMessage = null;
          notifyListeners();
        });

        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  /// Update age range (allowed for free users)
  Future<bool> updateAgeRange(int minAge, int maxAge) async {
    if (_preferences == null) return false;

    final updated = _preferences!.copyWith(minAge: minAge, maxAge: maxAge);
    return await savePreferences(updated);
  }

  /// Update distance (allowed for free users)
  Future<bool> updateDistance(int distanceInKm) async {
    if (_preferences == null) return false;

    final updated = _preferences!.copyWith(
      distance: distanceInKm * 1000,
    );

    return await savePreferences(updated);
  }

  /// Update languages (premium only)
  Future<bool> updateLanguages(List<String> languages) async {
    if (_preferences == null) return false;
    if (!_isSubscribed) {
      _errorMessage = 'Premium feature. Subscribe to unlock.';
      notifyListeners();
      return false;
    }

    final updated = _preferences!.copyWith(otherLanguages: languages);
    return await savePreferences(updated);
  }

  /// Update height range (premium only)
  Future<bool> updateHeightRange(int minHeight, int maxHeight) async {
    if (_preferences == null) return false;
    if (!_isSubscribed) {
      _errorMessage = 'Premium feature. Subscribe to unlock.';
      notifyListeners();
      return false;
    }

    final updated = _preferences!.copyWith(
      minHeight: minHeight,
      maxHeight: maxHeight,
    );

    return await savePreferences(updated);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear success message
  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }

  /// Helper to format error messages
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') || errorString.contains('connection')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Session expired. Please login again.';
    } else if (errorString.contains('404')) {
      return 'Preferences not found.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  /// Reset state
  void reset() {
    log('🔄 Resetting PreferencesViewModel');
    _preferences = null;
    _isLoading = false;
    _isSaving = false;
    _isResetting = false;
    _errorMessage = null;
    _successMessage = null;
    _isSubscribed = false;
    notifyListeners();
  }

  @override
  void dispose() {
    log('🗑️ Disposing PreferencesViewModel');
    super.dispose();
  }
}
