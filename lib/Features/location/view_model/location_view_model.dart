import 'dart:async';
import 'dart:developer';

import 'package:everqpidapp/Data/services/location_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationViewModel extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  bool isBlocked = false;
  bool isCheckingLocation = false;

  StreamSubscription? _subscription;

  Future<void> initialize() async {
    isCheckingLocation = true;
    notifyListeners();

    await _checkLocationStatus();

    isCheckingLocation = false;
    notifyListeners();
  }

  Future<void> _checkLocationStatus() async {
    final serviceEnabled = await _locationService.isLocationServiceEnabled();

    final permission = await _locationService.checkPermission();

    if (!serviceEnabled ||
        permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Browsers often remember a prior deny; hard-blocking the whole app
      // traps users with no OS settings screen. Soft-continue on web.
      if (kIsWeb) {
        log('⚠️ Web location unavailable ($permission) — continuing without hard block');
        _allowApp();
        return;
      }
      _blockApp();
      return;
    }

    _allowApp();
    // geolocator_web position stream can throw LegacyJavaScriptObject casts
    // on some browsers; tracking is only needed to re-block on mobile.
    if (!kIsWeb) {
      _startListening();
    }
  }

  void _blockApp() {
    isBlocked = true;
    _subscription?.cancel();
  }

  void _allowApp() {
    isBlocked = false;
  }

  void _startListening() {
    _subscription = _locationService.startTracking().listen(
      (_) {},
      onError: (_) {
        if (kIsWeb) {
          log('⚠️ Web location stream error — not hard-blocking');
          return;
        }
        _blockApp();
      },
    );
  }

  Future<void> recheckLocation() async {
    await _checkLocationStatus();
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void reset() {
    isBlocked = false;
    isCheckingLocation = false;
    _subscription?.cancel();
    notifyListeners();
  }
}
