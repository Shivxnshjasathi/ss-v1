import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:uuid/uuid.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/core/services/location_service.dart';
import 'package:feature_discovery/feature_discovery.dart';

class OtherServicesScreen extends ConsumerStatefulWidget {
  const OtherServicesScreen({super.key});

  @override
  ConsumerState<OtherServicesScreen> createState() =>
      _OtherServicesScreenState();
}

class _OtherServicesScreenState extends ConsumerState<OtherServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Electrical fitting & services';
  String? _selectedLaborType;
  final List<String> _categories = [
    'Electrical fitting & services',
    'Plumbing services',
    'House painting',
    'House cleaning',
    'Labor',
    'All',
  ];

  final List<String> _laborTypes = [
    'General Help',
    'Construction Labor',
    'Loading & Unloading',
    'Gardening/Landscaping',
    'Cleaning Specialist',
  ];

  bool _isLoading = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isLocating = true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final addressData = await LocationService.getAddressFromLatLng(
          position,
        );
        if (addressData != null) {
          setState(() {
            _cityController.text = addressData['city'] ?? '';
            _addressController.text = addressData['address'] ?? '';
            // Note: LocationService.getAddressFromLatLng currently doesn't return state/zip separately
            // but we can try to improve it or just pre-fill what we have.
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not fetch location. Please enable permissions.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == 'Labor' && _selectedLaborType == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select labor expertise'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please login to request a service',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final request = ServiceRequestModel(
        id: const Uuid().v4(),
        userId: user.uid,
        userName: user.name ?? 'User',
        userContact: user.phoneNumber,
        category: _selectedCategory,
        status: 'pending',
        createdAt: DateTime.now(),
        location: _cityController.text,
        city: _cityController.text,
        state: _stateController.text,
        zipCode: _zipController.text,
        fullAddress: _addressController.text,
        tenantEmail: user.email,
        details: {
          'problemDescription': _descriptionController.text,
          if (_selectedCategory == 'Labor' && _selectedLaborType != null)
            'laborExpertise': _selectedLaborType,
        },
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);

      LoggerService.trackEvent(
        'other_service_requested',
        parameters: {'category': _selectedCategory},
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Request Received'),
            content: Text(
              'Your $_selectedCategory request has been sent successfully. A professional will contact you shortly.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit request: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Widget _buildTextFieldWidget(
    TextEditingController controller,
    String label, {
    String? hint,
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryBlue,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.secondaryTextColor.withValues(alpha: 0.3),
              fontSize: 13.sp,
            ),
            prefixIcon: icon != null
                ? Icon(
                    icon,
                    color: AppTheme.primaryBlue.withValues(alpha: 0.4),
                    size: 20.sp,
                  )
                : null,
            filled: true,
            fillColor: context.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sp),
              borderSide: BorderSide(color: context.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sp),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sp),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    String displayLabel = label;
    if (label == 'Electrical fitting & services') {
      displayLabel = 'ELECTRICAL';
    } else if (label == 'Plumbing services') {
      displayLabel = 'PLUMBING';
    } else if (label == 'House painting') {
      displayLabel = 'PAINTING';
    } else if (label == 'House cleaning') {
      displayLabel = 'CLEANING';
    } else if (label == 'Labor') {
      displayLabel = 'LABOR';
    } else if (label == 'All') {
      displayLabel = 'ALL SERVICES';
    }

    return Padding(
      padding: EdgeInsets.only(right: 12.0.w),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? context.surfaceColor : context.cardColor,
            borderRadius: BorderRadius.circular(30.w),
            border: Border.all(
              color: isSelected ? AppTheme.primaryBlue : context.borderColor,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Text(
            displayLabel.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11.sp,
              fontFamily: 'Poppins',
              color: isSelected
                  ? AppTheme.primaryBlue
                  : context.primaryTextColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Handyman Hub',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: context.primaryTextColor,
                fontSize: 24.sp,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.w),
            ),
            child: IconButton(
              icon: Icon(
                Icons.help_outline,
                color: AppTheme.primaryBlue,
                size: 20.sp,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            DescribedFeatureOverlay(
              featureId: 'category_selection_feature_id',
              tapTarget: Icon(Icons.category_rounded, color: AppTheme.primaryBlue),
              title: const Text('Choose a Service'),
              description: const Text('Select from Electrical, Plumbing, Painting, or our new Labor service.'),
              backgroundColor: AppTheme.primaryBlue,
              targetColor: Colors.white,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                child: Row(
                  children: _categories
                      .asMap()
                      .entries
                      .map((entry) => _buildCategoryChip(entry.value))
                      .toList(),
                ),
              ),
            ),
            if (_selectedCategory == 'Labor') ...[
              SizedBox(height: 32.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LABOR EXPERTISE',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBlue,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Wrap(
                      spacing: 12.w,
                      runSpacing: 12.h,
                      children: _laborTypes.map((type) {
                        bool isSelected = _selectedLaborType == type;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedLaborType = type),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected ? context.surfaceColor : context.cardColor,
                              borderRadius: BorderRadius.circular(12.sp),
                              border: Border.all(
                                color: isSelected ? AppTheme.primaryBlue : context.borderColor,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _buildTextFieldWidget(
                _descriptionController,
                'Description',
                hint: 'Please describe in detail what needs to be fixed...',
                keyboardType: TextInputType.multiline,
                maxLines: 5,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SERVICE LOCATION',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _isLocating ? null : _fetchLocation,
                        icon: _isLocating
                            ? SizedBox(
                                height: 14.sp,
                                width: 14.sp,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryBlue,
                                ),
                              )
                            : Icon(
                                Icons.my_location,
                                size: 16.sp,
                                color: AppTheme.primaryBlue,
                              ),
                        label: Text(
                          'USE LIVE LOCATION',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 1.0,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          backgroundColor: AppTheme.primaryBlue.withValues(
                            alpha: 0.05,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildTextFieldWidget(
                    _addressController,
                    'Full Address',
                    hint: 'House No, Street, Area',
                    icon: Icons.home_rounded,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextFieldWidget(
                          _cityController,
                          'City',
                          hint: 'City',
                          icon: Icons.location_city_rounded,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextFieldWidget(
                          _zipController,
                          'Zip Code',
                          hint: 'Postal Code',
                          icon: Icons.local_post_office_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  _buildTextFieldWidget(
                    _stateController,
                    'State',
                    hint: 'State / Province',
                    icon: Icons.map_rounded,
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: context.scaffoldColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                elevation: 0,
                shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'REQUEST PROFESSIONAL',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                        letterSpacing: 1.5,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
