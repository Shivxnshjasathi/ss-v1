import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    {
      'bank': 'State Bank of India (SBI)',
      'rate': '8.40% - 9.05%',
      'fees': '0.35%'
    },
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text(l10n.applicationSubmitted,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: context.primaryTextColor)),
              ],
            ),
            content: Text(l10n.applicationSubmittedDesc,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.secondaryTextColor)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('OK',
                    style: TextStyle(color: AppTheme.primaryBlue)),
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
          l10n.homeLoans,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildServiceChip(l10n.salaried,
                      _employmentType == 'Salaried', () => setState(() => _employmentType = 'Salaried')),
                  _buildServiceChip(l10n.selfEmployed,
                      _employmentType == 'Self-Employed', () => setState(() => _employmentType = 'Self-Employed')),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    l10n.loanEligibilityForm,
                    'Tell us a little about your financial profile.',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          labelText: l10n.annualIncome,
                          hintText: 'e.g. 12,00,000',
                          type: TextInputType.number,
                          controller: _incomeController,
                          validator: (val) =>
                              val == null || val.isEmpty ? '*' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          labelText: l10n.cibilScore,
                          hintText: 'e.g. 750',
                          type: TextInputType.number,
                          controller: _cibilController,
                          validator: (val) {
                            if (val == null || val.isEmpty) return '*';
                            final score = int.tryParse(val);
                            if (score == null || score < 300 || score > 900) {
                              return 'Invalid';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          labelText: l10n.monthlyEmi,
                          hintText: 'e.g. 15,000 (0 if none)',
                          type: TextInputType.number,
                          controller: _emiController,
                          validator: (val) =>
                              val == null || val.isEmpty ? '*' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          labelText: l10n.propertyValue,
                          hintText: 'e.g. 75,00,000',
                          type: TextInputType.number,
                          controller: _propertyValueController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            _buildSectionHeader(
              'Current Bank Interest Rates',
              'Real-time estimates for Indian home loans',
            ),
            const SizedBox(height: 24),
            ..._bankRates.map((bank) => _buildBankRateItem(bank)).toList(),
            const SizedBox(height: 32),

            // Requirements Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF4FAFD),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.cyanAccent.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined,
                          color: AppTheme.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text('General Requirements',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              color: context.primaryTextColor)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ensure you have these before applying for faster approval processing.',
                    style: TextStyle(color: Colors.black54, fontSize: 10),
                  ),
                  const SizedBox(height: 16),
                  _buildReqRow('Age', '21 - 65 years'),
                  _buildReqRow(
                      'Minimum CIBIL', '700+ (Preferred for low rates)'),
                  _buildReqRow('Income Proof', 'Salary slips / 2 Yrs ITR'),
                  _buildReqRow('Down Payment', 'At least 10% - 20% of value'),
                ],
              ),
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
              onPressed: _isLoading ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text(
                      l10n.submitApplication.toUpperCase(),
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
            color: context.primaryTextColor,
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

  Widget _buildServiceChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryBlue : context.cardColor,
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

  Widget _buildTextField({
    required String labelText,
    required String hintText,
    required TextInputType type,
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
          child: TextFormField(
            controller: controller,
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
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.redAccent)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              isDense: true,
            ),
            validator: validator,
          ),
        ),
      ],
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
                Text(bank['bank']!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: context.primaryTextColor)),
                const SizedBox(height: 4),
                Text('Proc. Fee: ${bank['fees']}',
                    style: TextStyle(
                        color: context.secondaryTextColor, fontSize: 10)),
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
              style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w900,
                  fontSize: 12),
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
          Icon(Icons.check_circle,
              size: 14, color: AppTheme.primaryBlue.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: context.secondaryTextColor, fontSize: 11))),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  color: context.primaryTextColor)),
        ],
      ),
    );
  }
}
