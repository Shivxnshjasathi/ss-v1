import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:sampatti_bazar/core/utils/validators.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class ConstructionScreen extends ConsumerStatefulWidget {
  const ConstructionScreen({super.key});

  @override
  ConsumerState<ConstructionScreen> createState() => _ConstructionScreenState();
}

class _ConstructionScreenState extends ConsumerState<ConstructionScreen> {
  final _formKey = GlobalKey<FormState>();
  final String _selectedCategory = 'Residential'; // Residential or Commercial
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
              l10n.buildingAndDesign,
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
              icon: Icon(Icons.headset_mic_outlined, color: context.primaryTextColor, size: 20.sp),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Toggle (from image)
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text('Construction Category', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, letterSpacing: -0.2)),
            //       SizedBox(height: 12.h),
            //       _buildCategoryToggle(),
            //     ],
            //   ),
            // ),

            // Service Selector (Horizontal Scroll)
            SizedBox(height: 12.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: _services
                    .map((service) => _buildServiceChip(service, l10n))
                    .toList(),
              ),
            ),

            SizedBox(height: 32.h),

            // Dynamic Form based on selected service
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Form(
                key: _formKey,
                child: _buildDynamicBody(l10n),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
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
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                elevation: 0,
                shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
              ),
              child: Text(
                l10n.requestQuote.toUpperCase(),
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

  Widget _buildServiceChip(String label, AppLocalizations l10n) {
    bool isSelected = _selectedService == label;
    return Padding(
      padding: EdgeInsets.only(right: 12.0.w),
      child: GestureDetector(
        onTap: () => setState(() => _selectedService = label),
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
            _getLocalizedServiceName(label, l10n).toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11.sp,
              fontFamily: 'Poppins',
              color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor,
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
        SizedBox(height: 24.h),
        _buildTextField(
          l10n.plotSize,
          'e.g., 2400',
          TextInputType.number,
          controller: _plotSizeController,
          validator: (val) => Validators.number(val, l10n.plotSize, l10n),
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          l10n.exactLocation,
          'e.g., Plot 42, Civil Lines',
          TextInputType.text,
          controller: _locationController,
          validator: (val) => Validators.required(val, l10n.exactLocation, l10n),
        ),
        SizedBox(height: 16.h),
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
            SizedBox(width: 16.w),
            Expanded(
              child: _buildTextField(
                l10n.timelineLabel,
                'e.g., 6 months',
                TextInputType.text,
                controller: _timelineController,
                validator: (val) => Validators.required(val, l10n.timelineLabel, l10n),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          l10n.constructionType,
          'e.g., Duplex / Row House',
          TextInputType.text,
          controller: _typeController,
          validator: (val) => Validators.required(val, l10n.constructionType, l10n),
        ),
        SizedBox(height: 32.h),
        Text(
          l10n.documentUpload,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11.sp,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        _buildUploadBox(l10n.uploadPlotMap),
        SizedBox(height: 32.h),
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
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.plotDimensions,
                'e.g., 30x50 ft',
                TextInputType.text,
                controller: _dimensionsController,
                validator: (val) => Validators.required(val, l10n.plotDimensions, l10n),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildTextField(
                l10n.facingLabel,
                'e.g., North / East',
                TextInputType.text,
                controller: _facingController,
                validator: (val) => Validators.required(val, l10n.facingLabel, l10n),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
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
            SizedBox(width: 16.w),
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
        SizedBox(height: 16.h),
        _buildTextField(
          l10n.parkingCapacity,
          l10n.parkingHint,
          TextInputType.text,
          controller: _parkingController,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          l10n.specialNeeds,
          l10n.specialNeedsHint,
          TextInputType.text,
          controller: _specialNeedsController,
        ),
        SizedBox(height: 32.h),
        _buildSelectionBox(l10n.outputRequired, _outputRequired, [
          l10n.conceptualPlan,
          l10n.structuralPlan,
          l10n.threeDElevation,
        ], (val) => setState(() => _outputRequired = val)),
        SizedBox(height: 32.h),
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
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.propertyType,
                'e.g., Apartment / Villa',
                TextInputType.text,
                controller: _propTypeController,
                validator: (val) => Validators.required(val, l10n.propertyType, l10n),
              ),
            ),
            SizedBox(width: 16.w),
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
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                l10n.carpetArea,
                'e.g., 1500',
                TextInputType.number,
                controller: _areaController,
                validator: (val) => Validators.number(val, l10n.carpetArea, l10n),
              ),
            ),
            SizedBox(width: 16.w),
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
        SizedBox(height: 16.h),
        _buildSelectionBox(l10n.stylePreference, _stylePreference, [
          l10n.modernMinimalist,
          l10n.traditionalIndian,
          l10n.contemporary,
          l10n.industrial,
          l10n.luxury,
        ], (val) => setState(() => _stylePreference = val)),
        SizedBox(height: 32.h),
        Text(
          l10n.scopeSelection,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 11.sp,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        _buildCheckbox(l10n.fullHomeInterior),
        _buildCheckbox(l10n.modularKitchen),
        _buildCheckbox(l10n.wardrobesStorage),
        _buildCheckbox(l10n.roomRenovation),
        SizedBox(height: 32.h),
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
        SizedBox(height: 24.h),
        _buildTextField(
          l10n.consultationTopic,
          'e.g., Structural Analysis',
          TextInputType.text,
          controller: _consultTopicController,
          validator: (val) => Validators.required(val, l10n.consultationTopic, l10n),
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          l10n.propertyAddress,
          l10n.propertyAddressHint,
          TextInputType.text,
          controller: _locationController,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          l10n.detailedQuery,
          l10n.queryHint,
          TextInputType.multiline,
          maxLines: 4,
          controller: _queryController,
        ),
        SizedBox(height: 32.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: AppTheme.primaryBlue,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.verifiedExpertsOnly,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.expertsSubtitle,
                      style: TextStyle(color: context.secondaryTextColor, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
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
        SizedBox(height: 24.h),
        _buildTextField(
          l10n.exactLocationBorewell,
          l10n.landmarkHint,
          TextInputType.text,
          controller: _locationController,
        ),
        SizedBox(height: 16.h),
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
            SizedBox(width: 16.w),
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
        SizedBox(height: 16.h),
        _buildSelectionBox(l10n.purposeLabel, _borewellPurpose, [
          l10n.residentialWater,
          l10n.agricultureFarming,
          l10n.industrialSupply,
        ], (val) => setState(() => _borewellPurpose = val)),
        SizedBox(height: 32.h),
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
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 22.sp,
            fontFamily: 'Poppins',
            color: context.primaryTextColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          style: TextStyle(
            color: context.secondaryTextColor,
            fontSize: 13.sp,
            height: 1.4,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
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
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10.sp,
            color: AppTheme.primaryBlue,
            letterSpacing: 1.5,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16.sp),
            border: Border.all(color: context.borderColor),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
            validator: validator,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: context.primaryTextColor,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: context.secondaryTextColor.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 18.w,
                vertical: 16.h,
              ),
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
            fontSize: 10.sp,
            color: context.primaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _showSelectionMenu(label, options, value, onChanged),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
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
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp)),
            SizedBox(height: 16.h),
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
                    trailing: isSelected ? Icon(Icons.check_circle, color: AppTheme.primaryBlue) : null,
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
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
          if (isChecked) {
            _interiorScopes.remove(label);
          } else {
            _interiorScopes.add(label);
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isChecked
              ? AppTheme.primaryBlue.withValues(alpha: 0.08)
              : context.cardColor,
          border: Border.all(
            color: isChecked ? AppTheme.primaryBlue : context.borderColor,
          ),
          borderRadius: BorderRadius.circular(16.sp),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isChecked ? AppTheme.primaryBlue : Colors.transparent,
                border: Border.all(
                  color: isChecked ? AppTheme.primaryBlue : context.borderColor,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? Icon(Icons.check, color: Colors.white, size: 12.w)
                  : null,
            ),
            SizedBox(width: 14.w),
            Text(
              label,
              style: TextStyle(
                fontWeight: isChecked ? FontWeight.w900 : FontWeight.w700,
                fontSize: 14.sp,
                fontFamily: 'Poppins',
                color: isChecked ? AppTheme.primaryBlue : context.primaryTextColor,
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
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(20.sp),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18.sp),
            ),
            child: Icon(
              Icons.cloud_upload_outlined,
              color: AppTheme.primaryBlue,
              size: 28.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            l10n.tapToUpload,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16.sp,
              color: context.primaryTextColor,
              fontFamily: 'Poppins',
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: context.secondaryTextColor,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
