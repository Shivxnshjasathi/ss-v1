import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:uuid/uuid.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/features/services/data/service_request_repository.dart';
import 'package:sampatti_bazar/features/services/domain/service_request_model.dart';

class OtherServicesScreen extends ConsumerStatefulWidget {
  const OtherServicesScreen({super.key});

  @override
  ConsumerState<OtherServicesScreen> createState() =>
      _OtherServicesScreenState();
}

class _OtherServicesScreenState extends ConsumerState<OtherServicesScreen> {
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Electrical fitting & services';
  final List<String> _categories = [
    'Electrical fitting & services',
    'Plumbing services',
    'House painting',
    'House cleaning',
    'All',
  ];

  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (_addressController.text.trim().isEmpty ||
        _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all fields.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserDataProvider).value;
      if (user == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Please login to request a service',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
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
        details: {'problemDescription': _descriptionController.text},
      );

      await ref.read(serviceRequestRepositoryProvider).addRequest(request);

      LoggerService.trackEvent(
        'other_service_requested',
        parameters: {'category': _selectedCategory},
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Request Received'),
            content: Text(
              'Your $_selectedCategory request has been sent successfully. A professional will contact you shortly.',
            ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit request: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
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
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
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

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    // Map internal key to pretty label
    String displayLabel = label;
    if (label == 'Electrical fitting & services') {
      displayLabel = 'ELECTRICAL';
    } else if (label == 'Plumbing fitting & service') {
      displayLabel = 'PLUMBING';
    } else if (label == 'House painting') {
      displayLabel = 'PAINTING';
    } else if (label == 'House cleaning') {
      displayLabel = 'CLEANING';
    } else if (label == 'All') {
      displayLabel = 'ALL SERVICES';
    }

    return Padding(
      padding: EdgeInsets.only(right: 12.0.w),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = label),
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
            displayLabel.toUpperCase(),
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
              'Handyman Hub',
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
              icon: Icon(Icons.help_outline, color: AppTheme.primaryBlue, size: 20.sp),
              onPressed: () {},
            ),
          ),
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
                    .asMap()
                    .entries
                    .map(
                      (entry) => _buildCategoryChip(entry.value),
                    )
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
            height: 54.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                elevation: 0,
                shadowColor: AppTheme.primaryBlue.withValues(alpha: 0.4),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'REQUEST PROFESSIONAL',
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
}
