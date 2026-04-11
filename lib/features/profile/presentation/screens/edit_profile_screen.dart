import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserDataProvider).value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(currentUserDataProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      await ref.read(userRepositoryProvider).saveUser(updatedUser);
      
      if (mounted) {
        ref.invalidate(currentUserDataProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.profileUpdated), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        title: Text(l10n.personalInfo, style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.w900)),
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: context.iconColor),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                   Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.borderColor, width: 4.w),
                    ),
                    child: CircleAvatar(
                      radius: 54.w,
                      backgroundColor: context.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                      child: Text(
                        (_nameController.text.isNotEmpty ? _nameController.text : 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.w900,
                          color: context.isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 16.w),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40.h),
            _buildTextField(l10n.fullName, _nameController),
            SizedBox(height: 16.h),
            _buildTextField(l10n.emailAddress, _emailController, keyboardType: TextInputType.emailAddress),
            SizedBox(height: 16.h),
            _buildTextField(l10n.phoneNumber, _phoneController, keyboardType: TextInputType.phone),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
                ),
                child: _isLoading 
                  ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(l10n.saveChanges, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10.sp, color: context.secondaryTextColor, letterSpacing: 1)),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(color: context.borderColor),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: context.primaryTextColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            ),
          ),
        ),
      ],
    );
  }
}
