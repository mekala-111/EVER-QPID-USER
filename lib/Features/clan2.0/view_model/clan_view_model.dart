// features/clan/view_model/clan_view_model.dart

import 'dart:developer';
import 'package:everqpidapp/Features/clan2.0/model/clan_photo_model.dart';
import 'package:everqpidapp/Features/clan2.0/model/clan_profile_model.dart';
import 'package:everqpidapp/Features/clan2.0/repository/clan_repository.dart';
import 'package:flutter/material.dart';

class ClanViewModel extends ChangeNotifier {
  final ClanRepository _repository = ClanRepository();

  // Location state
  double? _currentLat;
  double? _currentLng;
  String? _currentLocationName;
  String? _currentCity;
  String? _currentState;
  String? _currentCountry;

  // Selected location (for offline picker)
  String? _selectedCity;
  String? _selectedState;
  String? _selectedCountry;

  // Purpose/Clan type state
  String? _selectedClanType;
  bool _purposeSelected = false;

  // Profile data
  List<ClanProfile> _profiles = [];
  List<ClanProfile> _mostActiveProfiles = [];
  Map<String, List<ClanPhoto>> _clanPhotos = {};

  // Loading states
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isSubscribed = true;

  // Getters
  bool get isSubscribed => _isSubscribed;
  double? get currentLat => _currentLat;
  double? get currentLng => _currentLng;
  String? get currentLocationName => _currentLocationName;
  String? get currentCity => _currentCity;
  String? get currentState => _currentState;
  String? get currentCountry => _currentCountry;
  String? get selectedCity => _selectedCity ?? _currentCity;
  String? get selectedState => _selectedState ?? _currentState;
  String? get selectedCountry => _selectedCountry ?? _currentCountry;
  String? get selectedClanType => _selectedClanType;
  bool get purposeSelected => _purposeSelected;
  List<ClanProfile> get profiles => _profiles;
  List<ClanProfile> get mostActiveProfiles => _mostActiveProfiles;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  /// Get display name for location
  String get locationDisplayName {
    if (_selectedCity != null) {
      return _selectedCity!;
    }
    return _currentLocationName ?? _currentCity ?? 'Select Location';
  }

  /// Get full location string
  String get fullLocationName {
    final parts = <String>[];
    if (_selectedCity != null) parts.add(_selectedCity!);
    if (_selectedState != null) parts.add(_selectedState!);
    if (_selectedCountry != null) parts.add(_selectedCountry!);

    if (parts.isEmpty) {
      if (_currentCity != null) parts.add(_currentCity!);
      if (_currentState != null) parts.add(_currentState!);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Select Location';
  }

  /// Get photos for specific clan type
  List<ClanPhoto> getClanPhotos(String clanType) {
    return _clanPhotos[clanType] ?? [];
  }

  /// Set location with geocoded data
  void setLocation(
    double lat,
    double lng, {
    String? locationName,
    String? city,
    String? state,
  }) {
    _currentLat = lat;
    _currentLng = lng;
    _currentLocationName = locationName;
    _currentCity = city;
    _currentState = state;

    // Initialize selected values
    _selectedCity = city;
    _selectedState = state;

    log('📍 Location set: $locationName (City: $city, State: $state)');
    notifyListeners();
  }

  /// Update selected location from offline picker
  Future<void> updateSelectedLocation({
    required String city,
    required String state,
    required String country,
  }) async {
    if (_selectedCity == city &&
        _selectedState == state &&
        _selectedCountry == country) {
      return;
    }

    _selectedCity = city;
    _selectedState = state;
    _selectedCountry = country;
    _currentLocationName = city;

    log('📍 Location changed to: $city, $state, $country');
    notifyListeners();

    // Refresh profiles if clan type is selected
    if (_selectedClanType != null) {
      await searchClanProfiles(_selectedClanType!);
    }
  }

  /// Update clan location on backend (called from Select Purpose)
  Future<void> updateClanLocation(String userId, String clanType) async {
    if (_currentLat == null || _currentLng == null) {
      throw Exception('Location not available');
    }

    try {
      log('🔄 Updating clan location for $clanType...');

      await _repository.updateClanLocation(
        userId: userId,
        clanType: clanType,
        lat: _currentLat!,
        lng: _currentLng!,
        city: _currentCity,
        state: _currentState,
      );

      _selectedClanType = clanType;
      _purposeSelected = true;

      log('✅ Clan location updated successfully');
      notifyListeners();
    } catch (e) {
      log('❌ Failed to update clan location: $e');
      rethrow;
    }
  }

  /// Search clan profiles by city and type
  Future<void> searchClanProfiles(String clanType) async {
    final targetCity = _selectedCity ?? _currentCity;

    if (targetCity == null || targetCity.isEmpty) {
      log('⚠️ Cannot search: No city selected');
      _setError('Please select a city');
      notifyListeners();
      return;
    }

    _selectedClanType = clanType;
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    _profiles = [];

    notifyListeners();

    try {
      log('🔍 Searching profiles - City: $targetCity, Type: $clanType');

      final response = await _repository.searchClanProfiles(
        targetCity: targetCity,
        clanType: clanType,
      );

      _profiles = response.data.users;

      log('✅ Loaded ${_profiles.length} profiles');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('❌ Error searching profiles: $e');
      _setError(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Prepare for fetching profiles (called synchronously, no notifyListeners)
  void prepareProfilesSearch(String clanType) {
    _selectedClanType = clanType;
    _profiles = [];
    _isLoading = false;
    _hasError = false;
    _errorMessage = null;

    log('📋 Prepared for searching $clanType profiles');
  }

  /// LEGACY: Fetch profiles with pagination (keep for backward compatibility)
  Future<void> fetchProfiles(String userId) async {
    if (_selectedClanType == null ||
        _currentLat == null ||
        _currentLng == null) {
      log('⚠️ Cannot fetch profiles: Missing clan type or location');
      return;
    }

    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.fetchClanProfiles(
        userId: userId,
        clanType: _selectedClanType!,
        lat: _currentLat!,
        lng: _currentLng!,
        pageNumber: 1,
        pageSize: 50,
      );

      _profiles = result['profiles'] as List<ClanProfile>;
      _isSubscribed = result['isSubscribed'] as bool;

      log('✅ Fetched ${_profiles.length} profiles');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('❌ Error fetching profiles: $e');
      _setError(e.toString());
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch stacked photos for all clan types
  Future<void> fetchAllClanPhotos(String userId) async {
    if (_currentLat == null || _currentLng == null) {
      log('⚠️ Cannot fetch photos: Location not available');
      return;
    }

    final clanTypes = ['home', 'work', 'study', 'quest'];

    for (final clanType in clanTypes) {
      try {
        final photos = await _repository.fetchClanPhotos(
          userId: userId,
          clanType: clanType,
          lat: _currentLat!,
          lng: _currentLng!,
        );
        _clanPhotos[clanType] = photos;
      } catch (e) {
        _clanPhotos[clanType] = [];
      }
    }

    notifyListeners();
  }

  /// Fetch most active profiles
  Future<void> fetchMostActiveProfiles() async {
    if (_currentLat == null || _currentLng == null) {
      log('⚠️ Cannot fetch most active: Location not available');
      return;
    }

    try {
      // _mostActiveProfiles = await _repository.fetchMostActiveProfiles(
      //   lat: _currentLat!,
      //   lng: _currentLng!,
      // );
      final res = await _repository.fetchMostActiveProfiles(
        lat: _currentLat!,
        lng: _currentLng!,
      );
      _mostActiveProfiles = res['profiles'] as List<ClanProfile>;
      _isSubscribed = res['isSubscribed'] as bool;
      log('✅ Fetched ${_mostActiveProfiles.length} most active profiles');
      notifyListeners();
    } catch (e) {
      log('❌ Error fetching most active: $e');
      _mostActiveProfiles = [];
      notifyListeners();
    }
  }

  /// Refresh profiles for current clan type
  Future<void> refresh() async {
    if (_selectedClanType != null) {
      await searchClanProfiles(_selectedClanType!);
    }
  }

  /// Clear selected clan WITHOUT notifying (safe for initState)
  void clearSelectedClanSilent() {
    _selectedClanType = null;
    _profiles = [];
    _isLoading = false;
    _hasError = false;
    _errorMessage = null;

    log('🔄 Cleared selected clan (silent)');
  }

  /// Clear selected clan WITH notification (safe for user actions)
  void clearSelectedClan() {
    clearSelectedClanSilent();
    notifyListeners();
    log('🔄 Cleared selected clan (notified)');
  }

  /// Reset all state
  void reset() {
    _selectedClanType = null;
    _purposeSelected = false;
    _profiles = [];
    _mostActiveProfiles = [];
    _clanPhotos = {};
    _isLoading = false;
    _hasError = false;
    _errorMessage = null;
    _selectedCity = null;
    _selectedState = null;
    _selectedCountry = null;
    _currentLat = null;
    _currentLng = null;
    _currentLocationName = null;
    _currentCity = null;
    _currentState = null;
    _currentCountry = null;

    log('🧹 ViewModel reset');
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
  }

  void clearError() {
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }
}
