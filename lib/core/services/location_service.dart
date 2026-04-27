import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sampatti_bazar/core/services/google_cloud_service.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

class LocationService {
  static Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      LoggerService.w('Location: Service is disabled');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      LoggerService.i('Location: Permission denied, requesting...');
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        LoggerService.w('Location: Permission denied again');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      LoggerService.e('Location: Permission denied forever');
      return null;
    }

    LoggerService.i('Location: Fetching current position (High Accuracy)...');
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Reverse geocode using Google Geocoding API, with a fallback to the free geocoding package
  static Future<Map<String, String>?> getAddressFromLatLng(Position position) async {
    try {
      // 1. Try Google Cloud Geocoding API
      final googleResult = await GoogleCloudService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      
      if (googleResult != null && googleResult['city']?.isNotEmpty == true) {
        return googleResult;
      }
      
      LoggerService.w('Google Geocoding failed or returned empty city. Falling back to native geocoder...');
      
      // 2. Fallback to native geocoding package (free, no API key needed)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        LoggerService.i('Location: Native Geocoder success - City: ${place.locality}');
        return {
          'city': place.locality ?? place.subAdministrativeArea ?? '',
          'locality': place.subLocality ?? place.name ?? '',
          'address': '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}',
        };
      } else {
        LoggerService.w('Location: Native Geocoder returned no results');
      }
    } catch (e) {
      LoggerService.e('Location fallback error: $e');
    }
    return null;
  }
}
