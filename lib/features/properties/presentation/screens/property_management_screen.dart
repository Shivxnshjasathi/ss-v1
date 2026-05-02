import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/features/properties/data/property_repository.dart';

class PropertyManagementScreen extends ConsumerStatefulWidget {
  final String propertyId;
  const PropertyManagementScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyManagementScreen> createState() => _PropertyManagementScreenState();
}

class _PropertyManagementScreenState extends ConsumerState<PropertyManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, bool> _uploadingStates = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _pickAndUpload(String category) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _uploadingStates[category] = true);
        
        final file = File(result.files.single.path!);
        final fileName = '${category.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.${result.files.single.extension}';
        final storageRef = FirebaseStorage.instance.ref().child('property_vault/${widget.propertyId}/$fileName');
        
        await storageRef.putFile(file);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ $category uploaded successfully!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload failed: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _uploadingStates[category] = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = ref.watch(propertyProvider(widget.propertyId));

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.chevronLeft, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Manage Property',
          style: TextStyle(fontWeight: FontWeight.w900, color: context.primaryTextColor, fontSize: 18.sp),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Digital Vault', icon: Icon(LucideIcons.shieldCheck)),
            Tab(text: 'Maintenance', icon: Icon(LucideIcons.calendarDays)),
          ],
        ),
      ),
      body: propertyAsync.when(
        data: (property) {
          if (property == null) return const Center(child: Text('Property not found'));
          return TabBarView(
            controller: _tabController,
            children: [
              _buildDigitalVault(context),
              _buildMaintenanceScheduler(context),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDigitalVault(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        _buildInfoCard(
          'Encrypted Document Vault',
          'Your documents are stored with end-to-end encryption and are only accessible by you.',
          LucideIcons.lock,
          Colors.green,
        ),
        SizedBox(height: 24.h),
        Text('PROPERTY DOCUMENTS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, letterSpacing: 1.2, color: Colors.grey)),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16.w,
          crossAxisSpacing: 16.w,
          childAspectRatio: 1.1,
          children: [
            _buildVaultItem('Property Deed', LucideIcons.fileText, '2.4 MB', true),
            _buildVaultItem('Tax Receipts', LucideIcons.receipt, '1.1 MB', true),
            _buildVaultItem('Insurance', LucideIcons.shield, '0.8 MB', false),
            _buildVaultItem('Floor Plans', LucideIcons.map, 'Empty', false),
          ],
        ),
        SizedBox(height: 32.h),
        ElevatedButton.icon(
          onPressed: () => _pickAndUpload('Other Document'),
          icon: Icon(LucideIcons.upload, size: 18.sp),
          label: Text('UPLOAD NEW DOCUMENT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
          ),
        ),
      ],
    );
  }

  Widget _buildVaultItem(String title, IconData icon, String size, bool isUploaded) {
    final bool isUploading = _uploadingStates[title] ?? false;

    return GestureDetector(
      onTap: isUploading ? null : () => _pickAndUpload(title),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(color: (isUploaded || isUploading) ? AppTheme.primaryBlue.withValues(alpha: 0.3) : context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isUploading)
              SizedBox(height: 24.sp, width: 24.sp, child: const CircularProgressIndicator(strokeWidth: 2))
            else
              Icon(icon, color: isUploaded ? AppTheme.primaryBlue : Colors.grey, size: 24.sp),
            const Spacer(),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
            SizedBox(height: 4.h),
            Text(isUploading ? 'Uploading...' : (isUploaded ? size : 'Tap to upload'), 
                 style: TextStyle(fontSize: 11.sp, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceScheduler(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(20.w),
      children: [
        _buildInfoCard(
          'Smart Maintenance',
          'We notify you when it\'s time for routine checks to keep your property value high.',
          LucideIcons.sparkles,
          Colors.orange,
        ),
        SizedBox(height: 24.h),
        _buildMaintenanceItem('AC Servicing', 'Next due: 15 June 2024', LucideIcons.snowflake, 'OVERDUE', Colors.red),
        _buildMaintenanceItem('Water Tank Cleaning', 'Next due: 22 July 2024', LucideIcons.droplets, 'UPCOMING', Colors.blue),
        _buildMaintenanceItem('Pest Control', 'Last done: 12 April 2024', LucideIcons.bug, 'COMPLETED', Colors.green),
        SizedBox(height: 32.h),
        Text('QUICK ACTIONS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.sp, letterSpacing: 1.2, color: Colors.grey)),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _buildQuickAction('Book Cleaning', LucideIcons.brush)),
            SizedBox(width: 16.w),
            Expanded(child: _buildQuickAction('Call Plumber', LucideIcons.wrench)),
          ],
        ),
      ],
    );
  }

  Widget _buildMaintenanceItem(String title, String subtitle, IconData icon, String status, Color statusColor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: statusColor, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(6.w)),
            child: Text(status, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16.w),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24.sp),
          SizedBox(height: 8.h),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20.w),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: color)),
                SizedBox(height: 4.h),
                Text(desc, style: TextStyle(fontSize: 12.sp, color: color.withValues(alpha: 0.8), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
