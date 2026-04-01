import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
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
  String _outputRequired = 'Conceptual Plan';

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
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(
          content: Text(l10n.requestSentSuccess),
          backgroundColor: AppTheme.primaryBlue,
        ),
      );
      context.pop(); // Go back
    } catch (e) {
      if (!mounted) return;
      context.pop(); // Close loader
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${l10n.loginError}: $e'), backgroundColor: Colors.red),
      );
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
          l10n.buildingAndDesign,
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
                    .map((service) => _buildServiceChip(service, l10n))
                    .toList(),
              ),
            ),

            const SizedBox(height: 32),

            // Dynamic Form based on selected service
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildDynamicBody(l10n),
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
              child: Text(
                l10n.requestQuote,
                style: const TextStyle(
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

  Widget _buildServiceChip(String label, AppLocalizations l10n) {
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
            _getLocalizedServiceName(label, l10n).toUpperCase(),
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

  Widget _buildDynamicBody(AppLocalizations l10n) {
    switch (_selectedService) {
      case 'Construction':
        return _buildConstructionForm(l10n);
      case 'Architecture':
        return _buildArchitectureForm(l10n);
      case 'Interiors':
        return _buildInteriorsForm(l10n);
      case 'Consultation':
        return _buildConsultationForm(l10n);
      case 'Borewell':
        return _buildBorewellForm(l10n);
      default:
        return const SizedBox();
    }
  }

  // --- 1. Construction / Renovation ---
  Widget _buildConstructionForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          l10n.constructionDetails,
          l10n.civilEngineersQuality,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          l10n.plotSize,
          'e.g., 2400',
          TextInputType.number,
          controller: _plotSizeController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          l10n.exactLocation,
          l10n.locationHint,
          TextInputType.text,
          controller: _locationController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.budgetLabel,
                l10n.budgetHint,
                TextInputType.number,
                controller: _budgetController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                l10n.timelineLabel,
                l10n.timelineHint,
                TextInputType.text,
                controller: _timelineController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          l10n.constructionType,
          l10n.constructionTypeHint,
          TextInputType.text,
          controller: _typeController,
        ),
        const SizedBox(height: 32),
        Text(
          l10n.documentUpload,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildUploadBox(l10n.uploadPlotMap),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- 2. Architecture Services ---
  Widget _buildArchitectureForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          l10n.architecturalDesign,
          l10n.archSubtitle,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.plotDimensions,
                l10n.dimensionsHint,
                TextInputType.text,
                controller: _dimensionsController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                l10n.facingLabel,
                l10n.facingHint,
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
                l10n.floorsCount,
                l10n.floorsHint,
                TextInputType.text,
                controller: _floorsController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                l10n.roomRequirement,
                l10n.roomsHint,
                TextInputType.text,
                controller: _roomsController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          l10n.parkingCapacity,
          l10n.parkingHint,
          TextInputType.text,
          controller: _parkingController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          l10n.specialNeeds,
          l10n.specialNeedsHint,
          TextInputType.text,
          controller: _specialNeedsController,
        ),
        const SizedBox(height: 32),
        _buildSelectionBox(l10n.outputRequired, _outputRequired, [
          l10n.conceptualPlan,
          l10n.structuralPlan,
          l10n.threeDElevation,
        ], (val) => setState(() => _outputRequired = val)),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- 3. Interior Designing ---
  Widget _buildInteriorsForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          l10n.interiors,
          l10n.interiorSubtitle,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.propertyType,
                l10n.propertyTypeHint,
                TextInputType.text,
                controller: _propTypeController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                l10n.bhkRooms,
                l10n.roomsHint,
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
                l10n.carpetArea,
                l10n.sqFtHint,
                TextInputType.number,
                controller: _areaController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                l10n.budgetLabel,
                l10n.budgetHint,
                TextInputType.number,
                controller: _budgetController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSelectionBox(l10n.stylePreference, _stylePreference, [
          l10n.modernMinimalist,
          l10n.traditionalIndian,
          l10n.contemporary,
          l10n.industrial,
          l10n.luxury,
        ], (val) => setState(() => _stylePreference = val)),
        const SizedBox(height: 32),
        Text(
          l10n.scopeSelection,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildCheckbox(l10n.fullHomeInterior),
        _buildCheckbox(l10n.modularKitchen),
        _buildCheckbox(l10n.wardrobesStorage),
        _buildCheckbox(l10n.roomRenovation),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- 4. Construction Consultation ---
  Widget _buildConsultationForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          l10n.expertConsultation,
          l10n.consultSubtitle,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          l10n.consultationTopic,
          l10n.consultTopicHint,
          TextInputType.text,
          controller: _consultTopicController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          l10n.propertyAddress,
          l10n.propertyAddressHint,
          TextInputType.text,
          controller: _locationController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          l10n.detailedQuery,
          l10n.queryHint,
          TextInputType.multiline,
          maxLines: 4,
          controller: _queryController,
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
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
                  children: [
                    Text(
                      l10n.verifiedExpertsOnly,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.expertsSubtitle,
                      style: TextStyle(color: context.secondaryTextColor, fontSize: 10),
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
  Widget _buildBorewellForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          l10n.boringBorewell,
          l10n.borewellSubtitle,
        ),
        const SizedBox(height: 24),
        _buildTextField(
          l10n.exactLocationBorewell,
          l10n.landmarkHint,
          TextInputType.text,
          controller: _locationController,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.soilType,
                l10n.soilTypeHint,
                TextInputType.text,
                controller: _soilTypeController,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                l10n.expectedDepth,
                l10n.depthHint,
                TextInputType.number,
                controller: _depthController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSelectionBox(l10n.purposeLabel, _borewellPurpose, [
          l10n.residentialWater,
          l10n.agricultureFarming,
          l10n.industrialSupply,
        ], (val) => setState(() => _borewellPurpose = val)),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- Shared Builders ---

  String _getLocalizedServiceName(String service, AppLocalizations l10n) {
    switch (service) {
      case 'Construction': return l10n.construction;
      case 'Architecture': return l10n.architecture;
      case 'Interiors': return l10n.interiors;
      case 'Consultation': return l10n.consultation;
      case 'Borewell': return l10n.borewell;
      default: return service;
    }
  }

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
    List<String> options,
    Function(String) onChanged,
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
        GestureDetector(
          onTap: () => _showSelectionMenu(label, options, value, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.primaryTextColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: context.iconColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionMenu(String title, List<String> options, String currentValue, Function(String) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  bool isSelected = option == currentValue;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryBlue) : null,
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_upload_outlined,
              color: AppTheme.primaryBlue,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.tapToUpload,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: context.primaryTextColor),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: context.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
