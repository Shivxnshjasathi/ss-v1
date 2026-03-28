import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/features/auth/domain/user_model.dart';
import 'package:sampatti_bazar/core/services/location_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String _selectedRole = 'Buyer / Tenant';
  bool _isLoading = false;
  bool _isFetchingLocation = false;

  final List<String> _roles = ['Buyer / Tenant', 'Owner / Landlord', 'Real Estate Agent', 'Builder'];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
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
    debugPrint('👆 [OnboardingScreen] Tapped Complete Setup');
    if (_formKey.currentState!.validate()) {
      debugPrint('✅ [OnboardingScreen] Form validation passed');
      setState(() { _isLoading = true; });
      try {
        final user = ref.read(authRepositoryProvider).currentUser;
        debugPrint('👤 [OnboardingScreen] Current user UID: ${user?.uid}');
        
        if (user != null) {
          debugPrint('💾 [OnboardingScreen] Attempting to save user profile...');
          final userModel = UserModel(
            uid: user.uid,
            phoneNumber: user.phoneNumber ?? '',
            name: _nameController.text.trim(),
            location: _locationController.text.trim(),
            role: _selectedRole,
            createdAt: DateTime.now(),
          );
          await ref.read(userRepositoryProvider).saveUser(userModel);
          debugPrint('🚀 [OnboardingScreen] Profile saved successfully! Navigating to /home');
          if (mounted) context.go('/home');
        } else {
          debugPrint('❌ [OnboardingScreen] Current user is NULL. Showing auth dialog.');
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
        debugPrint('💥 [OnboardingScreen] CRITICAL ERROR catching exception: $e');
        debugPrint('🥞 [OnboardingScreen] StackTrace: $stackTrace');
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Error Saving Profile'),
              content: Text('Wait! Firebase Error details:\n\n$e'),
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
        debugPrint('🏁 [OnboardingScreen] Finally block - resetting loading state');
        if (mounted) {
          setState(() { _isLoading = false; });
        }
      }
    } else {
      debugPrint('⚠️ [OnboardingScreen] Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      appBar: AppBar(
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        title: Text('Complete Your Profile', style: TextStyle(color: context.primaryTextColor)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome to Sampatti Bazar!', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: context.primaryTextColor)),
              const SizedBox(height: 8),
              Text('Tell us a bit about yourself to personalize your experience.', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 32),
              
              const Text('FULL NAME', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g. Rahul Sharma',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
                  filled: true,
                  fillColor: context.cardColor,
                ),
                style: TextStyle(color: context.primaryTextColor),
                validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 24),
              
              const Text('CITY / LOCATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: 'e.g. Jabalpur',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
                        filled: true,
                        fillColor: context.cardColor,
                      ),
                      style: TextStyle(color: context.primaryTextColor),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter your city' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isFetchingLocation ? null : _fetchLocation,
                    icon: _isFetchingLocation 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, color: Color(0xFF1E60FF)),
                    tooltip: 'Fetch Current Location',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text('YOUR ROLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                dropdownColor: context.cardColor,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: context.borderColor)),
                  filled: true,
                  fillColor: context.cardColor,
                ),
                items: _roles.map((run) => DropdownMenuItem(value: run, child: Text(run, style: TextStyle(color: context.primaryTextColor)))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() { _selectedRole = val; });
                },
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _onCompleteSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E60FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Complete Setup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
