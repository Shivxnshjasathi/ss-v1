import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

class HomeLoanScreen extends StatefulWidget {
  const HomeLoanScreen({super.key});

  @override
  State<HomeLoanScreen> createState() => _HomeLoanScreenState();
}

class _HomeLoanScreenState extends State<HomeLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  String _employmentType = 'Salaried';
  final _incomeController = TextEditingController();
  final _cibilController = TextEditingController();
  final _emiController = TextEditingController();
  final _propertyValueController = TextEditingController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _bankRates = [
    {'bank': 'State Bank of India (SBI)', 'rate': '8.40% - 9.05%', 'fees': '0.35%'},
    {'bank': 'HDFC Bank', 'rate': '8.50% - 9.10%', 'fees': '₹3000'},
    {'bank': 'ICICI Bank', 'rate': '8.75% - 9.15%', 'fees': '0.50%'},
    {'bank': 'Axis Bank', 'rate': '8.75% - 9.20%', 'fees': '₹10,000'},
    {'bank': 'Bank of Baroda', 'rate': '8.40% - 9.15%', 'fees': 'Nil'},
  ];

  @override
  void dispose() {
    _incomeController.dispose();
    _cibilController.dispose();
    _emiController.dispose();
    _propertyValueController.dispose();
    super.dispose();
  }

  void _submitApplication() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        
        final l10n = AppLocalizations.of(context)!;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text(l10n.applicationSubmitted, textAlign: TextAlign.center, style: TextStyle(color: context.primaryTextColor)),
              ],
            ),
            content: Text(l10n.applicationSubmittedDesc, textAlign: TextAlign.center, style: TextStyle(color: context.secondaryTextColor)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('OK', style: TextStyle(color: Color(0xFF1E60FF))),
              )
            ],
          ),
        );
      });
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
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.homeLoans, style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.loanEligibilityForm,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: context.primaryTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us a little about your financial profile.',
                    style: TextStyle(color: context.secondaryTextColor, fontSize: 12, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(l10n.employmentType, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(l10n.salaried, _employmentType == 'Salaried', () => setState(() => _employmentType = 'Salaried')),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildChoiceChip(l10n.selfEmployed, _employmentType == 'Self-Employed', () => setState(() => _employmentType = 'Self-Employed')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  Text(l10n.annualIncome, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _incomeController,
                    hintText: 'e.g. 1200000',
                    keyboardType: TextInputType.number,
                    icon: Icons.currency_rupee,
                    validator: (val) => val == null || val.isEmpty ? l10n.fieldRequired : null,
                  ),
                  const SizedBox(height: 24),
                  
                  Text(l10n.cibilScore, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _cibilController,
                    hintText: 'e.g. 750',
                    keyboardType: TextInputType.number,
                    icon: Icons.speed,
                    validator: (val) {
                      if (val == null || val.isEmpty) return l10n.fieldRequired;
                      final score = int.tryParse(val);
                      if (score == null || score < 300 || score > 900) return 'Enter a valid CIBIL score (300-900)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  Text(l10n.monthlyEmi, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emiController,
                    hintText: 'e.g. 15000 (0 if none)',
                    keyboardType: TextInputType.number,
                    icon: Icons.account_balance_wallet,
                    validator: (val) => val == null || val.isEmpty ? l10n.fieldRequired : null,
                  ),
                  const SizedBox(height: 24),
                  
                  Text(l10n.propertyValue, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _propertyValueController,
                    hintText: 'e.g. 7500000',
                    keyboardType: TextInputType.number,
                    icon: Icons.maps_home_work_outlined,
                  ),
                  const SizedBox(height: 48),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E60FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(l10n.submitApplication, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Divider(color: context.borderColor),
            const SizedBox(height: 48),
            
            // Bank Rates Info
            Text('Current Bank Interest Rates', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: context.primaryTextColor)),
            const SizedBox(height: 8),
            Text('Real-time estimates for Indian home loans', style: TextStyle(color: context.secondaryTextColor, fontSize: 12)),
            const SizedBox(height: 24),
            ..._bankRates.map((bank) => _buildBankRateItem(bank)).toList(),
            const SizedBox(height: 32),
            
            // Requirements Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E60FF).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E60FF).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user, color: Color(0xFF1E60FF), size: 20),
                      const SizedBox(width: 8),
                      Text('General Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.primaryTextColor)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReqRow('Age', '21 - 65 years'),
                  _buildReqRow('Minimum CIBIL', '700+ (Preferred for low rates)'),
                  _buildReqRow('Income Proof', 'Salary slips / 2 Yrs ITR'),
                  _buildReqRow('Down Payment', 'At least 10% - 20% of value'),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E60FF).withValues(alpha: 0.1) : context.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? const Color(0xFF1E60FF) : context.borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF1E60FF) : context.secondaryTextColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required TextInputType keyboardType,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.normal),
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: context.cardColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E60FF), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.redAccent)),
      ),
      validator: validator,
    );
  }

  Widget _buildBankRateItem(Map<String, dynamic> bank) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bank['bank']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: context.primaryTextColor)),
                const SizedBox(height: 4),
                Text('Proc. Fee: ${bank['fees']}', style: TextStyle(color: context.secondaryTextColor, fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              bank['rate']!,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReqRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: context.secondaryTextColor),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(color: context.secondaryTextColor, fontSize: 12))),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: context.primaryTextColor)),
        ],
      ),
    );
  }
}
