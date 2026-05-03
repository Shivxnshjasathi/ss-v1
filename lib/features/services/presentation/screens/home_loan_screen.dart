import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';

class HomeLoanScreen extends ConsumerStatefulWidget {
  const HomeLoanScreen({super.key});

  @override
  ConsumerState<HomeLoanScreen> createState() => _HomeLoanScreenState();
}

class _HomeLoanScreenState extends ConsumerState<HomeLoanScreen> {
  final _formKey = GlobalKey<FormState>();
  String _employmentType = 'Salaried';
  final _incomeController = TextEditingController();
  final _cibilController = TextEditingController();
  final _emiController = TextEditingController();
  final _propertyValueController = TextEditingController();
  bool _isLoading = false;
  bool _isUploading = false;
  final Map<String, String> _uploadedDocs = {};

  final List<Map<String, dynamic>> _bankRates = [
    {
      'bank': 'State Bank of India (SBI)',
      'rate': '8.40% - 9.05%',
      'fees': '0.35%',
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

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _isUploading = true);
        
        final file = File(result.files.single.path!);
        final fileName = 'loan_doc_${DateTime.now().millisecondsSinceEpoch}.${result.files.single.extension}';
        final storageRef = FirebaseStorage.instance.ref().child('service_requests/loans/$fileName');
        
        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();
        
        setState(() {
          _uploadedDocs['Identity/Income Proof'] = downloadUrl;
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Document uploaded successfully!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submitApplication() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final parsedCibil = int.tryParse(_cibilController.text) ?? 0;
        final parsedIncome =
            double.tryParse(_incomeController.text.replaceAll(',', '')) ?? 0.0;

        // Simulating Bank Underwriting Algorithm
        // 60x Monthly Income for standard eligibility if CIBIL > 700
        bool isApproved = parsedCibil >= 700 && parsedIncome > 0;
        double preApprovalAmount = isApproved ? (parsedIncome / 12) * 60 : 0.0;

        final user = ref.read(currentUserDataProvider).value;
        if (user != null) {
          await ref
              .read(userRepositoryProvider)
              .updatePreApprovalStatus(
                user.uid,
                isApproved,
                preApprovalAmount,
                parsedCibil,
              );
        }

        if (!mounted) return;
        setState(() => _isLoading = false);

        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.w),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isApproved ? Icons.verified : Icons.info,
                  color: isApproved ? Colors.green : Colors.orange,
                  size: 60.w,
                ),
                SizedBox(height: 16.h),
                Text(
                  isApproved ? 'Pre-Approved!' : 'Application Reviewed',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.primaryTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Text(
              isApproved
                  ? 'Congratulations! Based on your profile, you are pre-approved for an estimated loan up to ₹${preApprovalAmount.toInt()}.\nThe badge has been added to your profile.'
                  : 'Your profile has been captured, but your CIBIL score is currently too low for instant pre-approval. A human agent will contact you shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.secondaryTextColor),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (isApproved) context.pop(); // Go back on success
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: AppTheme.primaryBlue),
                ),
              ),
            ],
          ),
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
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
              'Loan Services',
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
              onPressed: () => ContactBottomSheet.show(context),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildServiceChip(
                    l10n.salaried,
                    _employmentType == 'Salaried',
                    () => setState(() => _employmentType = 'Salaried'),
                  ),
                  _buildServiceChip(
                    l10n.selfEmployed,
                    _employmentType == 'Self-Employed',
                    () => setState(() => _employmentType = 'Self-Employed'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    l10n.loanEligibilityForm,
                    'Tell us a little about your financial profile.',
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          l10n.annualIncome,
                          'e.g. 12,00,000',
                          TextInputType.number,
                          controller: _incomeController,
                          validator: (val) => val == null || val.isEmpty ? '*' : null,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          l10n.cibilScore,
                          'e.g. 750',
                          TextInputType.number,
                          controller: _cibilController,
                          validator: (val) {
                            if (val == null || val.isEmpty) return '*';
                            final score = int.tryParse(val);
                            if (score == null || score < 300 || score > 900) return 'Invalid';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          l10n.monthlyEmi,
                          'e.g. 15,000 (0 if none)',
                          TextInputType.number,
                          controller: _emiController,
                          validator: (val) => val == null || val.isEmpty ? '*' : null,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _buildTextField(
                          l10n.propertyValue,
                          'e.g. 75,00,000',
                          TextInputType.number,
                          controller: _propertyValueController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 48.h),
            _buildSectionHeader(
              'Current Bank Interest Rates',
              'Real-time estimates for Indian home loans',
            ),
            SizedBox(height: 24.h),
            ..._bankRates.map((bank) => _buildBankRateItem(bank)),
            SizedBox(height: 32.h),

            // Requirements Section
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.w),
                border: Border.all(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppTheme.primaryBlue,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'General Requirements',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.sp,
                          color: context.primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Ensure you have these before applying for faster approval processing.',
                    style: TextStyle(color: Colors.black54, fontSize: 10.sp),
                  ),
                  SizedBox(height: 16.h),
                  _buildReqRow('Age', '21 - 65 years'),
                  _buildReqRow(
                    'Minimum CIBIL',
                    '700+ (Preferred for low rates)',
                  ),
                  _buildReqRow('Income Proof', 'Salary slips / 2 Yrs ITR'),
                  _buildReqRow('Down Payment', 'At least 10% - 20% of value'),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'DOCUMENT UPLOAD',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10.sp, color: AppTheme.primaryBlue, letterSpacing: 1.5),
            ),
            SizedBox(height: 12.h),
            _buildUploadBox('Upload Income Proof / ID (Salary Slip, PAN, Aadhar)'),
            SizedBox(height: 48.h),
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
              onPressed: _isLoading ? null : _submitApplication,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'APPLY FOR LOAN',
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

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            letterSpacing: -0.5,
            height: 1.1,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 13.sp,
            color: context.secondaryTextColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextInputType type, {
    TextEditingController? controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryBlue,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 10.h),
        TextFormField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          validator: validator,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: context.primaryTextColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.secondaryTextColor.withValues(alpha: 0.3),
              fontSize: 13.sp,
            ),
            filled: true,
            fillColor: context.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sp),
              borderSide: BorderSide(color: context.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sp),
              borderSide: BorderSide(color: context.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.sp),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 18.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? context.surfaceColor : context.cardColor,
            borderRadius: BorderRadius.circular(30.sp),
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

  Widget _buildBankRateItem(Map<String, dynamic> bank) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bank['bank']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: context.primaryTextColor,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Proc. Fee: ${bank['fees']}',
                  style: TextStyle(
                    color: context.secondaryTextColor,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.w),
            ),
            child: Text(
              bank['rate']!,
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w900,
                fontSize: 12.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReqRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 14.w,
            color: AppTheme.primaryBlue.withValues(alpha: 0.6),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: context.secondaryTextColor,
                fontSize: 11.sp,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 11.sp,
              color: context.primaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadBox(String subtitle) {
    final bool isUploaded = _uploadedDocs.isNotEmpty;

    return GestureDetector(
      onTap: _isUploading ? null : _pickDocument,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
        decoration: BoxDecoration(
          color: isUploaded ? Colors.green.withValues(alpha: 0.05) : context.cardColor,
          borderRadius: BorderRadius.circular(20.sp),
          border: Border.all(
            color: isUploaded ? Colors.green : context.borderColor,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            if (_isUploading)
              const CircularProgressIndicator(color: AppTheme.primaryBlue)
            else ...[
              Icon(
                isUploaded ? LucideIcons.circleCheck : LucideIcons.upload,
                color: isUploaded ? Colors.green : AppTheme.primaryBlue,
                size: 40.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                isUploaded ? 'Document Uploaded' : 'Tap to Upload',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16.sp,
                  color: isUploaded ? Colors.green : context.primaryTextColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(color: context.secondaryTextColor, fontSize: 12.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
