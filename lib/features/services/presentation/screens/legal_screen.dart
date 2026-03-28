import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  // Service Selection
  String _selectedService = 'Rent Agreement';
  final List<String> _services = [
    'Rent Agreement',
    'Consult Lawyer',
    'Property Verification',
  ];

  // Rent Agreement State
  int _currentStep = 0;
  final _lessorController = TextEditingController(text: 'Ramesh Kumar Iyer');
  final _lesseeController = TextEditingController(text: 'Aditi Sharma');
  final _addressController = TextEditingController(text: 'Flat 402, Skyline Heights, Indiranagar, Bangalore');
  final _rentController = TextEditingController(text: '32000');
  final _depositController = TextEditingController(text: '150000');

  // Property Verification State
  final _propIdController = TextEditingController();
  final _propLocationController = TextEditingController();

  @override
  void dispose() {
    _lessorController.dispose();
    _lesseeController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _propIdController.dispose();
    _propLocationController.dispose();
    super.dispose();
  }

  void _nextStep() {
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

  void _submitLawyerConsult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consultation Request Sent. A verified lawyer will contact you shortly.'), backgroundColor: AppTheme.primaryBlue),
      );
    });
  }

  void _submitPropertyVerification() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification Request Submitted. We will audit the legal standing and title history.'), backgroundColor: AppTheme.primaryBlue),
      );
    });
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
            child: Icon(Icons.arrow_back_ios_new, color: context.iconColor, size: 14),
          ),
          onPressed: () {
            if (_selectedService == 'Rent Agreement' && _currentStep > 0) {
              _prevStep();
            } else {
              context.pop();
            }
          },
        ),
        title: Text('Legal Hub', style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Selector Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Row(
              children: _services.map((service) => _buildServiceChip(service)).toList(),
            ),
          ),
          
          if (_selectedService == 'Rent Agreement')
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: _buildStepper(),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildDynamicBody(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildDynamicBottomNav(),
    );
  }

  Widget _buildServiceChip(String label) {
    bool isSelected = _selectedService == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedService = label;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : context.cardColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: isSelected ? AppTheme.primaryBlue : context.borderColor),
            boxShadow: isSelected 
                ? [BoxShadow(color: AppTheme.primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] 
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isSelected ? Colors.white : context.primaryTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicBody() {
    switch (_selectedService) {
      case 'Rent Agreement': return _buildRentAgreementFlow();
      case 'Consult Lawyer': return _buildConsultLawyer();
      case 'Property Verification': return _buildPropertyVerification();
      default: return const SizedBox();
    }
  }

  Widget _buildDynamicBottomNav() {
    if (_selectedService == 'Rent Agreement') {
      return _buildRentAgreementNav();
    } else if (_selectedService == 'Consult Lawyer') {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: context.scaffoldColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, -10))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submitLawyerConsult,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('SUBMIT CONSULTATION REQUEST', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
            ),
          ),
        ),
      );
    } else if (_selectedService == 'Property Verification') {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, -10))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submitPropertyVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('REQUEST FULL VERIFICATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white, letterSpacing: 0.5)),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink(); 
  }

  // --- 1. RENT AGREEMENT GENERATOR ---
  Widget _buildRentAgreementFlow() {
    return Column(
      key: const ValueKey('rent_agreement'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCurrentStepContent(),
      ],
    );
  }

  Widget _buildStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepIndicator('REVIEW', 0),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator('VERIFY', 1),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator('SIGN', 2),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(String title, int stepIndex) {
    bool isCompleted = _currentStep > stepIndex;
    bool isActive = _currentStep == stepIndex;
    Color bgColor = isCompleted ? AppTheme.primaryBlue : (isActive ? AppTheme.primaryBlue : context.cardColor);
    Color textColor = (isCompleted || isActive) ? Colors.white : Colors.grey.shade400;
    Border? border = (!isCompleted && !isActive) ? Border.all(color: context.borderColor, width: 2) : null;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bgColor, border: border, shape: BoxShape.circle),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text('${stepIndex + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCompleted ? AppTheme.primaryBlue : (isActive ? AppTheme.primaryBlue : Colors.grey), letterSpacing: 0.5)),
      ],
    );
  }

  Widget _buildStepLine(int stepIndex) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(top: 15, left: 8, right: 8),
      color: _currentStep > stepIndex ? AppTheme.primaryBlue : Colors.grey.shade200,
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildFormStep();
      case 1: return _buildVerificationStep();
      case 2: return _buildSignStep();
      default: return const SizedBox();
    }
  }

  Widget _buildFormStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Draft Agreement', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Fill in the specific terms of the rental lease before verification.', style: TextStyle(color: Colors.black54, fontSize: 13, height: 1.5)),
        const SizedBox(height: 32),
        _buildTextFieldWidget(_lessorController, 'LESSOR (LANDLORD) NAME', icon: Icons.person_outline),
        const SizedBox(height: 20),
        _buildTextFieldWidget(_lesseeController, 'LESSEE (TENANT) NAME', icon: Icons.person_outline),
        const SizedBox(height: 20),
        _buildTextFieldWidget(_addressController, 'PROPERTY ADDRESS', icon: Icons.location_on_outlined),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextFieldWidget(_rentController, 'MONTHLY RENT (₹)', keyboardType: TextInputType.number, icon: Icons.currency_rupee)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextFieldWidget(_depositController, 'DEPOSIT (₹)', keyboardType: TextInputType.number, icon: Icons.account_balance_wallet_outlined)),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('E-KYC Verification', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1.0)),
        const SizedBox(height: 8),
        Text('Verify identities securely before stamping the document digitally.', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        _buildVerificationCard('Landlord KYC', _lessorController.text, true),
        const SizedBox(height: 16),
        _buildVerificationCard('Tenant KYC', _lesseeController.text, false),
      ],
    );
  }

  Widget _buildSignStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rent Agreement', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1.0)),
        const SizedBox(height: 4),
        Text('Residential Lease for Property ID: SR-89291-BLR', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.cyanAccent.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.cyanAccent.withValues(alpha: 0.1))),
          child: Row(
            children: [
               Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.verified_user_outlined, color: AppTheme.cyanAccent, size: 20)),
               const SizedBox(width: 12),
               Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                 Text('DIGITAL VERIFICATION', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: -0.2)),
                 const SizedBox(height: 2),
                 const Text('E-STAMPED DOCUMENT • 2024 SERIES', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w800, letterSpacing: 0.5))
               ]),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('LESSOR (LANDLORD)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)), const SizedBox(height: 8), Text(_lessorController.text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.3))])),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('LESSEE (TENANT)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)), const SizedBox(height: 8), Text(_lesseeController.text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.3))])),
          ],
        ),
        const SizedBox(height: 32),
        _buildClause('01', 'PREMISES & TERM', 'The Lessor hereby leases to the Lessee the residential apartment located at ${_addressController.text} for a period of 11 months starting June 1, 2024.'),
        _buildClause('02', 'MONTHLY RENT', 'The Lessee shall pay a monthly rent of ₹${_rentController.text} on or before the 5th of every calendar month via bank transfer.'),
        _buildClause('03', 'SECURITY DEPOSIT', 'An interest-free refundable security deposit of ₹${_depositController.text} has been paid. This shall be returned upon peaceful possession handover.'),
        _buildClause('04', 'NOTICE PERIOD', 'Both parties agree to a mandatory 2-month notice period prior to early termination by either party.'),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(child: Text('This document is digitally prepared by Sampatti Bazar Legal. By signing, you agree to the Terms of Service and digital e-stamp protocols.', style: TextStyle(fontSize: 10, color: Colors.grey[700], height: 1.5, fontWeight: FontWeight.w500))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.chevron_right, size: 16, color: AppTheme.primaryBlue),
            label: Text('View Full Document Details', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 13, color: AppTheme.primaryBlue)),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildRentAgreementNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white, 
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
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.download, size: 18, color: context.primaryTextColor),
                    label: Text('Download', style: TextStyle(color: context.primaryTextColor, fontSize: 13, fontWeight: FontWeight.w900)),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: BorderSide(color: context.borderColor)),
                  ),
                ),
              ),
            if (_currentStep == 2) const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentStep == 2) context.pop();
                    else _nextStep();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                  child: Text(_currentStep == 0 ? 'Next: Verification' : (_currentStep == 1 ? 'Generate Agreement' : 'Sign Document'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. CONSULT LAWYER ---
  Widget _buildConsultLawyer() {
    return Column(
      key: const ValueKey('consult_lawyer'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Legal Counsel', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1.0)),
        const SizedBox(height: 8),
        Text('Receive trusted guidance from locally verified real-estate attorneys.', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.withValues(alpha: 0.2))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DISCLAIMER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.red, letterSpacing: 0.5)),
                    const SizedBox(height: 4),
                    Text('This form does not establish an attorney-client relationship. Information provided is not legal advice until a lawyer is officially retained.', style: TextStyle(fontSize: 10, color: context.primaryTextColor, height: 1.5, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        _buildTextFieldWidget(TextEditingController(), 'FULL NAME', icon: Icons.person_outline),
        const SizedBox(height: 16),
        _buildTextFieldWidget(TextEditingController(), 'PHONE NUMBER', keyboardType: TextInputType.phone, icon: Icons.phone_outlined),
        const SizedBox(height: 16),
        _buildTextFieldWidget(TextEditingController(), 'CITY / REGION', icon: Icons.location_city_outlined),
        const SizedBox(height: 16),
        _buildTextFieldWidget(TextEditingController(), 'PROPERTY ID (IF ANY)', icon: Icons.home_work_outlined),
        const SizedBox(height: 16),
        _buildDropdownField('LEGAL REQUIREMENT', 'Buying Property', ['Buying Property', 'Legal Dispute', 'Document Verification', 'Other']),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- 3. PROPERTY VERIFICATION ---
  Widget _buildPropertyVerification() {
    return Column(
      key: const ValueKey('property_verification'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Property Audit', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -1.0)),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.primaryBlue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.verified_user_outlined, color: AppTheme.primaryBlue, size: 20),
            )
          ],
        ),
        const SizedBox(height: 8),
        Text('We thoroughly verify ownership history, title encumbrances, and structural clearances to keep you safe from fraud.', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF4FAFD), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.cyanAccent.withValues(alpha: 0.1))),
          child: Row(
            children: [
               const Icon(Icons.shield, color: AppTheme.primaryBlue, size: 18),
               const SizedBox(width: 12),
               Expanded(child: Text('Verification ensures all local municipal NOCs and past ownership trails are legitimate.', style: TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w600, height: 1.5))),
            ],
          ),
        ),
        const SizedBox(height: 32),

        _buildTextFieldWidget(_propIdController, 'PROPERTY ID / RERA ID (OPTIONAL)', icon: Icons.home_work_outlined),
        const SizedBox(height: 16),
        _buildTextFieldWidget(_propLocationController, 'EXACT LOCALITY OR PROJECT NAME', icon: Icons.location_on_outlined),
        const SizedBox(height: 16),
        _buildDropdownField('TYPE OF ASSET', 'Apartment', ['Apartment', 'Villa / Row House', 'Commercial Office', 'Plot / Land']),
        const SizedBox(height: 24),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
             color: const Color(0xFFF5F5F5),
             border: Border.all(color: Colors.grey.shade300),
             borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade100)), child: const Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryBlue)),
              const SizedBox(height: 16),
              const Text('Attach Documents for Verification', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
              const SizedBox(height: 6),
              const Text('Sale deeds, NOCs, or previous agreements.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- Core Shared Builders ---

  Widget _buildTextFieldWidget(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.primaryTextColor),
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon, color: Colors.grey.shade400, size: 20) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.black54, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12),
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
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: context.primaryTextColor)),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationCard(String role, String name, bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isVerified ? AppTheme.primaryBlue.withValues(alpha: 0.05) : Colors.white, border: Border.all(color: isVerified ? AppTheme.primaryBlue.withValues(alpha: 0.1) : Colors.grey.shade100), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isVerified ? AppTheme.primaryBlue.withValues(alpha: 0.1) : const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(12)), child: Icon(isVerified ? Icons.verified : Icons.account_circle_outlined, color: isVerified ? AppTheme.primaryBlue : Colors.grey.shade400, size: 24)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(role.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[400], letterSpacing: 0.5)), const SizedBox(height: 4), Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3))])),
          if (isVerified) const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 20)
          else Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(8)), child: const Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5))),
        ],
      ),
    );
  }

  Widget _buildClause(String number, String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2)), const SizedBox(height: 6), Text(body, style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.5, fontWeight: FontWeight.w500)), const SizedBox(height: 16), Divider(height: 1, color: Colors.grey.shade100)])),
        ],
      ),
    );
  }
}
