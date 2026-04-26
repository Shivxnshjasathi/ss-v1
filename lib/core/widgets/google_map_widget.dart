import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class GoogleMapWidget extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String address;

  const GoogleMapWidget({
    Key? key,
    this.latitude,
    this.longitude,
    required this.address,
  }) : super(key: key);

  @override
  State<GoogleMapWidget> createState() => _GoogleMapWidgetState();
}

class _GoogleMapWidgetState extends State<GoogleMapWidget> {
  LatLng? _targetLocation;
  bool _isLoading = true;

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
          _isLoading = false;
        });
      }
      return;
    }

    try {
      List<Location> locations = await locationFromAddress(widget.address);
      if (locations.isNotEmpty) {
        if (mounted) {
          setState(() {
            _targetLocation = LatLng(locations.first.latitude, locations.first.longitude);
            _isLoading = false;
          });
        }
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 250,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _targetLocation!,
            zoom: 15.0,
          ),
          markers: {
            Marker(
              markerId: const MarkerId('propertyLocation'),
              position: _targetLocation!,
            ),
          },
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}
