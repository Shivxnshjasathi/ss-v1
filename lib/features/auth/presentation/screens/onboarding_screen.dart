import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
              const SnackBar(content: Text('Location updated successfully!')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not fetch location. Please check permissions.')),
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


  Future<void> _onCompleteSetup() async {
    LoggerService.i('Tapped Complete Setup');
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      LoggerService.i('Form validation passed');
      setState(() { _isLoading = true; });
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
            createdAt: DateTime.now(),
          );
          await ref.read(userRepositoryProvider).saveUser(userModel);
          await LoggerService.setUserId(user.uid);
          if (mounted) RoutingUtils.navigateByRole(context, userModel.role);
        } else {
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Authentication Error'),
                content: const Text('No active user session found. Please try logging in again.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }
        }
      } catch (e, stackTrace) {
        LoggerService.e('CRITICAL ERROR saving profile', error: e, stack: stackTrace);
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error Saving Profile'),
              content: Text('Firebase Error: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isLoading = false; });
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
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        title: Text(l10n.completeProfile, style: TextStyle(color: context.primaryTextColor)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.welcomeToSampatti, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, color: context.primaryTextColor)),
              SizedBox(height: 8.h),
              Text(l10n.onboardingSubtitle, style: TextStyle(color: context.secondaryTextColor, fontSize: 14.sp)),
              SizedBox(height: 32.h),
              
              Text(l10n.fullName, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Rahul Sharma',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                  filled: true,
                  fillColor: context.cardColor,
                ),
                style: TextStyle(color: context.primaryTextColor),
                validator: (value) => value == null || value.isEmpty ? l10n.enterName : null,
              ),
              SizedBox(height: 24.h),

              Text(l10n.phoneNumber, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'e.g. +91 9876543210',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                  filled: true,
                  fillColor: context.cardColor,
                ),
                style: TextStyle(color: context.primaryTextColor),
              validator: (value) => value == null || value.isEmpty ? l10n.enterPhone : null,
              ),
              SizedBox(height: 24.h),
              
              Text(l10n.emailAddress, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 8.h),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'e.g. rahul@example.com',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                  filled: true,
                  fillColor: context.cardColor,
                ),
                style: TextStyle(color: context.primaryTextColor),
                validator: (value) => (value == null || value.isEmpty || !value.contains('@')) ? 'Please enter a valid email' : null,
              ),
              SizedBox(height: 24.h),
              
              Text(l10n.cityLocation, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Jabalpur',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                        filled: true,
                        fillColor: context.cardColor,
                      ),
                      style: TextStyle(color: context.primaryTextColor),
                      validator: (value) => value == null || value.isEmpty ? l10n.enterCity : null,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: _isFetchingLocation ? null : _fetchLocation,
                    icon: _isFetchingLocation 
                      ? SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.my_location, color: Color(0xFF1E60FF)),
                    tooltip: 'Fetch Current Location',
                  ),
                ],
              ),
              SizedBox(height: 24.h),

              Text(l10n.yourRole, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 8.h),
              DropdownButtonFormField<String>(
                initialValue: _selectedRoleKey,
                dropdownColor: context.cardColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.w), borderSide: BorderSide(color: context.borderColor)),
                  filled: true,
                  fillColor: context.cardColor,
                ),
                items: roles.map((role) => DropdownMenuItem(value: role['key'], child: Text(role['label']!, style: TextStyle(color: context.primaryTextColor)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() { _selectedRoleKey = val; });
                },
              ),
              SizedBox(height: 48.h),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onCompleteSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E60FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
                  ),
                  child: _isLoading 
                      ? SizedBox(width: 24.w, height: 24.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(l10n.completeSetup, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
