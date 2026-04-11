import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';
import 'package:sampatti_bazar/features/properties/domain/property_model.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:sampatti_bazar/core/services/location_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _depositController = TextEditingController();
  final TextEditingController _builtInController = TextEditingController();
  final TextEditingController _lotSizeController = TextEditingController();
  String _propertyType = 'Apartment';
  String _listingType = 'Sell';
  String _furnishingStatus = 'Semi-Furnished';
  String _bhk = '2 BHK';
  int _currentStep = 1;
  bool _isSubmitting = false;
  bool _isFetchingLocation = false;

  List<File> _selectedImages = [];

  final List<String> _propertyTypes = [
    'Apartment',
    'House/Villa',
    'Plot',
    'PG',
    'Commercial',
  ];
  final List<String> _listingTypes = ['Sell', 'Rent/Lease'];
  final List<String> _bhkOptions = [
    '1 RK',
    '1 BHK',
    '2 BHK',
    '3 BHK',
    '4+ BHK',
  ];
  final List<String> _furnishingOptions = [
    'Unfurnished',
    'Semi-Furnished',
    'Fully Furnished',
  ];

  String _getLocalizedListingType(AppLocalizations l10n, String type) {
    switch (type) {
      case 'Sell': return l10n.sell;
      case 'Rent/Lease': return l10n.rentLease;
      default: return type;
    }
  }

  String _getLocalizedPropertyType(AppLocalizations l10n, String type) {
    switch (type) {
      case 'Apartment': return l10n.apartment;
      case 'House/Villa': return l10n.houseVilla;
      case 'Plot': return l10n.plot;
      case 'PG': return l10n.pg;
      case 'Commercial': return l10n.commercial;
      default: return type;
    }
  }

  String _getLocalizedFurnishing(AppLocalizations l10n, String status) {
    switch (status) {
      case 'Unfurnished': return l10n.unfurnished;
      case 'Semi-Furnished': return l10n.semiFurnished;
      case 'Fully Furnished': return l10n.fullyFurnished;
      default: return status;
    }
  }

  Future<void> _fetchLocation(AppLocalizations l10n) async {
    setState(() => _isFetchingLocation = true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final addressData = await LocationService.getAddressFromLatLng(position);
        if (addressData != null) {
          setState(() {
            _cityController.text = addressData['city'] ?? '';
            _localityController.text = addressData['locality'] ?? '';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.locationUpdated)),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.couldNotFetchLocation)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((img) => File(img.path)));
      });
    }
  }

  @override
  void dispose() {
    _cityController.dispose();
    _localityController.dispose();
    _areaController.dispose();
    _bathroomsController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _depositController.dispose();
    _builtInController.dispose();
    _lotSizeController.dispose();
    super.dispose();
  }

  void _nextStep(AppLocalizations l10n) async {
    if (_currentStep < 3) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() => _isSubmitting = true);
        try {
          final user = ref.read(authRepositoryProvider).currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please wait until initialized or log in')));
            context.go('/login');
            return;
          }

          final property = PropertyModel(
            id: const Uuid().v4(),
            ownerId: user.uid,
            title: '$_bhk $_propertyType in ${_localityController.text}',
            description: _descriptionController.text,
            type: _listingType,
            propertyType: _propertyType,
            price: double.tryParse(_priceController.text) ?? 0,
            location: _localityController.text,
            city: _cityController.text,
            bedrooms: int.tryParse(_bhk.split(' ')[0]) ?? 0,
            bathrooms: int.tryParse(_bathroomsController.text) ?? 0,
            areaSqFt: double.tryParse(_areaController.text) ?? 0,
            imageUrls: [],
            createdAt: DateTime.now(),
            builtIn: int.tryParse(_builtInController.text),
            lotSizeSqFt: double.tryParse(_lotSizeController.text),
          );

          await ref.read(propertyRepositoryProvider).addProperty(property, _selectedImages);

          if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property listed successfully!')));
             context.pop();
          }
        } catch (e) {
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        } finally {
             if (mounted) setState(() => _isSubmitting = false);
        }
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.iconColor),
          onPressed: _previousStep,
        ),
        title: Text(
          l10n.listPropertyTitle,
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0.w),
            child: Center(
              child: Text(
                l10n.stepOf(_currentStep),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            LinearProgressIndicator(
              value: _currentStep / 3,
              backgroundColor: context.borderColor,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              minHeight: 4,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(24.0.w),
                  children: [
                    if (_currentStep == 1) _buildBasicInfoStep(l10n),
                    if (_currentStep == 2) _buildLocationAndDetailsStep(l10n),
                    if (_currentStep == 3) _buildMediaAndPricingStep(l10n),
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: EdgeInsets.all(16.0.w),
              decoration: BoxDecoration(
                color: context.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.w),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Text(
                          l10n.back,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 1) SizedBox(width: 16.w),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _nextStep(l10n),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                      ),
                      child: _isSubmitting 
                        ? SizedBox(width: 24.w, height: 24.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentStep < 3 ? l10n.continueButton : l10n.postListing,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.basicInfo,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 8.h),
        Text(
          'What kind of property are you listing?', // Localize this later if needed
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 32.h),
        _buildLabel(l10n.listingType),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.h,
          runSpacing: 12,
          children: _listingTypes.map((type) {
            final isSelected = _listingType == type;
            return ChoiceChip(
              label: Text(_getLocalizedListingType(l10n, type)),
              selected: isSelected,
              onSelected: (_) => setState(() => _listingType = type),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : context.primaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: context.surfaceColor,
              selectedColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.w),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            );
          }).toList(),
        ),

        SizedBox(height: 24.h),
        _buildLabel(l10n.propertyType),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.h,
          runSpacing: 12,
          children: _propertyTypes
              .map(
                (type) => _buildSelectionCard(
                  title: _getLocalizedPropertyType(l10n, type),
                  isSelected: _propertyType == type,
                  onTap: () => setState(() => _propertyType = type),
                  icon: _getIconForPropertyType(type),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildLocationAndDetailsStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.propertyDetails,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tell us more about your property and its location.', // Localize later
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 24.h),
        OutlinedButton.icon(
          onPressed: _isFetchingLocation ? null : () => _fetchLocation(l10n),
          icon: _isFetchingLocation 
            ? SizedBox(width: 16.w, height: 16.h, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(Icons.my_location, size: 18.w),
          label: Text(_isFetchingLocation ? l10n.fetchingLocation : l10n.useCurrentLocation),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
          ),
        ),
        SizedBox(height: 24.h),
        _buildLabel('City'), // Localize to "City" if needed
        SizedBox(height: 8.h),
        _buildTextField(
          l10n,
          'Enter city (e.g., Jabalpur)',
          Icons.location_city_outlined,
          controller: _cityController,
        ),

        SizedBox(height: 16.h),
        _buildLabel('Locality / Society'), // Localize later
        SizedBox(height: 8.h),
        _buildTextField(l10n, 'Enter locality', Icons.map_outlined, controller: _localityController),

        SizedBox(height: 24.h),
        _buildLabel(l10n.bhkConfiguration),
        SizedBox(height: 12.h),
        _buildChoiceChips(
          _bhkOptions,
          _bhk,
          (val) => setState(() => _bhk = val),
        ),

        SizedBox(height: 24.h),
        _buildLabel(l10n.furnishingStatus),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.h,
          runSpacing: 12,
          children: _furnishingOptions.map((option) {
            final isSelected = _furnishingStatus == option;
            return ChoiceChip(
              label: Text(_getLocalizedFurnishing(l10n, option)),
              selected: isSelected,
              onSelected: (_) => setState(() => _furnishingStatus = option),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : context.primaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: context.surfaceColor,
              selectedColor: Theme.of(context).colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.w),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade300,
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            );
          }).toList(),
        ),

        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(l10n.builtUpArea),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    l10n,
                    'sq.ft.',
                    Icons.square_foot,
                    keyboardType: TextInputType.number,
                    controller: _areaController,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(l10n.bath), // Using bath from ARB
                  SizedBox(height: 8.h),
                  _buildTextField(
                    l10n,
                    'e.g., 2',
                    Icons.bathtub_outlined,
                    keyboardType: TextInputType.number,
                    controller: _bathroomsController,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(l10n.yearBuilt),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    l10n,
                    'e.g. 2023',
                    Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    controller: _builtInController,
                  ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel(l10n.lotSize),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    l10n,
                    'sq.ft.',
                    Icons.aspect_ratio_outlined,
                    keyboardType: TextInputType.number,
                    controller: _lotSizeController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMediaAndPricingStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pricingPhotos,
          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900),
        ),
        SizedBox(height: 8.h),
        Text(
          'Add a competitive price and high-quality photos.', // Localize later
          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
        ),
        SizedBox(height: 32.h),

        _buildLabel(
          _listingType == 'Sell' ? l10n.expectedPrice : l10n.monthlyRent,
        ),
        SizedBox(height: 8.h),
        _buildTextField(
          l10n,
          'Enter amount',
          Icons.currency_rupee,
          keyboardType: TextInputType.number,
          controller: _priceController,
        ),

        SizedBox(height: 16.h),
        if (_listingType == 'Rent/Lease') ...[
          _buildLabel(l10n.securityDeposit),
          SizedBox(height: 8.h),
          _buildTextField(l10n, 'Enter deposit amount', Icons.security, controller: _depositController),
          SizedBox(height: 16.h),
        ],

        _buildLabel(l10n.propertyDescription),
        SizedBox(height: 8.h),
        _buildTextField(
          l10n,
          'Write a few lines about your property...', // Localize later
          Icons.description_outlined,
          maxLines: 4,
          controller: _descriptionController,
        ),

        SizedBox(height: 24.h),
        _buildLabel(l10n.uploadPhotos),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.w),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2.w,
                style: BorderStyle.none,
              ), // We'll simulate dashed by using an icon
            ),
            child: _selectedImages.isEmpty 
              ? DefaultTextStyle(
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 48.w,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        l10n.uploadPhotos,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Supports JPG, PNG (Max 5MB each)',
                        style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  padding: EdgeInsets.all(8.w),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 8.0.w),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.w),
                            child: Image.file(_selectedImages[index], height: 140.h, width: 140.w, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4.h,
                            right: 4.w,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: CircleAvatar(
                                radius: 12.w,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 16.w, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ),
      ],
    );
  }

  // Helpers
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(
    AppLocalizations l10n,
    String hint,
    IconData icon, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: Colors.grey)
            : Padding(
                padding: EdgeInsets.only(bottom: 56.h),
                child: Icon(icon, color: Colors.grey),
              ),
        filled: true,
        fillColor: context.surfaceColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.w),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.w),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.w),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.fieldRequired;
        }
        return null;
      },
    );
  }

  Widget _buildChoiceChips(
    List<String> options,
    String selectedValue,
    Function(String) onSelect,
  ) {
    return Wrap(
      spacing: 12.h,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedValue == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (_) => onSelect(option),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : context.primaryTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          backgroundColor: context.surfaceColor,
          selectedColor: Theme.of(context).colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.w),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        );
      }).toList(),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(16.w),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade600,
              size: 32.w,
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : context.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForPropertyType(String type) {
    switch (type) {
      case 'Apartment':
        return Icons.apartment;
      case 'House/Villa':
        return Icons.house_outlined;
      case 'Plot':
        return Icons.landscape_outlined;
      case 'PG':
        return Icons.bed_outlined;
      case 'Commercial':
        return Icons.storefront_outlined;
      default:
        return Icons.domain;
    }
  }
}
