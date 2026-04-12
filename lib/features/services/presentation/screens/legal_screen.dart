import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/utils/validators.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';

class LegalScreen extends ConsumerStatefulWidget {
  const LegalScreen({super.key});

  @override
  ConsumerState<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends ConsumerState<LegalScreen> {
  // Service Selection
  String _selectedService = 'Rent Agreement';
  final List<String> _services = [
    'Rent Agreement',
    'Consult Lawyer',
    'Property Verification',
  ];

  // Rent Agreement State
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final _lessorController = TextEditingController();
  final _lesseeController = TextEditingController();
  final _lesseeEmailController = TextEditingController();
  final _addressController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  
  bool _isLandlordVerified = false;
  String? _generatedAgreementId;

  // Property Verification State
  final _propIdController = TextEditingController();
  final _propLocationController = TextEditingController();
  
  // Consult Lawyer State
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _consultDescriptionController = TextEditingController();
  
  String _legalReq = 'Buying Property';
  String _assetType = 'Apartment';

  @override
  void dispose() {
    _lessorController.dispose();
    _lesseeController.dispose();
    _lesseeEmailController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _propIdController.dispose();
    _propLocationController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _consultDescriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _showEkycBottomSheet() {
    final aadhaarController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Theme.of(ctx).scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('E-KYC Verification', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp)),
              SizedBox(height: 8.h),
              Text('Enter your 12-digit Aadhaar to simulate verification.', style: TextStyle(color: context.secondaryTextColor, fontSize: 13.sp)),
              SizedBox(height: 24.h),
              TextField(
                controller: aadhaarController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: 'Aadhaar Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.sp)),
                  prefixIcon: Icon(Icons.fingerprint),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (aadhaarController.text.length == 12) {
                      setState(() {
                        _isLandlordVerified = true;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('E-KYC Successful'), backgroundColor: Colors.green),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Enter a valid 12-digit Aadhaar number'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)),
                  ),
                  child: Text('Verify Identity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _generateAgreement() async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }
    if (!_isLandlordVerified) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please complete E-KYC first'), backgroundColor: Colors.red));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );

    try {
      final tenantEmail = _lesseeEmailController.text.trim();
      final tenantUser = await ref.read(userRepositoryProvider).getUserByEmail(tenantEmail);
      
      final requestId = 'AGR-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      final request = ServiceRequestModel(
        id: requestId,
        userId: user.uid,
        userName: user.name ?? _lessorController.text,
        userContact: user.phoneNumber,
        category: 'RentAgreement',
        status: 'Drafted',
        tenantEmail: tenantEmail,
        tenantId: tenantUser?.uid,
        details: {
          'lessorName': _lessorController.text,
          'lesseeName': _lesseeController.text,
          'lesseeEmail': tenantEmail,
          'propertyAddress': _addressController.text,
          'rent': _rentController.text,
          'deposit': _depositController.text,
          'isLessorVerified': _isLandlordVerified,
        },
        location: _addressController.text.split(',').last.trim(),
        createdAt: DateTime.now(),
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);

      if (!mounted) return;
      setState(() {
        _generatedAgreementId = requestId;
        _currentStep++;
      });
      context.pop(); // dismiss loading
    } catch (e) {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _showSignatureDialog() {
    final SignatureController signatureController = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Draw Your Signature', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18.sp)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 300.w,
                height: 150.h,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
                child: Signature(
                  controller: signatureController,
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => signatureController.clear(),
                    child: Text('Clear', style: TextStyle(color: Colors.red, fontSize: 13.sp)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (signatureController.isNotEmpty) {
                        final Uint8List? data = await signatureController.toPngBytes();
                        if (data != null) {
                          final String base64Signature = base64Encode(data);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            _signAgreementNatively(base64Signature);
                          }
                        }
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please draw your signature')));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.sp)),
                    ),
                    child: Text('Confirm', style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signAgreementNatively(String base64Signature) async {
    if (_generatedAgreementId == null) return;
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );

    try {
      final request = await ref.read(serviceRequestRepositoryProvider).getRequestById(_generatedAgreementId!);
      if (request != null) {
        final newDetails = Map<String, dynamic>.from(request.details);
        newDetails['lessorSignature'] = {
          'uid': user.uid,
          'name': user.name,
          'timestamp': DateTime.now().toIso8601String(),
          'kycMethod': 'Aadhaar',
        };
        newDetails['lessorSignatureImage'] = base64Signature;
        await ref.read(serviceRequestRepositoryProvider).updateRequestDetails(_generatedAgreementId!, newDetails);
        await ref.read(serviceRequestRepositoryProvider).updateRequestStatus(_generatedAgreementId!, 'Awaiting Tenant Signature');
      }
      
      if (!mounted) return;
      context.pop();
      setState(() {
        // Just triggering a rebuild so the signature might visually appear if we implemented live sync,
        // but since we don't watch the stream directly in this tab currently, we rely on state.
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully digitally signed!'), backgroundColor: Colors.green));
    } catch (e) {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _submitLawyerConsult() async {
    final userAsync = ref.read(currentUserDataProvider);
    final user = userAsync.value;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );

    try {
      final requestId = 'LEG-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      final request = ServiceRequestModel(
        id: requestId,
        userId: user.uid,
        userName: user.name ?? _fullNameController.text,
        userContact: user.phoneNumber.isNotEmpty ? user.phoneNumber : _phoneController.text,
        category: 'Legal Consultation',
        status: 'Pending',
        details: {
          'requirement': _legalReq,
          'city': _cityController.text,
          'propertyId': _propIdController.text,
          'description': _consultDescriptionController.text,
        },
        location: _cityController.text,
        createdAt: DateTime.now(),
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);

      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation Request Sent. A verified lawyer will contact you shortly.'), backgroundColor: AppTheme.primaryBlue),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _submitPropertyVerification() async {
    final userAsync = ref.read(currentUserDataProvider);
    final user = userAsync.value;
    
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );

    try {
      final requestId = 'VER-${const Uuid().v4().substring(0, 8).toUpperCase()}';
      final request = ServiceRequestModel(
        id: requestId,
        userId: user.uid,
        userName: user.name ?? 'User',
        userContact: user.phoneNumber,
        category: 'Property Verification',
        status: 'Pending',
        details: {
          'propertyId': _propIdController.text,
          'locality': _propLocationController.text,
          'assetType': _assetType,
        },
        location: _propLocationController.text,
        createdAt: DateTime.now(),
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);

      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification Request Submitted. We will audit the legal standing.'), backgroundColor: AppTheme.primaryBlue),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: _buildAppBar(l10n),
      body: Form(
        key: _formKey,
        child: _buildBody(l10n),
      ),
      bottomNavigationBar: _buildDynamicBottomNav(l10n),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                if (_selectedService == 'Rent Agreement' && _currentStep > 0) {
                  _prevStep();
                } else {
                  context.pop();
                }
              },
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
              l10n.legalHub,
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
              icon: Icon(Icons.help_outline, color: context.primaryTextColor, size: 20.sp),
              onPressed: () {},
            ),
          ),
        ],
      );
  }

  Widget _buildBody(AppLocalizations l10n) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          SizedBox(height: 24.h),
          
          if (_selectedService == 'Rent Agreement')
            Padding(
              padding: EdgeInsets.only(bottom: 24.0.h),
              child: _buildStepper(l10n),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: _buildDynamicBody(l10n),
            ),
          ),
        ],
      );
  }

  Widget _buildServiceChip(String label, AppLocalizations l10n) {
    bool isSelected = _selectedService == label;
    return Padding(
      padding: EdgeInsets.only(right: 12.0.w),
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedService = label;
          _currentStep = 0;
        }),
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
            label.toUpperCase(),
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
      case 'Rent Agreement': return _buildRentAgreementFlow(l10n);
      case 'Consult Lawyer': return _buildConsultLawyer(l10n);
      case 'Property Verification': return _buildPropertyVerification(l10n);
      default: return const SizedBox();
    }
  }

  Widget _buildDynamicBottomNav(AppLocalizations l10n) {
    if (_selectedService == 'Rent Agreement') {
      return _buildRentAgreementNav(l10n);
    } else if (_selectedService == 'Consult Lawyer') {
      return _buildLawyerConsultNav(l10n);
    } else if (_selectedService == 'Property Verification') {
      return _buildPropertyVerificationNav(l10n);
    }
    return const SizedBox.shrink(); 
  }

  Widget _buildLawyerConsultNav(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54.h,
          child: ElevatedButton(
            onPressed: _submitLawyerConsult,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.sp),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.submitConsultRequest.toUpperCase(),
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
    );
  }

  Widget _buildPropertyVerificationNav(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54.h,
          child: ElevatedButton(
            onPressed: _submitPropertyVerification,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
              elevation: 0,
            ),
            child: Text(l10n.requestFullVerification, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, color: Colors.white, letterSpacing: 0.5)),
          ),
        ),
      ),
    );
  }

  // --- 1. RENT AGREEMENT GENERATOR ---
  Widget _buildRentAgreementFlow(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('rent_agreement'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrentStepContent(l10n),
      ],
    );
  }

  Widget _buildStepper(AppLocalizations l10n) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator(l10n.review, 0),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(l10n.verify, 1),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(l10n.sign, 2),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String title, int stepIndex) {
    bool isCompleted = _currentStep > stepIndex;
    bool isActive = _currentStep == stepIndex;
    Color bgColor = isCompleted ? context.colorScheme.primary : (isActive ? context.colorScheme.primary : context.cardColor);
    Color textColor = (isCompleted || isActive) ? Colors.white : context.secondaryTextColor.withValues(alpha: 0.5);
    Border? border = (!isCompleted && !isActive) ? Border.all(color: context.borderColor, width: 2.w) : null;

    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(color: bgColor, border: border, shape: BoxShape.circle),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                : Text('${stepIndex + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13.sp)),
          ),
        ),
        SizedBox(height: 8.h),
        Text(title, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: isCompleted ? AppTheme.primaryBlue : (isActive ? AppTheme.primaryBlue : Colors.grey), letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildStepLine(int stepIndex) {
    return Container(
      height: 2.h,
      margin: EdgeInsets.only(top: 15.h, left: 8.w, right: 8.w),
      color: _currentStep > stepIndex ? context.colorScheme.primary : context.borderColor,
    );
  }

  Widget _buildCurrentStepContent(AppLocalizations l10n) {
    switch (_currentStep) {
      case 0: return _buildFormStep(l10n);
      case 1: return _buildVerificationStep(l10n);
      case 2: return _buildSignStep(l10n);
      default: return const SizedBox();
    }
  }

  Widget _buildFormStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.draftAgreement, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, letterSpacing: -0.5)),
        SizedBox(height: 8.h),
        Text(l10n.fillAgreementTerms, style: TextStyle(color: context.secondaryTextColor, fontSize: 13.sp, height: 1.5.h)),
        SizedBox(height: 32.h),
        _buildTextFieldWidget(_lessorController, l10n.lessorName, hint: 'e.g., Rajesh Kumar', icon: Icons.person_outline, validator: (val) => Validators.required(val, l10n.lessorName, l10n)),
        _buildTextFieldWidget(_lesseeController, l10n.lesseeName, hint: 'e.g., Suresh Singh', icon: Icons.person_outline, validator: (val) => Validators.required(val, l10n.lesseeName, l10n)),
        _buildTextFieldWidget(_lesseeEmailController, 'Tenant Email Address', hint: 'e.g., suresh@example.com', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (val) => Validators.email(val, l10n)),
        _buildTextFieldWidget(_addressController, l10n.propertyAddress, hint: 'e.g., Plot No. 45, Vijay Nagar, Jabalpur', icon: Icons.location_on_outlined, maxLines: 3, validator: (val) => Validators.required(val, l10n.propertyAddress, l10n)),
        Row(
          children: [
            Expanded(child: _buildTextFieldWidget(_rentController, l10n.monthlyRent, hint: 'e.g., 15000', keyboardType: TextInputType.number, icon: Icons.currency_rupee, validator: (val) => Validators.number(val, l10n.monthlyRent, l10n))),
            SizedBox(width: 16.w),
            Expanded(child: _buildTextFieldWidget(_depositController, l10n.depositLabel, hint: 'e.g., 30000', keyboardType: TextInputType.number, icon: Icons.account_balance_wallet_outlined, validator: (val) => Validators.number(val, l10n.depositLabel, l10n))),
          ],
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildVerificationStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.ekycVerification, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28.sp, letterSpacing: -1.0)),
        SizedBox(height: 8.h),
        Text(l10n.verifyIdentitiesSubtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 13.sp, height: 1.5.h, fontWeight: FontWeight.w500)),
        SizedBox(height: 32.h),
        _buildVerificationCard(l10n.landlordKyc, _lessorController.text, _isLandlordVerified, l10n, onTap: () {
          if (!_isLandlordVerified) _showEkycBottomSheet();
        }),
        SizedBox(height: 16.h),
        _buildVerificationCard('${l10n.tenantKyc}\n(${_lesseeEmailController.text})', _lesseeController.text, false, l10n),
      ],
    );
  }

  Widget _buildSignStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.rentAgreement, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28.sp, letterSpacing: -1.0)),
        SizedBox(height: 4.h),
        Text(l10n.leaseForProperty(_generatedAgreementId ?? 'AGR-DRAFT'), style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(16.sp),
          decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12.sp), border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.1))),
          child: Row(
            children: [
               Container(padding: EdgeInsets.all(8.sp), decoration: BoxDecoration(color: context.scaffoldColor, borderRadius: BorderRadius.circular(8.sp)), child: Icon(Icons.verified_user_outlined, color: context.primaryTextColor, size: 20.sp)),
               SizedBox(width: 12.w),
               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                 Text(l10n.digitalVerification, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, letterSpacing: -0.2)),
                 SizedBox(height: 2.h),
                 Text(l10n.estampedSeries, style: TextStyle(fontSize: 9.sp, color: context.secondaryTextColor, fontWeight: FontWeight.w800, letterSpacing: 0.5))
               ]),
            ],
          ),
        ),
        SizedBox(height: 32.h),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.lessorLabel, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: context.secondaryTextColor, letterSpacing: 0.5)), 
              SizedBox(height: 8.h), 
              Text(_lessorController.text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp, letterSpacing: -0.3))
            ])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.lesseeLabel, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: context.secondaryTextColor, letterSpacing: 0.5)), 
              SizedBox(height: 8.h), 
              Text(_lesseeController.text, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.sp, letterSpacing: -0.3))
            ])),
          ],
        ),
        SizedBox(height: 32.h),
        _buildClause('01', l10n.premisesTerm, 'The Lessor hereby leases to the Lessee the residential apartment located at ${_addressController.text} for a period of 11 months starting June 1, 2024.'),
        _buildClause('02', l10n.monthlyRentClause, 'The Lessee shall pay a monthly rent of ₹${_rentController.text} on or before the 5th of every calendar month via bank transfer.'),
        _buildClause('03', l10n.securityDepositClause, 'An interest-free refundable security deposit of ₹${_depositController.text} has been paid. This shall be returned upon peaceful possession handover.'),
        _buildClause('04', l10n.noticePeriod, 'Both parties agree to a mandatory 2-month notice period prior to early termination by either party.'),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(12.w), border: Border.all(color: context.borderColor)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16.w, color: Colors.grey),
              SizedBox(width: 8.w),
              Expanded(child: Text(l10n.legalDisclaimer, style: TextStyle(fontSize: 10.sp, color: context.secondaryTextColor, height: 1.5.h, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: Icon(Icons.chevron_right, size: 16.sp, color: AppTheme.primaryBlue),
            label: Text(l10n.viewDocumentDetails, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.sp, color: AppTheme.primaryBlue)),
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildRentAgreementNav(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: context.scaffoldColor, 
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep == 2)
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 54.h,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (_generatedAgreementId != null) {
                        final link = 'https://sampatti.app/services/legal/sign/$_generatedAgreementId';
                        Share.share('Please sign our Rent Agreement via this secure link: $link');
                      }
                    },
                    icon: Icon(Icons.ios_share, size: 18.sp, color: context.primaryTextColor),
                    label: Text('Share Link', style: TextStyle(color: context.primaryTextColor, fontSize: 13.sp, fontWeight: FontWeight.w900)),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)), side: BorderSide(color: context.borderColor)),
                  ),
                ),
              ),
            if (_currentStep == 2) SizedBox(width: 16.w),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 0) {
                      _nextStep();
                    } else if (_currentStep == 1) {
                      _generateAgreement();
                    } else if (_currentStep == 2) {
                      _showSignatureDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.sp)), elevation: 0),
                  child: Text(_currentStep == 0 ? l10n.nextVerification : (_currentStep == 1 ? l10n.generateAgreement : 'Self-Sign Natively'), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. CONSULT LAWYER ---
  Widget _buildConsultLawyer(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('consult_lawyer'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.legalCounsel, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28.sp, letterSpacing: -1.0)),
        SizedBox(height: 8.h),
        Text(l10n.legalCounselSubtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 13.sp, height: 1.5.h, fontWeight: FontWeight.w500)),
        SizedBox(height: 32.h),
        
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12.w), border: Border.all(color: Colors.red.withValues(alpha: 0.2))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.disclaimer, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.sp, color: Colors.red, letterSpacing: 0.5)),
                    SizedBox(height: 4.h),
                    Text(l10n.attorneyDisclaimer, style: TextStyle(fontSize: 10.sp, color: context.primaryTextColor, height: 1.5.h, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        _buildTextFieldWidget(_fullNameController, l10n.fullName, hint: 'e.g., Rajesh Kumar', icon: Icons.person_outline, validator: (val) => Validators.required(val, l10n.fullName, l10n)),
        _buildTextFieldWidget(_phoneController, l10n.phoneNumber, hint: '98XXXXXXXX', keyboardType: TextInputType.phone, icon: Icons.phone_outlined, validator: (val) => Validators.phone(val, l10n)),
        _buildTextFieldWidget(_cityController, l10n.cityRegion, hint: 'e.g., Jabalpur, MP', icon: Icons.location_city_outlined, validator: (val) => Validators.required(val, l10n.cityRegion, l10n)),
        _buildTextFieldWidget(_propIdController, l10n.propertyIdAny, hint: 'e.g., SB-1234 (If any)', icon: Icons.home_work_outlined),
        _buildDropdownField(l10n.legalRequirement, _legalReq, [l10n.buyingProperty, l10n.legalDispute, l10n.propertyVerification, l10n.other], (val) => setState(() => _legalReq = val)),
        TextFormField(
          controller: _consultDescriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'e.g., I need assistance with property title verification and document review...',
            hintStyle: TextStyle(color: context.secondaryTextColor.withValues(alpha: 0.5), fontSize: 13.sp),
            filled: true,
            fillColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.all(16.w),
          ),
          validator: (val) => Validators.required(val, l10n.expertsSubtitle, l10n),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  // --- 3. PROPERTY VERIFICATION ---
  Widget _buildPropertyVerification(AppLocalizations l10n) {
    return Column(
      key: const ValueKey('property_verification'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.propertyAudit, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28.sp, letterSpacing: -1.0)),
            Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.verified_user_outlined, color: AppTheme.primaryBlue, size: 20.sp),
            )
          ],
        ),
        SizedBox(height: 8.h),
        Text(l10n.propertyAuditSubtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 13.sp, height: 1.5.h, fontWeight: FontWeight.w500)),
        SizedBox(height: 32.h),

        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: context.cardColor, borderRadius: BorderRadius.circular(12.w), border: Border.all(color: context.borderColor)),
          child: Row(
            children: [
               Icon(Icons.shield, color: AppTheme.primaryBlue, size: 18.w),
               SizedBox(width: 12.w),
               Expanded(child: Text(l10n.verificationEnsures, style: TextStyle(color: context.primaryTextColor, fontSize: 11.sp, fontWeight: FontWeight.w600, height: 1.5.h))),
            ],
          ),
        ),
        SizedBox(height: 32.h),

        _buildTextFieldWidget(_propIdController, l10n.propertyIdOptional, hint: 'e.g., MP-14-1234', icon: Icons.home_work_outlined),
        _buildTextFieldWidget(_propLocationController, l10n.exactLocality, hint: 'e.g., Flat 4B, Emerald Heights', icon: Icons.location_on_outlined, validator: (val) => Validators.required(val, l10n.exactLocality, l10n)),
        _buildDropdownField(l10n.typeOfAsset, _assetType, [l10n.apartment, l10n.villaRowHouse, l10n.commercialOffice, 'Plot / Land'], (val) => setState(() => _assetType = val)),
        SizedBox(height: 24.h),
        
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          decoration: BoxDecoration(
             color: context.cardColor,
             border: Border.all(color: context.borderColor),
             borderRadius: BorderRadius.circular(12.sp),
          ),
          child: Column(
            children: [
              Container(padding: EdgeInsets.all(12.sp), decoration: BoxDecoration(color: context.scaffoldColor, shape: BoxShape.circle, border: Border.all(color: context.borderColor)), child: Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryBlue, size: 24.sp)),
              SizedBox(height: 16.h),
              Text(l10n.attachDocs, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp)),
              SizedBox(height: 6.h),
              Text(l10n.attachDocsSubtitle, textAlign: TextAlign.center, style: TextStyle(fontSize: 11.sp, color: context.secondaryTextColor, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        SizedBox(height: 32.h),
      ],
    );
  }

  // --- Core Shared Builders ---

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
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: context.secondaryTextColor, letterSpacing: 1.0),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: context.primaryTextColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: context.secondaryTextColor.withValues(alpha: 0.3), fontSize: 13.sp),
            prefixIcon: icon != null ? Icon(icon, color: AppTheme.primaryBlue.withValues(alpha: 0.4), size: 20.sp) : null,
            filled: true,
            fillColor: context.cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.sp), borderSide: BorderSide(color: context.borderColor)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.sp), borderSide: BorderSide(color: context.borderColor)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.sp), borderSide: BorderSide(color: AppTheme.primaryBlue, width: 1.5)),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp, color: context.secondaryTextColor, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _showSelectionMenu(label, options, value, onChanged),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(12.sp),
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: context.primaryTextColor), overflow: TextOverflow.ellipsis)),
                Icon(Icons.arrow_drop_down, color: Colors.grey, size: 24.sp),
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

  Widget _buildVerificationCard(String role, String name, bool isVerified, AppLocalizations l10n, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.sp),
        decoration: BoxDecoration(
          color: isVerified ? AppTheme.primaryBlue.withValues(alpha: 0.08) : context.cardColor,
          border: Border.all(
            color: isVerified ? AppTheme.primaryBlue.withValues(alpha: 0.2) : context.borderColor,
          ),
          borderRadius: BorderRadius.circular(20.sp),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.sp),
              decoration: BoxDecoration(
                color: isVerified ? AppTheme.primaryBlue.withValues(alpha: 0.1) : context.scaffoldColor,
                borderRadius: BorderRadius.circular(14.sp),
              ),
              child: Icon(
                isVerified ? Icons.verified : Icons.account_circle_outlined,
                color: isVerified ? AppTheme.primaryBlue : context.secondaryTextColor.withValues(alpha: 0.5),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.primaryBlue,
                      letterSpacing: 1.2,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                      color: context.primaryTextColor,
                      fontFamily: 'Poppins',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isVerified)
              Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 22.sp)
            else if (onTap != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Text(
                  'Verify',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: context.scaffoldColor,
                  borderRadius: BorderRadius.circular(10.sp),
                ),
                child: Text(
                  l10n.pending,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: context.secondaryTextColor,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClause(String number, String title, String body) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(8.sp),
              border: Border.all(color: context.borderColor),
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w900,
                color: AppTheme.primaryBlue,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14.sp,
                    color: context.primaryTextColor,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  body,
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 12.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(height: 16.h),
                Divider(height: 1.h, color: context.borderColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
