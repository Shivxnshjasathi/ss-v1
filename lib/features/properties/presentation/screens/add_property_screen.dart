import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _propertyType = 'Apartment';
  String _listingType = 'Sell';
  String _furnishingStatus = 'Semi-Furnished';
  String _bhk = '2 BHK';
  int _currentStep = 1;

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

  void _nextStep() {
    if (_currentStep < 3) {
      if (_formKey.currentState?.validate() ?? false) {
        setState(() {
          _currentStep++;
        });
      }
    } else {
      if (_formKey.currentState?.validate() ?? false) {
        // Submit listing
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property listed successfully!')),
        );
        context.pop();
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
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
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
        const SizedBox(height: 32),
        _buildLabel('City'),
        const SizedBox(height: 8),
        _buildTextField(
          'Enter city (e.g., Jabalpur)',
          Icons.location_city_outlined,
        ),

        const SizedBox(height: 16),
        _buildLabel('Locality / Society'),
        const SizedBox(height: 8),
        _buildTextField('Enter locality', Icons.map_outlined),

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
        ),

        const SizedBox(height: 16),
        if (_listingType == 'Rent/Lease') ...[
          _buildLabel('Security Deposit (₹)'),
          const SizedBox(height: 8),
          _buildTextField('Enter deposit amount', Icons.security),
          const SizedBox(height: 16),
        ],

        _buildLabel('Property Description'),
        const SizedBox(height: 8),
        _buildTextField(
          'Write a few lines about your property...',
          Icons.description_outlined,
          maxLines: 4,
        ),

        const SizedBox(height: 24),
        _buildLabel('Upload Photos'),
        const SizedBox(height: 12),
        Container(
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
          child: DefaultTextStyle(
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
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
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
