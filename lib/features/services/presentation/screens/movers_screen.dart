import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MoversScreen extends ConsumerStatefulWidget {
  const MoversScreen({super.key});

  @override
  ConsumerState<MoversScreen> createState() => _MoversScreenState();
}

// Google Maps API key (same as in AndroidManifest)
const _kMapsApiKey = 'AIzaSyBXkFyaP5w0g89EfUleyCFmhhMTQ_IVsnY';

class _MoversScreenState extends ConsumerState<MoversScreen> {
  final TextEditingController _pickupController = TextEditingController(text: 'Prestige Falcon City, Bangalore');
  final TextEditingController _dropController = TextEditingController();
  final FocusNode _dropFocusNode = FocusNode();

  String _selectedSize = '2 BHK';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  bool _includePacking = false;
  double _distanceKm = 0.0;
  bool _isCalculatingDistance = false;

  // Places autocomplete
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  bool _isFetchingSuggestions = false;

  GoogleMapController? _mapController;
  LatLng? _pickupLatLng;
  LatLng? _dropLatLng;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _dropController.addListener(_onDropTextChanged);
  }

  @override
  void dispose() {
    _dropController.removeListener(_onDropTextChanged);
    _dropController.dispose();
    _dropFocusNode.dispose();
    super.dispose();
  }

  // ── Places Autocomplete ─────────────────────────────────────────────────────

  void _onDropTextChanged() {
    final query = _dropController.text.trim();
    if (query.length < 3) {
      setState(() { _suggestions = []; _showSuggestions = false; });
      return;
    }
    _fetchPlacesSuggestions(query);
  }

  Future<void> _fetchPlacesSuggestions(String input) async {
    setState(() => _isFetchingSuggestions = true);
    try {
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(input)}'
        '&key=$_kMapsApiKey'
        '&language=en'
        '&components=country:in',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          setState(() {
            _suggestions = predictions.map<Map<String, dynamic>>((p) => {
              'description': p['description'],
              'place_id': p['place_id'],
            }).toList();
            _showSuggestions = _suggestions.isNotEmpty;
          });
        } else {
          setState(() { _suggestions = []; _showSuggestions = false; });
        }
      }
    } catch (_) {
      setState(() { _suggestions = []; _showSuggestions = false; });
    } finally {
      setState(() => _isFetchingSuggestions = false);
    }
  }

  Future<void> _selectSuggestion(Map<String, dynamic> suggestion) async {
    final description = suggestion['description'] as String;
    _dropController.removeListener(_onDropTextChanged);
    _dropController.text = description;
    _dropController.addListener(_onDropTextChanged);
    setState(() { _suggestions = []; _showSuggestions = false; });
    _dropFocusNode.unfocus();
    await _geocodeAndCalculate(description);
  }

  /// Called on keyboard Done / search icon tap
  Future<void> _onDropSubmitted() async {
    final text = _dropController.text.trim();
    if (text.isEmpty) return;
    setState(() { _suggestions = []; _showSuggestions = false; });
    _dropFocusNode.unfocus();
    await _geocodeAndCalculate(text);
  }

  Future<void> _geocodeAndCalculate(String address) async {
    setState(() => _isCalculatingDistance = true);
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isEmpty) return;
      final loc = locations.first;
      final dropLatLng = LatLng(loc.latitude, loc.longitude);

      setState(() {
        _dropLatLng = dropLatLng;
        _markers.removeWhere((m) => m.markerId.value == 'drop');
        _markers.add(Marker(
          markerId: const MarkerId('drop'),
          position: dropLatLng,
          infoWindow: InfoWindow(title: address),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ));
      });

      _calculateDistanceAndRoute();

      // Zoom to fit both markers
      if (_pickupLatLng != null) {
        final bounds = LatLngBounds(
          southwest: LatLng(
            _pickupLatLng!.latitude < dropLatLng.latitude ? _pickupLatLng!.latitude : dropLatLng.latitude,
            _pickupLatLng!.longitude < dropLatLng.longitude ? _pickupLatLng!.longitude : dropLatLng.longitude,
          ),
          northeast: LatLng(
            _pickupLatLng!.latitude > dropLatLng.latitude ? _pickupLatLng!.latitude : dropLatLng.latitude,
            _pickupLatLng!.longitude > dropLatLng.longitude ? _pickupLatLng!.longitude : dropLatLng.longitude,
          ),
        );
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not find location: $address'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isCalculatingDistance = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _pickupLatLng = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: const MarkerId('pickup'),
          position: _pickupLatLng!,
          infoWindow: const InfoWindow(title: 'Pickup Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      });
      _updateAddressFromLatLng(_pickupLatLng!, isPickup: true);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_pickupLatLng!, 14));
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  Future<void> _updateAddressFromLatLng(LatLng latLng, {required bool isPickup}) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = '${place.name}, ${place.locality}, ${place.administrativeArea}';
        setState(() {
          if (isPickup) {
            _pickupController.text = address;
          } else {
            _dropController.text = address;
          }
        });
      }
    } catch (e) {
      debugPrint('Error updating address: $e');
    }
  }

  Future<void> _onMapTap(LatLng latLng) async {
    setState(() {
      _dropLatLng = latLng;
      _markers.removeWhere((m) => m.markerId.value == 'drop');
      _markers.add(Marker(
        markerId: const MarkerId('drop'),
        position: _dropLatLng!,
        infoWindow: const InfoWindow(title: 'Drop Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
    });
    _updateAddressFromLatLng(latLng, isPickup: false);
    _calculateDistanceAndRoute();
  }

  void _calculateDistanceAndRoute() {
    if (_pickupLatLng == null || _dropLatLng == null) return;

    final distanceInMeters = Geolocator.distanceBetween(
      _pickupLatLng!.latitude, _pickupLatLng!.longitude,
      _dropLatLng!.latitude, _dropLatLng!.longitude,
    );

    setState(() {
      _distanceKm = distanceInMeters / 1000;
      _polylines
        ..removeWhere((p) => p.polylineId.value == 'route')
        ..add(Polyline(
          polylineId: const PolylineId('route'),
          points: [_pickupLatLng!, _dropLatLng!],
          color: AppTheme.primaryBlue,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ));
    });
  }
  
  int _calculateBasePrice() {
    switch (_selectedSize) {
      case '1 BHK': return 2500;
      case '2 BHK': return 4250;
      case '3 BHK': return 6500;
      case '4+ BHK': return 9000;
      default: return 4250;
    }
  }

  int _calculateTotalQuote() {
    int base = _calculateBasePrice();
    // 50 INR per km
    int distanceCost = (_distanceKm * 50).round();
    int total = base + distanceCost;
    if (_includePacking) total += 999;
    return total;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: AppTheme.primaryBlue),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _confirmBooking() async {
    if (_dropController.text.trim().isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterDropLocation), backgroundColor: Colors.red),
      );
      return;
    }

    final user = ref.read(currentUserDataProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to continue'), backgroundColor: Colors.red),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );

    try {
      final String requestId = 'MOV-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      final request = ServiceRequestModel(
        id: requestId,
        userId: user.uid,
        userName: user.name ?? 'User',
        userContact: user.phoneNumber,
        category: 'Movers',
        status: 'Pending',
        createdAt: DateTime.now(),
        location: _pickupController.text.split(',').last.trim(), // simple city extraction
        details: {
          'pickupLocation': _pickupController.text,
          'dropLocation': _dropController.text,
          'propertySize': _selectedSize,
          'includePacking': _includePacking,
          'pickupDate': _selectedDate.toIso8601String(),
          'pickupTime': '${_selectedTime.hour}:${_selectedTime.minute}',
          'distance': _distanceKm.round(),
          'estimatedQuote': _calculateTotalQuote(),
        },
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);

      if (!mounted) return;
      context.pop(); // dismiss loading

      final l10n = AppLocalizations.of(context)!;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.w)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 60.w),
                SizedBox(height: 16.h),
                Text(l10n.moversBookedSuccess, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp), textAlign: TextAlign.center),
                SizedBox(height: 8.h),
                Text(
                  l10n.moversArrivalMsg(
                    _pickupController.text,
                    DateFormat('MMM d, yyyy').format(_selectedDate),
                    _selectedTime.format(context),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.go('/services/tracking'); // Redirect to tracking map
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                    ),
                    child: const Text('Track Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  border: Border.all(color: context.borderColor),
                  borderRadius: BorderRadius.circular(14.sp),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: context.iconColor,
                  size: 14.sp,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Text(
              l10n.packersAndMovers,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.primaryTextColor,
                fontSize: 24.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Map
          Positioned.fill(
            bottom: 0.35.h * MediaQuery.of(context).size.height,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _pickupLatLng ?? const LatLng(22.7196, 75.8577),
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              onMapCreated: (controller) => _mapController = controller,
              onTap: _onMapTap,
              padding: EdgeInsets.only(top: 60.h),
              zoomControlsEnabled: false,
            ),
          ),
          
          // Selection Panel
          DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.45,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: context.scaffoldColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32.sp)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          margin: EdgeInsets.only(bottom: 24.h),
                          decoration: BoxDecoration(
                            color: context.borderColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  _buildSectionLabel(l10n.transitRoute),
                  SizedBox(height: 16.h),
                  _buildTransitRouteCard(l10n),
                  
                  SizedBox(height: 32.h),
                  
                  _buildSectionLabel(l10n.propertySize),
                  SizedBox(height: 16.h),
                  _buildPropertySizeRow(),
                  
                  SizedBox(height: 32.h),

                  // Distance chip — auto-calculated, no manual slider
                  if (_distanceKm > 0)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12.w),
                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.25)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.route_outlined, color: AppTheme.primaryBlue, size: 20.sp),
                              SizedBox(width: 10.w),
                              Text('Calculated Distance', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w700, fontSize: 13.sp)),
                            ],
                          ),
                          Text('${_distanceKm.toStringAsFixed(1)} km', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.w900, fontSize: 16.sp)),
                        ],
                      ),
                    )
                  else if (_isCalculatingDistance)
                    Center(child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue)),
                          SizedBox(width: 10.w),
                          Text('Calculating distance...', style: TextStyle(color: AppTheme.primaryBlue, fontSize: 12.sp)),
                        ],
                      ),
                    ))
                  else
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12.w),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.grey, size: 18.sp),
                          SizedBox(width: 10.w),
                          Text('Enter drop location to calculate distance', style: TextStyle(color: Colors.grey, fontSize: 12.sp)),
                        ],
                      ),
                    ),

                  SizedBox(height: 32.h),
                  
                  _buildSectionLabel(l10n.schedulePickup),
                  SizedBox(height: 16.h),
                  _buildScheduleRow(context),
                  
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 12.w, color: Colors.grey[600]),
                      SizedBox(width: 6.w),
                      Text(l10n.shiftingTimeDisclaimer, style: TextStyle(color: Colors.grey[600], fontSize: 10.sp, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  _buildBookingSummaryCard(l10n),
                  
                  SizedBox(height: 32.h),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: OutlinedButton.icon(
                      icon: Icon(_includePacking ? Icons.check_box : Icons.check_box_outline_blank, color: _includePacking ? AppTheme.primaryBlue : context.secondaryTextColor),
                      onPressed: () {
                        setState(() {
                          _includePacking = !_includePacking;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: _includePacking ? AppTheme.primaryBlue : context.borderColor, width: 2.w),
                        backgroundColor: _includePacking ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                      ),
                      label: Row(
                        children: [
                          Text(' ${l10n.professionalPacking}', style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 13.sp)),
                          const Spacer(),
                          Text('+₹999', style: TextStyle(fontWeight: FontWeight.w900, color: context.secondaryTextColor, fontSize: 13.sp)),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: _distanceKm > 0 ? _confirmBooking : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: Text(
                        _distanceKm > 0 
                            ? l10n.confirmBooking.toUpperCase() 
                            : 'SEARCH DROP LOCATION FIRST',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.sp,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          );
        },
      ),
      
      // Floating Help Button
      Positioned(
        top: 16.h,
        right: 16.w,
        child: FloatingActionButton.small(
          onPressed: () => ContactBottomSheet.show(context),
          backgroundColor: context.cardColor,
          elevation: 4,
          child: Icon(Icons.help_outline, color: context.primaryTextColor),
        ),
      ),
    ],
  ),
);
}

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 10.sp,
        letterSpacing: 1.5,
        fontFamily: 'Poppins',
        color: AppTheme.primaryBlue,
      ),
    );
  }

  Widget _buildTransitRouteCard(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(20.sp),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 11.w,
            top: 24.h,
            bottom: 24.h,
            child: Container(
              width: 1.5.w,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryBlue, AppTheme.primaryBlue.withValues(alpha: 0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Container(
                        width: 10.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.pickupLocation,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 1,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TextField(
                          controller: _pickupController,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            fontFamily: 'Poppins',
                            color: context.primaryTextColor,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                            border: InputBorder.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 28.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    ),
                    child: Icon(Icons.location_on_rounded, color: context.primaryTextColor, size: 16.w),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dropLocation,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 1,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              controller: _dropController,
                              focusNode: _dropFocusNode,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => _onDropSubmitted(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15.sp,
                                fontFamily: 'Poppins',
                                color: context.primaryTextColor,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.searchDestination,
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
                                  fontFamily: 'Poppins',
                                  color: context.secondaryTextColor.withValues(alpha: 0.4),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                                border: InputBorder.none,
                                suffixIcon: _isFetchingSuggestions
                                    ? Padding(
                                        padding: EdgeInsets.all(10.w),
                                        child: SizedBox(
                                          width: 16.w, height: 16.w,
                                          child: const CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryBlue),
                                        ),
                                      )
                                    : GestureDetector(
                                        onTap: _onDropSubmitted,
                                        child: Icon(Icons.search_rounded, color: AppTheme.primaryBlue, size: 22.sp),
                                      ),
                              ),
                            ),
                            // ── Autocomplete Suggestions Dropdown ──
                            if (_showSuggestions && _suggestions.isNotEmpty)
                              Container(
                                margin: EdgeInsets.only(top: 4.h),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: BorderRadius.circular(12.sp),
                                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _suggestions.length > 5 ? 5 : _suggestions.length,
                                  separatorBuilder: (_, __) => Divider(height: 1, color: context.borderColor),
                                  itemBuilder: (context, i) {
                                    final s = _suggestions[i];
                                    return InkWell(
                                      onTap: () => _selectSuggestion(s),
                                      borderRadius: i == 0
                                          ? BorderRadius.vertical(top: Radius.circular(12.sp))
                                          : (i == (_suggestions.length > 5 ? 4 : _suggestions.length - 1)
                                              ? BorderRadius.vertical(bottom: Radius.circular(12.sp))
                                              : BorderRadius.zero),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                        child: Row(
                                          children: [
                                            Icon(Icons.location_on_outlined, color: AppTheme.primaryBlue, size: 16.sp),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: Text(
                                                s['description'] as String,
                                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: context.primaryTextColor),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertySizeRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildSizeChip('1 BHK'),
          SizedBox(width: 12.w),
          _buildSizeChip('2 BHK'),
          SizedBox(width: 12.w),
          _buildSizeChip('3 BHK'),
          SizedBox(width: 12.w),
          _buildSizeChip('4+ BHK'),
        ],
      ),
    );
  }

  Widget _buildSizeChip(String label) {
    bool isSelected = _selectedSize == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSize = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : context.cardColor,
          border: isSelected ? null : Border.all(color: context.borderColor, width: 1.5.w),
          borderRadius: BorderRadius.circular(30.w),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12.sp,
            color: isSelected ? Colors.white : context.primaryTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: context.cardColor,
                border: Border.all(color: context.borderColor),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 18.w, color: context.primaryTextColor),
                  SizedBox(width: 12.w),
                  Text(DateFormat('MMM d, yyyy').format(_selectedDate), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, color: context.primaryTextColor)),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: context.cardColor,
                border: Border.all(color: context.borderColor),
                borderRadius: BorderRadius.circular(12.w),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 18.w, color: context.primaryTextColor),
                  SizedBox(width: 8.w),
                  Text(_selectedTime.format(context), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, color: context.primaryTextColor)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSummaryCard(AppLocalizations l10n) {
    String formatCurrency(int amount) {
      String text = amount.toString();
      text = text.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+\d$)'), (Match m) => '${m[1]},');
      return '₹$text';
    }

    int totalQuote = _calculateTotalQuote();

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(16.w),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.bookingSummary, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                    border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(4.w),
                  ),
                  child: Text(l10n.premiumCare, style: TextStyle(color: AppTheme.primaryBlue, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ],
            ),
          ),
          Divider(height: 1.h, color: context.borderColor),
          Padding(
            padding: EdgeInsets.all(20.0.w),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildSummaryItem(context, l10n.inventory.toUpperCase(), _selectedSize)),
                    Expanded(child: _buildSummaryItem(context, l10n.packing.toUpperCase(), _includePacking ? l10n.included : l10n.none)),
                  ],
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(child: _buildSummaryItem(context, l10n.distance.toUpperCase(), '${_distanceKm.round()} km')),
                    Expanded(child: _buildSummaryItem(context, l10n.insurance.toUpperCase(), l10n.standardInsurance)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 20.0.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16.w), bottomRight: Radius.circular(16.w)),
              border: Border(top: BorderSide(color: context.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_outlined, color: context.primaryTextColor, size: 18.w),
                    SizedBox(width: 8.w),
                    Text(l10n.estQuote, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, color: context.secondaryTextColor)),
                  ],
                ),
                Text(formatCurrency(totalQuote), style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, color: AppTheme.primaryBlue)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: context.secondaryTextColor, letterSpacing: 0.5)),
        SizedBox(height: 6.h),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: context.primaryTextColor)),
      ],
    );
  }
}
