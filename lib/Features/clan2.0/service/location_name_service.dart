// features/clan/service/location_name_service.dart

import 'package:geocoding/geocoding.dart';

class LocationNameService {
  /// Converts lat/lng → City, State, Country
  Future<String> getLocationName({
    required double lat,
    required double lng,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) return '';

      final place = placemarks.first;

      /// Priority: City → SubLocality → State
      return [
            place.locality,
            place.subLocality,
            place.administrativeArea,
          ].where((e) => e != null && e.isNotEmpty).first ??
          '';
    } catch (_) {
      return '';
    }
  }

  /// Get detailed placemark information for city and state
  Future<Map<String, String?>> getPlacemarkDetails({
    required double lat,
    required double lng,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return {'city': null, 'state': null};
      }

      final place = placemarks.first;

      return {
        'city': place.locality ?? place.subLocality,
        'state': place.administrativeArea,
      };
    } catch (_) {
      return {'city': null, 'state': null};
    }
  }
}
