import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:uuid/uuid.dart';

class ConstructionScreen extends ConsumerStatefulWidget {
  const ConstructionScreen({super.key});

  @override
  ConsumerState<ConstructionScreen> createState() => _ConstructionScreenState();
}

class _ConstructionScreenState extends ConsumerState<ConstructionScreen> {
  String _selectedCategory = 'Residential'; // Residential or Commercial
  String _selectedService =
      'Construction'; // Construction, Architecture, Interiors, Consultation, Borewell

  final List<String> _services = [
    'Construction',
    'Architecture',
    'Interiors',
    'Consultation',
    'Borewell',
  ];

  // Controllers for all forms
  final _plotSizeController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _timelineController = TextEditingController();
  final _typeController = TextEditingController();
  
  final _dimensionsController = TextEditingController();
  final _facingController = TextEditingController();
  final _floorsController = TextEditingController();
  final _roomsController = TextEditingController();
  final _parkingController = TextEditingController();
  final _specialNeedsController = TextEditingController();
  
  final _propTypeController = TextEditingController();
  final _areaController = TextEditingController();
  String _stylePreference = 'Modern Minimalist';
  
  final _consultTopicController = TextEditingController();
  final _queryController = TextEditingController();
  
  final _soilTypeController = TextEditingController();
  final _depthController = TextEditingController();
  String _borewellPurpose = 'Residential Water Supply';

  @override
  void dispose() {
    _plotSizeController.dispose();
    _locationController.dispose();
    _budgetController.dispose();
    _timelineController.dispose();
    _typeController.dispose();
    _dimensionsController.dispose();
    _facingController.dispose();
    _floorsController.dispose();
    _roomsController.dispose();
    _parkingController.dispose();
    _specialNeedsController.dispose();
    _propTypeController.dispose();
    _areaController.dispose();
    _consultTopicController.dispose();
    _queryController.dispose();
    _soilTypeController.dispose();
    _depthController.dispose();
    super.dispose();
  }

  // Specific state for interior scope
  final List<String> _interiorScopes = [];

  Future<void> _submitForm() async {
    final userAsync = ref.read(currentUserDataProvider);
    final user = userAsync.value;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to submit a request')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      ),
    );

    try {
      final String requestId = 'SR-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      
      Map<String, dynamic> details = {};
      
      if (_selectedService == 'Construction') {
        details = {
          'plotSize': _plotSizeController.text,
          'location': _locationController.text,
          'budget': _budgetController.text,
          'timeline': _timelineController.text,
          'constructionType': _typeController.text,
          'category': _selectedCategory,
        };
      } else if (_selectedService == 'Architecture') {
        details = {
          'dimensions': _dimensionsController.text,
          'facing': _facingController.text,
          'floors': _floorsController.text,
          'rooms': _roomsController.text,
          'parking': _parkingController.text,
          'specialNeeds': _specialNeedsController.text,
        };
      } else if (_selectedService == 'Interiors') {
        details = {
          'propertyType': _propTypeController.text,
          'rooms': _roomsController.text, // Shared or use another
          'area': _areaController.text,
          'budget': _budgetController.text,
          'style': _stylePreference,
          'scopes': _interiorScopes,
        };
      } else if (_selectedService == 'Consultation') {
        details = {
          'topic': _consultTopicController.text,
          'address': _locationController.text,
          'query': _queryController.text,
        };
      } else if (_selectedService == 'Borewell') {
        details = {
          'landmark': _locationController.text,
          'soilType': _soilTypeController.text,
          'depth': _depthController.text,
          'purpose': _borewellPurpose,
        };
      }

      final request = ServiceRequestModel(
        id: requestId,
        userId: user.uid,
        userName: user.name ?? 'User',
        userContact: user.phoneNumber,
        category: _selectedService,
        status: 'Pending',
        details: details,
        location: _locationController.text,
        createdAt: DateTime.now(),
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);

      if (!mounted) return;
      context.pop(); // Close loader
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request Sent! A verified professional will contact you soon.'),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
      context.pop(); // Go back
    } catch (e) {
      if (!mounted) return;
      context.pop(); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
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
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: context.iconColor,
              size: 14,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Building & Design',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.headset_mic_outlined, color: context.iconColor),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Toggle (from image)
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       const Text('Construction Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2)),
            //       const SizedBox(height: 12),
            //       _buildCategoryToggle(),
            //     ],
            //   ),
            // ),

            // Service Selector (Horizontal Scroll)
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: _services
                    .map((service) => _buildServiceChip(service))
                    .toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Dynamic Form based on selected service
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildDynamicBody(),
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
            height: 54,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'REQUEST QUOTE & TIMELINE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryToggle() {
    bool isRes = _selectedCategory == 'Residential';
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = 'Residential'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                color: isRes ? Colors.black : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESIDENTIAL',
                      style: TextStyle(
                        color: isRes ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Homes & Villas',
                      style: TextStyle(
                        color: isRes ? Colors.grey[400] : Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = 'Commercial'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                color: !isRes ? Colors.black : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'COMMERCIAL',
                      style: TextStyle(
                        color: !isRes ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Office & Retail',
                      style: TextStyle(
                        color: !isRes ? Colors.grey[400] : Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceChip(String label) {
    bool isSelected = _selectedService == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () => setState(() => _selectedService = label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue
                : context.cardColor,
            borderRadius: BorderRadius.circular(30),
            border: isSelected ? null : Border.all(color: context.borderColor),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 10,
              letterSpacing: 0.5,
              color: isSelected ? Colors.white : context.primaryTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicBody() {
    switch (_selectedService) {
      case 'Construction':
        return _buildConstructionForm();
      case 'Architecture':
        return _buildArchitectureForm();
      case 'Interiors':
        return _buildInteriorsForm();
      case 'Consultation':
        return _buildConsultationForm();
      case 'Borewell':
        return _buildBorewellForm();
      default:
        return const SizedBox();
    }
  }

  // --- 1. Construction / Renovation ---
  Widget _buildConstructionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Construction Details',
          'Verified civil engineers only. No open contractor pool to ensure extreme quality control.',
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'PLOT SIZE (SQ. FT.)',
          'e.g., 2400',
          TextInputType.number,
          controller: _plotSizeController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'EXACT LOCATION',
          'City, Neighborhood or Coordinates',
          TextInputType.text,
          controller: _locationController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'BUDGET (₹)',
                'Estimated amount',
                TextInputType.number,
                controller: _budgetController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'TIMELINE',
                'e.g., 6 Months',
                TextInputType.text,
                controller: _timelineController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'TYPE OF CONSTRUCTION',
          'House, Building, Duplex, etc.',
          TextInputType.text,
          controller: _typeController,
        ),
        const SizedBox(height: 32),
        const Text(
          'DOCUMENT UPLOAD',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildUploadBox('Upload plot map and local approvals'),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- 2. Architecture Services ---
  Widget _buildArchitectureForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Architectural Design',
          'Map planning and structural design by licensed architects.',
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'PLOT DIMENSIONS',
                'L x W (in ft)',
                TextInputType.text,
                controller: _dimensionsController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'FACING',
                'North, East, etc.',
                TextInputType.text,
                controller: _facingController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'NO. OF FLOORS',
                'e.g., G+2',
                TextInputType.text,
                controller: _floorsController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'ROOM REQUIREMENT',
                'e.g., 4 BHK',
                TextInputType.text,
                controller: _roomsController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'PARKING CAPACITY',
          'No. of Cars / Bikes',
          TextInputType.text,
          controller: _parkingController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'SPECIAL NEEDS (OPTIONAL)',
          'Vastu compliance, Garden, Pool, etc.',
          TextInputType.text,
          controller: _specialNeedsController,
        ),
        const SizedBox(height: 32),
        _buildSelectionBox('OUTPUT REQUIRED', 'Conceptual Plan (MVP)', [
          'Conceptual Plan (MVP)',
          'Structural Plan',
          '3D Elevation (Phase 2)',
        ]),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- 3. Interior Designing ---
  Widget _buildInteriorsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Interior Designing',
          'Transform spaces with our curated interior design partners.',
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'PROPERTY TYPE',
                'Apartment, Villa',
                TextInputType.text,
                controller: _propTypeController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'BHK / ROOMS',
                'e.g., 3 BHK',
                TextInputType.text,
                controller: _roomsController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'CARPET AREA',
                'In Sq. Ft.',
                TextInputType.number,
                controller: _areaController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'BUDGET (₹)',
                'Expected total',
                TextInputType.number,
                controller: _budgetController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSelectionBox('STYLE PREFERENCE', 'Modern Minimalist', [
          'Modern Minimalist',
          'Traditional Indian',
          'Contemporary',
          'Industrial',
          'Luxury',
        ]),
        const SizedBox(height: 32),
        const Text(
          'SCOPE SELECTION',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildCheckbox('Full Home Interior'),
        _buildCheckbox('Modular Kitchen'),
        _buildCheckbox('Wardrobes & Storage'),
        _buildCheckbox('Room-Specific Renovation'),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- 4. Construction Consultation ---
  Widget _buildConsultationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Expert Consultation',
          'Civil-engineer-led consultation to inspect or advise on building matters.',
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'CONSULTATION TOPIC',
          'Structural Audit, Material Quality, Seepage, etc.',
          TextInputType.text,
          controller: _consultTopicController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'PROPERTY ADDRESS',
          'Where is the property?',
          TextInputType.text,
          controller: _locationController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          'DETAILED QUERY',
          'Describe the issue or advice needed...',
          TextInputType.multiline,
          maxLines: 4,
          controller: _queryController,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4FAFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.cyanAccent.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'VERIFIED EXPERTS ONLY',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Your lead is routed smartly and securely.',
                      style: TextStyle(color: Colors.black54, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- 5. Boring / Borewell ---
  Widget _buildBorewellForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Boring & Borewell',
          'Expert surveying and drilling tailored to geographical constraints.',
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'EXACT LOCATION / PLOT NO.',
          'Enter landmark',
          TextInputType.text,
          controller: _locationController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                'TYPE OF SOIL (IF KNOWN)',
                'e.g., Rocky, Red',
                TextInputType.text,
                controller: _soilTypeController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                'EXPECTED DEPTH',
                'In Feet',
                TextInputType.number,
                controller: _depthController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSelectionBox('PURPOSE', 'Residential Water Supply', [
          'Residential Water Supply',
          'Agriculture / Farming',
          'Industrial Supply',
        ]),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- Shared Builders ---

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String labelText,
    String hintText,
    TextInputType type, {
    int maxLines = 1,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            color: context.primaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.primaryTextColor,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionBox(
    String label,
    String value,
    List<String> dummyOptions,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10,
            color: context.primaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.primaryTextColor,
                ),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label) {
    bool isChecked = _interiorScopes.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isChecked)
            _interiorScopes.remove(label);
          else
            _interiorScopes.add(label);
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isChecked
              ? AppTheme.primaryBlue.withValues(alpha: 0.05)
              : context.cardColor,
          border: Border.all(
            color: isChecked ? AppTheme.primaryBlue : context.borderColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isChecked ? Icons.check_circle : Icons.circle_outlined,
              color: isChecked ? AppTheme.primaryBlue : Colors.grey.shade300,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: context.primaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadBox(String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tap to upload files',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
