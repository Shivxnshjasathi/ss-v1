import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  int _currentStep = 0;

  // Controllers for the form
  final _lessorController = TextEditingController(text: 'Ramesh Kumar Iyer');
  final _lesseeController = TextEditingController(text: 'Aditi Sharma');
  final _addressController = TextEditingController(text: 'Flat 402, Skyline Heights, Indiranagar, Bangalore');
  final _rentController = TextEditingController(text: '32000');
  final _depositController = TextEditingController(text: '150000');

  @override
  void dispose() {
    _lessorController.dispose();
    _lesseeController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
          ),
          onPressed: _prevStep,
        ),
        title: const Text('Legal Documents', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: _buildStepper(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentStepContent(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildStepper() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepIndicator('REVIEW', 0),
        _buildStepLine(0),
        _buildStepIndicator('VERIFY', 1),
        _buildStepLine(1),
        _buildStepIndicator('SIGN', 2),
      ],
    );
  }

  Widget _buildStepIndicator(String title, int stepIndex) {
    bool isCompleted = _currentStep > stepIndex;
    bool isActive = _currentStep == stepIndex;

    Color bgColor = isCompleted ? Colors.black : (isActive ? const Color(0xFF0066FF) : Colors.white);
    Color textColor = (isCompleted || isActive) ? Colors.white : Colors.grey.shade500;
    Border? border = (!isCompleted && !isActive) ? Border.all(color: Colors.grey.shade300) : null;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            border: border,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text('${stepIndex + 1}', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: isCompleted ? Colors.black : (isActive ? const Color(0xFF0066FF) : Colors.grey),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int stepIndex) {
    bool isCompleted = _currentStep > stepIndex;
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(top: 15, left: 12, right: 12),
      color: isCompleted ? Colors.black : Colors.grey.shade200,
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildFormStep();
      case 1:
        return _buildVerificationStep();
      case 2:
        return _buildSignStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelText, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: Colors.black87, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.transparent),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF0066FF), width: 1.5)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormStep() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Draft Agreement', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Fill in the specific terms of the rental lease before verification.', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),
        
        _buildTextField(_lessorController, 'LESSOR (LANDLORD) NAME'),
        const SizedBox(height: 20),
        _buildTextField(_lesseeController, 'LESSEE (TENANT) NAME'),
        const SizedBox(height: 20),
        _buildTextField(_addressController, 'PROPERTY ADDRESS'),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField(_rentController, 'MONTHLY RENT (₹)', keyboardType: TextInputType.number)),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(_depositController, 'DEPOSIT (₹)', keyboardType: TextInputType.number)),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildVerificationStep() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('E-KYC Verification', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        Text('Verify identities securely before stamping the document digitally.', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5, fontWeight: FontWeight.w500)),
        const SizedBox(height: 32),

        _buildVerificationCard('Landlord KYC', _lessorController.text, true),
        const SizedBox(height: 16),
        _buildVerificationCard('Tenant KYC', _lesseeController.text, false),
      ],
    );
  }

  Widget _buildVerificationCard(String role, String name, bool isVerified) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFF0066FF).withValues(alpha: 0.05) : Colors.white,
        border: Border.all(color: isVerified ? const Color(0xFF0066FF).withValues(alpha: 0.2) : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(16),
        boxShadow: !isVerified ? [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))] : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isVerified ? const Color(0xFF0066FF).withValues(alpha: 0.1) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(isVerified ? Icons.verified : Icons.account_circle_outlined, color: isVerified ? const Color(0xFF0066FF) : Colors.grey.shade600, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey[500], letterSpacing: 0.5)),
                const SizedBox(height: 4),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: -0.3)),
              ],
            ),
          ),
          if (isVerified)
             const Icon(Icons.check_circle, color: Color(0xFF0066FF), size: 20)
          else
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
               decoration: BoxDecoration(
                 color: Colors.grey.shade100,
                 borderRadius: BorderRadius.circular(8),
               ),
               child: const Text('PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
             ),
        ],
      ),
    );
  }

  Widget _buildSignStep() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rent Agreement', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 28, letterSpacing: -0.5)),
        const SizedBox(height: 4),
        Text('Residential Lease for Property ID: SR-89291-BLR', style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 24),

        // Badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.verified_user_outlined, color: Color(0xFF00D1FF), size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('DIGITAL VERIFICATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: -0.2)),
                  SizedBox(height: 2),
                  Text('E-STAMPED DOCUMENT • 2024 SERIES', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Parties
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LESSOR (LANDLORD)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text(_lessorController.text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.3)),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LESSEE (TENANT)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Text(_lesseeController.text, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: -0.3)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // Clauses
        _buildClause('01', 'PREMISES & TERM', 'The Lessor hereby leases to the Lessee the residential apartment located at ${_addressController.text} for a period of 11 months starting June 1, 2024.'),
        _buildClause('02', 'MONTHLY RENT', 'The Lessee shall pay a monthly rent of ₹${_rentController.text} on or before the 5th of every calendar month via bank transfer.'),
        _buildClause('03', 'SECURITY DEPOSIT', 'An interest-free refundable security deposit of ₹${_depositController.text} has been paid. This shall be returned upon peaceful possession handover.'),
        _buildClause('04', 'NOTICE PERIOD', 'Both parties agree to a mandatory 2-month notice period prior to early termination of the lease by either the Lessor or the Lessee.'),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This document is digitally prepared by Sampatti Bazar Legal. By signing, you agree to the Terms of Service and digital e-stamp protocols.',
                  style: TextStyle(fontSize: 10, color: Colors.grey[700], height: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: -0.2)),
                const SizedBox(height: 6),
                Text(body, style: TextStyle(color: Colors.grey[700], fontSize: 12, height: 1.5, fontWeight: FontWeight.w500)),
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.grey.shade100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32), // Add bottom padding for modern notch
      decoration: BoxDecoration(
        color: Colors.white, 
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
        child: Row(
          children: [
            if (_currentStep == 2)
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, size: 18, color: Colors.black87),
                    label: const Text('Save PDF', style: TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w900)),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
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
                    if (_currentStep == 2) {
                      context.pop();
                    } else {
                      _nextStep();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    _currentStep == 0 ? 'Next: Verification' : (_currentStep == 1 ? 'Generate Agreement' : 'Sign & Submit'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
