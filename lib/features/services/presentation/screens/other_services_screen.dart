import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';

class OtherServicesScreen extends ConsumerStatefulWidget {
  const OtherServicesScreen({super.key});

  @override
  ConsumerState<OtherServicesScreen> createState() => _OtherServicesScreenState();
}

class _OtherServicesScreenState extends ConsumerState<OtherServicesScreen> {
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'Electrical fitting & services';
  final List<String> _categories = [
    'Electrical fitting & services',
    'Plumbing fitting & service',
    'House painting',
    'House cleaning',
    'All'
  ];

  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (_addressController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill out all fields.')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to request a service', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red));
        }
        return;
      }

      final request = ServiceRequestModel(
        id: const Uuid().v4(),
        userId: user.uid,
        userName: user.name ?? 'User',
        userContact: user.phoneNumber,
        category: _selectedCategory,
        status: 'pending',
        createdAt: DateTime.now(),
        location: _addressController.text,
        tenantEmail: user.email,
        details: {
          'problemDescription': _descriptionController.text,
        },
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);
      
      LoggerService.trackEvent('other_service_requested', parameters: {
        'category': _selectedCategory,
      });

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Request Received'),
            content: Text('Your $_selectedCategory request has been sent successfully. A professional will contact you shortly.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit request: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Same header matching construction UI
  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w900,
            fontSize: 24.sp,
            letterSpacing: -1.0,
            color: context.primaryTextColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.sp,
            height: 1.5.h,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Same textfield matching construction UI
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
            fontSize: 10.sp,
            color: context.primaryTextColor,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12.w),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
            style: TextStyle(
              fontSize: 14.sp,
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
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.w),
                borderSide: BorderSide(
                  color: AppTheme.primaryBlue,
                  width: 1.5.w,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    // Map internal key to pretty label
    String displayLabel = label;
    if (label == 'Electrical fitting & services') displayLabel = 'ELECTRICAL';
    else if (label == 'Plumbing fitting & service') displayLabel = 'PLUMBING';
    else if (label == 'House painting') displayLabel = 'PAINTING';
    else if (label == 'House cleaning') displayLabel = 'CLEANING';
    else if (label == 'All') displayLabel = 'ALL SERVICES';

    return Padding(
      padding: EdgeInsets.only(right: 12.0.w),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryBlue
                : context.cardColor,
            borderRadius: BorderRadius.circular(30.w),
            border: isSelected ? null : Border.all(color: context.borderColor),
          ),
          child: Text(
            displayLabel,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 10.sp,
              letterSpacing: 0.5,
              color: isSelected ? Colors.white : context.primaryTextColor,
            ),
          ),
        ),
      ),
    );
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
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              color: context.iconColor,
              size: 14.w,
            ),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Handyman Services',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.headset_mic_outlined, color: context.iconColor),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            
            // Category Selector (Horizontal Scroll matching 'CONSTRUCTION, ARCHITECTURE...')
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Row(
                children: _categories
                    .map((cat) => _buildCategoryChip(cat))
                    .toList(),
              ),
            ),

            SizedBox(height: 32.h),

            // Form Content
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Service Details',
                    'Book certified professionals for all your home repair and maintenance needs. Fast, reliable, and verified.',
                  ),
                  SizedBox(height: 24.h),
                  
                  _buildTextField(
                    'SERVICE ADDRESS',
                    'e.g. 123 Main St, Apartment 4B',
                    TextInputType.text,
                    controller: _addressController,
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  _buildTextField(
                    'PROBLEM DESCRIPTION',
                    'Please describe in detail what needs to be fixed...',
                    TextInputType.multiline,
                    maxLines: 5,
                    controller: _descriptionController,
                  ),
                  
                  SizedBox(height: 32.h),
                ],
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
            height: 54.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.w),
                ),
                elevation: 0,
              ),
              child: _isLoading 
                ? SizedBox(height: 20.h, width: 20.h, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(
                'REQUEST PROFESSIONAL',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13.sp,
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
}
