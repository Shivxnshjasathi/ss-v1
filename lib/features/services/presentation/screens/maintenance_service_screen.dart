import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/widgets/contact_bottom_sheet.dart';

class MaintenanceServiceScreen extends ConsumerStatefulWidget {
  const MaintenanceServiceScreen({super.key});

  @override
  ConsumerState<MaintenanceServiceScreen> createState() => _MaintenanceServiceScreenState();
}

class _MaintenanceServiceScreenState extends ConsumerState<MaintenanceServiceScreen> {
  String _selectedType = 'AC Servicing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        title: Text(
          'Property Maintenance',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: context.primaryTextColor,
            fontSize: 24.sp,
            fontFamily: 'Poppins',
          ),
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
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeSelector(),
            SizedBox(height: 24.h),
            _buildSectionHeader(
              'Schedule Service',
              'Book professional maintenance experts for your home with verified quality control.',
            ),
            SizedBox(height: 24.h),
            _buildTextField('Specific Requirements', 'e.g., Leaking tap, AC not cooling', TextInputType.text),
            SizedBox(height: 16.h),
            _buildTextField('Service Address', 'e.g., Flat 402, Green Apartments', TextInputType.streetAddress),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildTextField('Preferred Date', 'e.g., 25th May', TextInputType.datetime)),
                SizedBox(width: 16.w),
                Expanded(child: _buildTextField('Time Slot', 'e.g., 10 AM - 1 PM', TextInputType.text)),
              ],
            ),
            SizedBox(height: 48.h),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Our expert will contact you shortly!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
                elevation: 0,
              ),
              child: Text(
                'SCHEDULE MAINTENANCE',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.sp, letterSpacing: 1.2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      'AC Servicing',
      'Electrical',
      'Plumbing',
      'Painting',
      'Deep Cleaning',
      'Carpentry',
      'Pest Control',
      'Gardening',
      'CCTV & Security',
      'Lift Maintenance',
      'Fire Safety',
      'Water Tank',
      'General Repairs',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT SERVICE TYPE',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11.sp, color: context.secondaryTextColor, letterSpacing: 1),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: types.map((type) {
              final isSelected = _selectedType == type;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: ChoiceChip(
                  label: Text(type.toUpperCase()),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedType = type),
                  selectedColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? AppTheme.primaryBlue : context.primaryTextColor,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    fontSize: 10.sp,
                    letterSpacing: 0.5,
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
        if (subtitle.isNotEmpty) ...[
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
        ),
      ],
    );
  }

}
