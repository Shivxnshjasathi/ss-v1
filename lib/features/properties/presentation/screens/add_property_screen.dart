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

  Future<void> _fetchLocation() async {
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
              const SnackBar(content: Text('Location updated successfully!')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch location. Please check permissions.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e')),
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

  void _nextStep() async {
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
          'List Your Property',
          style: TextStyle(
            color: context.primaryTextColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                'Step $_currentStep of 3',
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
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    if (_currentStep == 1) _buildBasicInfoStep(),
                    if (_currentStep == 2) _buildLocationAndDetailsStep(),
                    if (_currentStep == 3) _buildMediaAndPricingStep(),
                  ],
                ),
              ),
            ),
            // Bottom Action Bar
            Container(
              padding: const EdgeInsets.all(16.0),
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSubmitting 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _currentStep < 3 ? 'Continue' : 'Post Listing',
                            style: const TextStyle(
                              fontSize: 16,
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

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Basic Information',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'What kind of property are you listing?',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        _buildLabel('Listing Type'),
        const SizedBox(height: 12),
        _buildChoiceChips(
          _listingTypes,
          _listingType,
          (val) => setState(() => _listingType = val),
        ),

        const SizedBox(height: 24),
        _buildLabel('Property Type'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _propertyTypes
              .map(
                (type) => _buildSelectionCard(
                  title: type,
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

  Widget _buildLocationAndDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Property Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us more about your property and its location.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: _isFetchingLocation ? null : _fetchLocation,
          icon: _isFetchingLocation 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.my_location, size: 18),
          label: Text(_isFetchingLocation ? 'Fetching Location...' : 'Use Current Location'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
        _buildLabel('City'),
        const SizedBox(height: 8),
        _buildTextField(
          'Enter city (e.g., Jabalpur)',
          Icons.location_city_outlined,
          controller: _cityController,
        ),

        const SizedBox(height: 16),
        _buildLabel('Locality / Society'),
        const SizedBox(height: 8),
        _buildTextField('Enter locality', Icons.map_outlined, controller: _localityController),

        const SizedBox(height: 24),
        _buildLabel('BHK Configuration'),
        const SizedBox(height: 12),
        _buildChoiceChips(
          _bhkOptions,
          _bhk,
          (val) => setState(() => _bhk = val),
        ),

        const SizedBox(height: 24),
        _buildLabel('Furnishing Status'),
        const SizedBox(height: 12),
        _buildChoiceChips(
          _furnishingOptions,
          _furnishingStatus,
          (val) => setState(() => _furnishingStatus = val),
        ),

        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Built Up Area'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'sq.ft.',
                    Icons.square_foot,
                    keyboardType: TextInputType.number,
                    controller: _areaController,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Bathrooms'),
                  const SizedBox(height: 8),
                  _buildTextField(
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
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Year Built'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    'e.g. 2023',
                    Icons.calendar_today_outlined,
                    keyboardType: TextInputType.number,
                    controller: _builtInController,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('Lot Size'),
                  const SizedBox(height: 8),
                  _buildTextField(
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

  Widget _buildMediaAndPricingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing & Photos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'Add a competitive price and high-quality photos.',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 32),

        _buildLabel(
          _listingType == 'Sell' ? 'Expected Price (₹)' : 'Monthly Rent (₹)',
        ),
        const SizedBox(height: 8),
        _buildTextField(
          'Enter amount',
          Icons.currency_rupee,
          keyboardType: TextInputType.number,
          controller: _priceController,
        ),

        const SizedBox(height: 16),
        if (_listingType == 'Rent/Lease') ...[
          _buildLabel('Security Deposit (₹)'),
          const SizedBox(height: 8),
          _buildTextField('Enter deposit amount', Icons.security, controller: _depositController),
          const SizedBox(height: 16),
        ],

        _buildLabel('Property Description'),
        const SizedBox(height: 8),
        _buildTextField(
          'Write a few lines about your property...',
          Icons.description_outlined,
          maxLines: 4,
          controller: _descriptionController,
        ),

        const SizedBox(height: 24),
        _buildLabel('Upload Photos'),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
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
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to upload property images',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Supports JPG, PNG (Max 5MB each)',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_selectedImages[index], height: 140, width: 140, fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(Icons.close, size: 16, color: Colors.white),
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
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildTextField(
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
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: Colors.grey)
            : Padding(
                padding: const EdgeInsets.only(bottom: 56),
                child: Icon(icon, color: Colors.grey),
              ),
        filled: true,
        fillColor: context.surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
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
      spacing: 12,
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
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade300,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
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
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black87,
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
