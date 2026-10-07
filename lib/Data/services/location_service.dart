import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionStream;

  /// Check if location service is ON
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Read permission state without triggering an OS/browser prompt.
  Future<LocationPermission> checkPermission() =>
      Geolocator.checkPermission();

  /// Start real-time location tracking.
  /// Disabled on web — geolocator_web's position stream throws
  /// `LegacyJavaScriptObject is not a subtype of Position` in current Flutter.
  Stream<Position> startTracking() {
    if (kIsWeb) {
      return const Stream<Position>.empty();
    }
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // meters
      ),
    );
  }

  void stopTracking() {
    _positionStream?.cancel();
  }
}
