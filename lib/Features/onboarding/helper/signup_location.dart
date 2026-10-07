import 'package:dio/dio.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Location payload required by `/auth/user-auth` signup (`lat` + `locationString`).
class SignupLocation {
  const SignupLocation({
    required this.locationString,
    required this.lat,
    required this.lng,
  });

  final String locationString;
  final double lat;
  final double lng;

  static Future<SignupLocation> fromCoords(double lat, double lng) async {
    var locationString = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    // geocoding has no web implementation — skip reverse lookup on web.
    if (!kIsWeb) {
      try {
        final placemarks = await placemarkFromCoordinates(lat, lng);
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final parts = [
            place.locality,
            place.administrativeArea,
            place.country,
          ].whereType<String>().where((s) => s.trim().isNotEmpty);
          if (parts.isNotEmpty) locationString = parts.join(', ');
        }
      } catch (e) {
        AppLogger.d('SignupLocation geocode failed: $e');
      }
    }

    return SignupLocation(locationString: locationString, lat: lat, lng: lng);
  }

  static Future<SignupLocation> fromPosition(Position position) =>
      fromCoords(position.latitude, position.longitude);

  /// Forward-geocode a typed city (works on web via Nominatim; GPS often fails
  /// on desktop Chrome with "Position update is unavailable").
  // ponytail: Nominatim free tier; swap for Maps Geocoding API if quota/rate matters
  static Future<SignupLocation?> fromAddressQuery(String query) async {
    final q = query.trim();
    if (q.isEmpty) return null;
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          headers: const {
            'User-Agent': 'EverQpidCustomer/1.0 (signup-location)',
            'Accept': 'application/json',
          },
        ),
      );
      final res = await dio.get<List<dynamic>>(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': q,
          'format': 'json',
          'limit': 1,
        },
      );
      final list = res.data;
      if (list == null || list.isEmpty) return null;
      final row = list.first as Map;
      final lat = double.tryParse('${row['lat']}');
      final lng = double.tryParse('${row['lon']}');
      if (lat == null || lng == null) return null;
      final display = (row['display_name'] as String?)?.trim();
      final short = (display != null && display.isNotEmpty)
          ? display.split(',').take(3).map((s) => s.trim()).join(', ')
          : q;
      return SignupLocation(locationString: short, lat: lat, lng: lng);
    } catch (e) {
      AppLogger.d('SignupLocation fromAddressQuery failed: $e');
      return null;
    }
  }
}
