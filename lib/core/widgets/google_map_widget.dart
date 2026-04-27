import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sampatti_bazar/core/services/google_cloud_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

class GoogleMapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String address;
  final bool showDirectionsButton;

  const GoogleMapWidget({
    super.key,
    this.latitude,
    this.longitude,
    required this.address,
    this.showDirectionsButton = false,
  });

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  LatLng? _targetLocation;
  bool _isLoading = true;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  bool _isLoadingRoute = false;
  GoogleMapController? _mapController;
  String? _routeInfo;

  @override
  void initState() {
    super.initState();
    _determineLocation();
  }

  Future<void> _determineLocation() async {
    if (widget.latitude != null && widget.longitude != null) {
      if (mounted) {
        setState(() {
          _targetLocation = LatLng(widget.latitude!, widget.longitude!);
          _markers = {
            Marker(
              markerId: const MarkerId('propertyLocation'),
              position: _targetLocation!,
              infoWindow: InfoWindow(title: widget.address),
            ),
          };
          _isLoading = false;
        });
      }
      return;
    }

    // Use Google Geocoding API for accurate address → coordinates
    try {
      LatLng? latLng = await GoogleCloudService.geocodeAddress(widget.address);
      
      // Fallback to native geocoding package if API fails
      if (latLng == null) {
        LoggerService.w('Google Geocoding failed. Falling back to native geocoder for Map...');
        List<Location> locations = await locationFromAddress(widget.address);
        if (locations.isNotEmpty) {
          latLng = LatLng(locations.first.latitude, locations.first.longitude);
        }
      }

      if (latLng != null && mounted) {
        setState(() {
          _targetLocation = latLng;
          _markers = {
            Marker(
              markerId: const MarkerId('propertyLocation'),
              position: _targetLocation!,
              infoWindow: InfoWindow(title: widget.address),
            ),
          };
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _drawRoute() async {
    if (_targetLocation == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      // Get current user position
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final userLocation = LatLng(position.latitude, position.longitude);

      // Get route from Directions API
      final routePoints = await GoogleCloudService.getDirections(
        userLocation,
        _targetLocation!,
      );

      if (routePoints.isNotEmpty && mounted) {
        // Calculate distance
        final distanceInMeters = Geolocator.distanceBetween(
          userLocation.latitude, userLocation.longitude,
          _targetLocation!.latitude, _targetLocation!.longitude,
        );
        final distanceKm = (distanceInMeters / 1000).toStringAsFixed(1);

        setState(() {
          _routeInfo = '$distanceKm km away';
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: const Color(0xFF1E60FF),
              width: 4,
              patterns: [],
            ),
          };
          _markers = {
            Marker(
              markerId: const MarkerId('userLocation'),
              position: userLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              infoWindow: const InfoWindow(title: 'Your Location'),
            ),
            Marker(
              markerId: const MarkerId('propertyLocation'),
              position: _targetLocation!,
              infoWindow: InfoWindow(title: widget.address),
            ),
          };
          _isLoadingRoute = false;
        });

        // Fit the map to show both points
        if (_mapController != null) {
          final bounds = LatLngBounds(
            southwest: LatLng(
              userLocation.latitude < _targetLocation!.latitude ? userLocation.latitude : _targetLocation!.latitude,
              userLocation.longitude < _targetLocation!.longitude ? userLocation.longitude : _targetLocation!.longitude,
            ),
            northeast: LatLng(
              userLocation.latitude > _targetLocation!.latitude ? userLocation.latitude : _targetLocation!.latitude,
              userLocation.longitude > _targetLocation!.longitude ? userLocation.longitude : _targetLocation!.longitude,
            ),
          );
          _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
        }
      } else {
        if (mounted) {
          setState(() => _isLoadingRoute = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch route. Try again.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRoute = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Route error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_targetLocation == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('Map location not available'),
        ),
      );
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: _polylines.isNotEmpty ? 300 : 250,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _targetLocation!,
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
                if (_isLoadingRoute)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 8),
                          Text(
                            'Drawing route...',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Route info badge
                if (_routeInfo != null)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E60FF),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.directions_car, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            _routeInfo!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Draw route button
                if (_polylines.isEmpty)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      elevation: 4,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _drawRoute,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions, color: Color(0xFF1E60FF), size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Show Route',
                                style: TextStyle(
                                  color: Color(0xFF1E60FF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
