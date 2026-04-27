import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class PropertyMapView extends ConsumerStatefulWidget {
  final List<PropertyModel> properties;

  const PropertyMapView({super.key, required this.properties});

  @override
  ConsumerState<PropertyMapView> createState() => _PropertyMapViewState();
}

class _PropertyMapViewState extends ConsumerState<PropertyMapView> {
  GoogleMapController? _mapController;
  LatLng _currentCenter = const LatLng(22.7196, 75.8577); // Default: Indore
  double _searchRadius = 5000; // 5 km radius
  bool _isMapIdle = true;
  PropertyModel? _selectedProperty;

  // Custom Silver Map Style
  final String _mapStyle = '''
  [
    {
      "elementType": "geometry",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "elementType": "labels.icon",
      "stylers": [{"visibility": "off"}]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [{"color": "#f5f5f5"}]
    },
    {
      "featureType": "administrative.land_parcel",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#bdbdbd"}]
    },
    {
      "featureType": "poi",
      "elementType": "geometry",
      "stylers": [{"color": "#eeeeee"}]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "road",
      "elementType": "geometry",
      "stylers": [{"color": "#ffffff"}]
    },
    {
      "featureType": "road.arterial",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#757575"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [{"color": "#dadada"}]
    },
    {
      "featureType": "road.highway",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#616161"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#c9c9c9"}]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [{"color": "#9e9e9e"}]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    _determineInitialLocation();
  }

  Future<void> _determineInitialLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
    if (mounted) {
      setState(() {
        _currentCenter = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentCenter, 13));
    }
  }

  // Filter properties based on radius
  List<PropertyModel> get _visibleProperties {
    return widget.properties.where((p) {
      if (p.latitude == null || p.longitude == null) return false;
      double distanceInMeters = Geolocator.distanceBetween(
        _currentCenter.latitude, _currentCenter.longitude,
        p.latitude!, p.longitude!
      );
      return distanceInMeters <= _searchRadius;
    }).toList();
  }

  Set<Marker> _buildMarkers() {
    return _visibleProperties.map((p) {
      final isSelected = _selectedProperty?.id == p.id;
      return Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.latitude!, p.longitude!),
        icon: BitmapDescriptor.defaultMarkerWithHue(isSelected ? BitmapDescriptor.hueBlue : BitmapDescriptor.hueRed),
        zIndexInt: isSelected ? 2 : 1,
        onTap: () {
          setState(() {
            _selectedProperty = p;
          });
        },
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final visibleProps = _visibleProperties;
    
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(target: _currentCenter, zoom: 13),
          style: _mapStyle,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onCameraMove: (position) {
            if (_isMapIdle) setState(() => _isMapIdle = false);
            _currentCenter = position.target;
          },
          onCameraIdle: () {
            setState(() {
              _isMapIdle = true;
            });
          },
          markers: _buildMarkers(),
          circles: {
            Circle(
              circleId: const CircleId('searchRadius'),
              center: _currentCenter,
              radius: _searchRadius,
              fillColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              strokeColor: AppTheme.primaryBlue,
              strokeWidth: 2,
            )
          },
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        
        // Radius Slider Overlay
        // Minimal Radius Control Pill
        Positioned(
          top: 16.h,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.w),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 15, offset: const Offset(0, 5))
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchRadius = (_searchRadius - 1000).clamp(1000, 20000);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.minus, size: 16.sp, color: Colors.black87),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Radius: ${(_searchRadius/1000).toStringAsFixed(0)} km', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.black87)
                        ),
                        Text(
                          '${visibleProps.length} found', 
                          style: TextStyle(color: AppTheme.primaryBlue, fontSize: 10.sp, fontWeight: FontWeight.w600)
                        ),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchRadius = (_searchRadius + 1000).clamp(1000, 20000);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(LucideIcons.plus, size: 16.sp, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Property Card Carousel
        if (_selectedProperty != null)
          Positioned(
            bottom: 100.h, // Leave room for map toggle
            left: 0,
            right: 0,
            child: _buildFloatingPropertyCard(_selectedProperty!),
          )
        else if (visibleProps.isNotEmpty)
          Positioned(
            bottom: 100.h,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 140.h,
              child: PageView.builder(
                controller: PageController(viewportFraction: 0.85),
                itemCount: visibleProps.length,
                onPageChanged: (index) {
                  final p = visibleProps[index];
                  _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(p.latitude!, p.longitude!)));
                },
                itemBuilder: (context, index) {
                  return _buildFloatingPropertyCard(visibleProps[index]);
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingPropertyCard(PropertyModel p) {
    return GestureDetector(
      onTap: () => context.push('/properties/detail/${p.id}'),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.w),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16.w)),
              child: CachedNetworkImage(
                imageUrl: p.imageUrls.isNotEmpty ? p.imageUrls.first : '',
                width: 120.w,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[300]),
                errorWidget: (context, url, err) => Container(color: Colors.grey[300], child: Icon(Icons.home, color: Colors.grey)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('₹${(p.price / 100000).toStringAsFixed(1)} L', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppTheme.primaryBlue)),
                    SizedBox(height: 4.h),
                    Text(p.title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp), maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 12.sp, color: Colors.grey),
                        SizedBox(width: 4.w),
                        Expanded(child: Text(p.location, style: TextStyle(color: Colors.grey, fontSize: 12.sp), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(LucideIcons.bed, size: 12.sp, color: Colors.black54),
                        SizedBox(width: 4.w),
                        Text('${p.bedrooms} Beds', style: TextStyle(fontSize: 12.sp)),
                        SizedBox(width: 12.w),
                        Icon(LucideIcons.bath, size: 12.sp, color: Colors.black54),
                        SizedBox(width: 4.w),
                        Text('${p.bathrooms} Baths', style: TextStyle(fontSize: 12.sp)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
