import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/auth/domain/user_model.dart';
import 'package:sampatti_bazar/core/utils/routing_utils.dart';
import 'package:sampatti_bazar/core/services/location_service.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedRoleKey;
  File? _imageFile;
  String? _networkImageUrl;
  bool _isLoading = false;
  bool _isFetchingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authRepositoryProvider).currentUser;
      if (user?.phoneNumber != null && user!.phoneNumber!.isNotEmpty) {
        _phoneController.text = user.phoneNumber!;
      }
      if (user?.email != null && user!.email!.isNotEmpty) {
        _emailController.text = user.email!;
      }
      if (user?.displayName != null && user!.displayName!.isNotEmpty) {
        _nameController.text = user.displayName!;
      }
      if (user?.photoURL != null && user!.photoURL!.isNotEmpty) {
        setState(() {
          _networkImageUrl = user.photoURL!;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final position = await LocationService.getCurrentPosition();
      if (position != null) {
        final addressData = await LocationService.getAddressFromLatLng(position);
        if (addressData != null) {
          setState(() {
            _locationController.text = addressData['city'] ?? '';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context)!.locationUpdated)),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.couldNotFetchLocation),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  Future<void> _onCompleteSetup() async {
    LoggerService.i('Tapped Complete Setup');
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      LoggerService.i('Form validation passed');
      setState(() {
        _isLoading = true;
      });
      try {
        final user = ref.read(authRepositoryProvider).currentUser;

        if (user != null) {
          final roleMap = {
            'consumerBuyer': l10n.consumerBuyer,
            'builderAgent': l10n.builderAgent,
            'constructionPartner': l10n.constructionPartner,
            'legalAdvisor': l10n.legalAdvisor,
            'materialVendor': l10n.materialVendor,
            'loanExpert': l10n.loanExpert,
          };

          String? imageUrl = _networkImageUrl;
          final userRepo = ref.read(userRepositoryProvider);
          if (_imageFile != null) {
            imageUrl = await userRepo.uploadProfileImage(_imageFile!, user.uid);
          }

          final userModel = UserModel(
            uid: user.uid,
            phoneNumber: _phoneController.text.trim().isNotEmpty
                ? _phoneController.text.trim()
                : (user.phoneNumber ?? ''),
            email: _emailController.text.trim().isNotEmpty
                ? _emailController.text.trim()
                : (user.email ?? ''),
            name: _nameController.text.trim(),
            location: _locationController.text.trim(),
            role: roleMap[_selectedRoleKey ?? 'consumerBuyer']!,
            profileImageUrl: imageUrl,
            createdAt: DateTime.now(),
          );
          await userRepo.saveUser(userModel);
          await LoggerService.setUserId(user.uid);
          if (mounted) RoutingUtils.navigateByRole(context, userModel.role);
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.authError),
                content: Text(l10n.noActiveSession),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/');
                    },
                    child: Text(l10n.goToLogin),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e, stackTrace) {
        LoggerService.e(
          'CRITICAL ERROR saving profile',
          error: e,
          stack: stackTrace,
        );
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.errorSavingProfile),
              content: Text('Firebase Error: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.close),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _selectedRoleKey ??= 'consumerBuyer';

    final roles = [
      {'key': 'consumerBuyer', 'label': l10n.consumerBuyer},
      {'key': 'builderAgent', 'label': l10n.builderAgent},
      {'key': 'constructionPartner', 'label': l10n.constructionPartner},
      {'key': 'legalAdvisor', 'label': l10n.legalAdvisor},
      {'key': 'materialVendor', 'label': l10n.materialVendor},
      {'key': 'loanExpert', 'label': l10n.loanExpert},
      {'key': 'packersMovers', 'label': l10n.packersMoversRole},
    ];

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 120.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeToSampatti,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 32.sp,
                    color: context.primaryTextColor,
                    fontFamily: 'Poppins',
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  l10n.onboardingSubtitle,
                  style: TextStyle(
                    color: context.secondaryTextColor.withValues(alpha: 0.7),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32.h),
                
                // Profile Image Picker
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: context.borderColor, width: 4.w),
                          ),
                          child: CircleAvatar(
                            radius: 54.w,
                            backgroundColor: context.surfaceColor,
                            backgroundImage: _imageFile != null 
                                ? FileImage(_imageFile!) as ImageProvider
                                : (_networkImageUrl != null ? NetworkImage(_networkImageUrl!) : null),
                            child: (_imageFile == null && _networkImageUrl == null)
                                ? Icon(Icons.person, size: 54.w, color: context.secondaryTextColor.withValues(alpha: 0.3))
                                : null,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 16.w),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                _buildTextField(
                  l10n.fullName,
                  l10n.namePlaceholder,
                  TextInputType.name,
                  controller: _nameController,
                  validator: (value) =>
                      value == null || value.isEmpty ? l10n.enterName : null,
                ),
                SizedBox(height: 24.h),

                _buildTextField(
                  l10n.phoneNumber,
                  l10n.phonePlaceholder,
                  TextInputType.phone,
                  controller: _phoneController,
                  validator: (value) =>
                      value == null || value.isEmpty ? l10n.enterPhone : null,
                ),
                SizedBox(height: 24.h),

                _buildTextField(
                  l10n.emailAddress,
                  l10n.emailPlaceholder,
                  TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) =>
                      (value == null || value.isEmpty || !value.contains('@'))
                          ? l10n.enterValidEmail
                          : null,
                ),
                SizedBox(height: 24.h),

                _buildLocationField(l10n.cityLocation, _locationController, l10n),
                SizedBox(height: 24.h),

                _buildSelectionBox(
                  l10n.yourRole,
                  roles.firstWhere((r) => r['key'] == _selectedRoleKey)['label']!,
                  roles.map((r) => r['label']!).toList(),
                  (val) {
                    final key = roles.firstWhere((r) => r['label'] == val)['key'];
                    setState(() => _selectedRoleKey = key);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
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
          child: SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onCompleteSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.sp),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      l10n.completeSetup.toUpperCase(),
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

  Widget _buildTextField(
    String labelText,
    String hintText,
    TextInputType type, {
    int maxLines = 1,
    TextEditingController? controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText.isNotEmpty)
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
        if (labelText.isNotEmpty) SizedBox(height: 10.h),
        Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(16.sp),
            border: Border.all(color: context.borderColor),
          ),
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: type,
            validator: validator,
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

  Widget _buildLocationField(
      String label, TextEditingController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 10.sp,
                color: AppTheme.primaryBlue,
                letterSpacing: 1.5,
                fontFamily: 'Poppins',
              ),
            ),
            TextButton.icon(
              onPressed: _isFetchingLocation ? null : _fetchLocation,
              icon: _isFetchingLocation
                  ? SizedBox(
                      height: 14.sp,
                      width: 14.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryBlue,
                      ),
                    )
                  : Icon(Icons.my_location, size: 16.sp, color: AppTheme.primaryBlue),
              label: Text(
                l10n.useLiveLocation,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primaryBlue,
                  letterSpacing: 1.0,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.sp),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        _buildTextField(
          '',
          l10n.cityPlaceholder,
          TextInputType.text,
          controller: controller,
          validator: (val) => val == null || val.isEmpty ? l10n.enterCity : null,
        ),
      ],
    );
  }

  Widget _buildSelectionBox(
    String label,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 10.sp,
            color: AppTheme.primaryBlue,
            letterSpacing: 1.5,
            fontFamily: 'Poppins',
          ),
        ),
        SizedBox(height: 10.h),
        GestureDetector(
          onTap: () => _showSelectionMenu(label, options, value, onChanged),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16.sp),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: context.primaryTextColor,
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.primaryBlue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSelectionMenu(String title, List<String> options,
      String currentValue, Function(String) onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                    fontFamily: 'Poppins')),
            SizedBox(height: 16.h),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == currentValue;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontFamily: 'Poppins',
                        color: isSelected
                            ? AppTheme.primaryBlue
                            : context.primaryTextColor,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: AppTheme.primaryBlue)
                        : null,
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
