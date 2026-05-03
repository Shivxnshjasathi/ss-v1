import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';

class InsuranceScreen extends ConsumerStatefulWidget {
  const InsuranceScreen({super.key});

  @override
  ConsumerState<InsuranceScreen> createState() => _InsuranceScreenState();
}

class _InsuranceScreenState extends ConsumerState<InsuranceScreen> {
  final _formKey = GlobalKey<FormState>();
  String _insuranceType = 'Home Insurance';
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _contactController = TextEditingController();
  final _amountController = TextEditingController();
  final _detailsController = TextEditingController();
  
  bool _isLoading = false;
  bool _isUploading = false;
  final Map<String, String> _uploadedDocs = {};

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _contactController.dispose();
    _amountController.dispose();
    _detailsController.dispose();
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
        final fileName = 'insurance_doc_${DateTime.now().millisecondsSinceEpoch}.${result.files.single.extension}';
        final storageRef = FirebaseStorage.instance.ref().child('service_requests/insurance/$fileName');
        
        await storageRef.putFile(file);
        final downloadUrl = await storageRef.getDownloadURL();
        
        setState(() {
          _uploadedDocs['Verification Document'] = downloadUrl;
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
      if (_uploadedDocs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload at least one identification document.'), backgroundColor: Colors.orange),
        );
        return;
      }

      setState(() => _isLoading = true);
      // Simulate submission
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() => _isLoading = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.w)),
            title: Icon(Icons.check_circle, color: Colors.green, size: 60.w),
            content: const Text(
              'Your insurance request has been submitted successfully. Our agent will review your documents and contact you within 24 hours.',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('OK', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              'Insurance Services',
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
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            _buildSectionHeader(
              'Insurance Details',
              'Secure your property with specialized real estate insurance options from top providers.',
            ),
            SizedBox(height: 32.h),
            _buildTypeSelector(),
            SizedBox(height: 24.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField('Full Name', 'e.g., John Doe', TextInputType.name, controller: _nameController),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Age', 'e.g., 28', TextInputType.number, controller: _ageController)),
                      SizedBox(width: 16.w),
                      Expanded(child: _buildTextField('Contact', 'e.g., +91 98765 43210', TextInputType.phone, controller: _contactController)),
                    ],
                  ),
                  _buildTextField('Sum Insured (₹)', 'e.g., 50,00,000', TextInputType.number, controller: _amountController),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'DOCUMENT UPLOAD',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10.sp, color: AppTheme.primaryBlue, letterSpacing: 1.5),
            ),
            SizedBox(height: 12.h),
            _buildUploadBox('Upload ID Proof (Aadhar/PAN/Voter ID)'),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
                elevation: 0,
                shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'GET QUOTE',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 1.5, fontFamily: 'Poppins'),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = ['Home Insurance', 'Renters Insurance', 'Commercial Property', 'Title Insurance', 'Landlord Insurance'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT INSURANCE TYPE',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.sp, color: context.secondaryTextColor, letterSpacing: 1),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: types.map((type) {
              final isSelected = _insuranceType == type;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _insuranceType = type),
                  selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 12.sp,
                  ),
                  backgroundColor: context.cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.sp),
                    side: BorderSide(color: isSelected ? AppTheme.primaryBlue : context.borderColor),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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

  Widget _buildTextField(String label, String hint, TextInputType type, {TextEditingController? controller}) {
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
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
        SizedBox(height: 16.h),
      ],
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
