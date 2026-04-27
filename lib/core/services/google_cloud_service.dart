import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

class GoogleCloudService {
  static const String _apiKey = 'AIzaSyDxBbtJh5KO4cLgMTy652YU8cL-rRPbXB8';
  
  // ==========================================
  // PLACES API - Autocomplete
  // ==========================================
  static Future<List<Map<String, dynamic>>> getPlacePredictions(String query) async {
    if (query.isEmpty) return [];
    
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&components=country:in'
        '&key=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return List<Map<String, dynamic>>.from(data['predictions']);
        } else {
          LoggerService.w('Places API returned status: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      } else {
        LoggerService.e('Places API HTTP Error: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      LoggerService.e('Places API Exception: $e');
      return [];
    }
  }

  // ==========================================
  // PLACES API - Place Details
  // ==========================================
  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=geometry,formatted_address,address_components,name'
        '&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final location = result['geometry']['location'];
          
          String city = '';
          String locality = '';
          String fullAddress = result['formatted_address'] ?? '';
          
          if (result['address_components'] != null) {
            for (final comp in result['address_components']) {
              final types = List<String>.from(comp['types']);
              if (types.contains('locality')) {
                city = comp['long_name'];
              }
              if (types.contains('sublocality_level_1') || types.contains('sublocality')) {
                locality = comp['long_name'];
              }
            }
          }

          return {
            'latitude': location['lat'] as double,
            'longitude': location['lng'] as double,
            'city': city,
            'locality': locality,
            'address': fullAddress,
            'name': result['name'] ?? '',
          };
        } else {
          LoggerService.w('Place Details API returned status: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      }
      return null;
    } catch (e) {
      LoggerService.e('Place Details API Exception: $e');
      return null;
    }
  }

  // ==========================================
  // GOOGLE GEOCODING API - Reverse
  // ==========================================
  static Future<Map<String, String>?> reverseGeocode(double lat, double lng) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?latlng=$lat,$lng'
        '&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final result = data['results'][0];
          String city = '';
          String locality = '';
          String address = result['formatted_address'] ?? '';

          for (final comp in result['address_components']) {
            final types = List<String>.from(comp['types']);
            if (types.contains('locality')) {
              city = comp['long_name'];
            }
            if (types.contains('sublocality_level_1') || types.contains('sublocality')) {
              locality = comp['long_name'];
            }
          }

          return {
            'city': city,
            'locality': locality,
            'address': address,
          };
        } else {
          LoggerService.w('Reverse Geocoding API returned status: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      }
      return null;
    } catch (e) {
      LoggerService.e('Reverse Geocoding API Exception: $e');
      return null;
    }
  }

  // ==========================================
  // GOOGLE GEOCODING API - Forward
  // ==========================================
  static Future<LatLng?> geocodeAddress(String address) async {
    if (address.isEmpty) return null;

    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json'
        '?address=${Uri.encodeComponent(address)}'
        '&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && (data['results'] as List).isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'] as double, location['lng'] as double);
        } else {
          LoggerService.w('Geocoding API returned status: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      }
      return null;
    } catch (e) {
      LoggerService.e('Geocoding API Exception: $e');
      return null;
    }
  }

  // ==========================================
  // ROUTES / DIRECTIONS API
  // ==========================================
  static Future<List<LatLng>> getDirections(LatLng origin, LatLng destination) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${origin.latitude},${origin.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&key=$_apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final String points = data['routes'][0]['overview_polyline']['points'];
          List<PointLatLng> result = PolylinePoints.decodePolyline(points);
          return result.map((e) => LatLng(e.latitude, e.longitude)).toList();
        } else {
          LoggerService.w('Directions API returned status: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      }
      return [];
    } catch (e) {
      LoggerService.e('Directions API Exception: $e');
      return [];
    }
  }

  // ==========================================
  // CLOUD TRANSLATION API
  // ==========================================
  static Future<String> translateText(String text, String targetLanguageCode) async {
    if (text.isEmpty) return '';
    
    final String url = 'https://translation.googleapis.com/language/translate/v2?key=$_apiKey';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'q': text,
          'target': targetLanguageCode,
          'format': 'text'
        }),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['translations'][0]['translatedText'];
      } else {
        LoggerService.w('Translation API Error: ${response.body}');
      }
      return text;
    } catch (e) {
      LoggerService.e('Translation API Exception: $e');
      return text;
    }
  }
}
