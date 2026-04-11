import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/utils/routing_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isEmailLogin = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onGetOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length >= 10) {
      setState(() { _isLoading = true; });
      LoggerService.i('Attempting OTP verification for: +91$phone');
      try {
        await ref.read(authRepositoryProvider).verifyPhoneNumber(
          phoneNumber: '+91$phone',
          verificationCompleted: (credential) async {
            LoggerService.i('Auto-verification completed for: +91$phone');
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (mounted) {
              final userRepo = ref.read(userRepositoryProvider);
              final profile = await userRepo.getUser(FirebaseAuth.instance.currentUser!.uid);
              if (mounted) {
                if (profile == null) {
                  context.go('/onboarding');
                } else {
                  RoutingUtils.navigateByRole(context, profile.role);
                }
              }
            }
          },
          verificationFailed: (e) {
            LoggerService.e('Phone verification failed', error: e, stack: StackTrace.current);
            if (mounted) {
              setState(() { _isLoading = false; });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Verification failed')));
            }
          },
          codeSent: (verificationId) {
            if (mounted) {
              LoggerService.i('OTP code sent to: +91$phone');
              setState(() { _isLoading = false; });
              context.push('/otp', extra: {'phoneNumber': phone, 'verificationId': verificationId});
            }
          },
          codeAutoRetrievalTimeout: (verificationId) {},
        );
      } catch (e) {
        LoggerService.e('Error during phone authentication', error: e, stack: StackTrace.current);
        if (mounted) {
          setState(() { _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  void _onEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter email and password')));
      return;
    }
    
    LoggerService.i('Attempting email login for: $email');
    try {
      final authRepo = ref.read(authRepositoryProvider);
      try {
        await authRepo.signInWithEmailAndPassword(email, password);
        LoggerService.i('Email login successful for: $email');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'invalid-email') {
          try {
            await authRepo.createUserWithEmailAndPassword(email, password);
          } on FirebaseAuthException catch (regErr) {
            if (regErr.code == 'email-already-in-use') {
               throw Exception('Incorrect password for this email.');
            } else {
               throw Exception(regErr.message ?? 'Registration failed.');
            }
          }
        } else {
          rethrow;
        }
      }
      
      final userRepo = ref.read(userRepositoryProvider);
      final profile = await userRepo.getUser(FirebaseAuth.instance.currentUser!.uid);
      if (mounted) {
        if (profile == null) {
          context.go('/onboarding');
        } else {
          RoutingUtils.navigateByRole(context, profile.role);
        }
      }
    } catch (e) {
      LoggerService.e('Error during email authentication', error: e, stack: StackTrace.current);
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 32.0.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E60FF),
                          borderRadius: BorderRadius.circular(12.w),
                        ),
                        child: Icon(Icons.home_outlined, color: Colors.white, size: 32.w),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(l10n.welcomeTo, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32.sp, letterSpacing: -1, height: 1.1.h)),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(l10n.sampattiBazar, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32.sp, letterSpacing: -1, color: Color(0xFF1E60FF), height: 1.1.h)),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _isEmailLogin ? l10n.emailLoginHint : l10n.phoneLoginHint, 
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: context.primaryTextColor)
                    ),
                    SizedBox(height: 32.h),
                    
                    if (!_isEmailLogin) ...[
                      Text(l10n.mobileNumber, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                      SizedBox(height: 12.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('+91', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, color: context.primaryTextColor)),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              cursorColor: const Color(0xFF1E60FF),
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, color: context.primaryTextColor, letterSpacing: 2.0),
                              decoration: InputDecoration(
                                hintText: '00000 00000',
                                hintStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 24.sp, color: context.secondaryTextColor.withValues(alpha: 0.3), letterSpacing: 2.0),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(height: 2.h, color: context.primaryTextColor, margin: EdgeInsets.only(top: 8.h)),
                    ] else ...[
                      Text(l10n.emailAddress, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: const Color(0xFF1E60FF),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: context.primaryTextColor),
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          hintStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: context.secondaryTextColor.withValues(alpha: 0.3)),
                          border: const UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryTextColor, width: 2.w)),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(l10n.password, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        cursorColor: const Color(0xFF1E60FF),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: context.primaryTextColor),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: context.secondaryTextColor.withValues(alpha: 0.3)),
                          border: const UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryTextColor, width: 2.w)),
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isEmailLogin ? _onEmailLogin : _onGetOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E60FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.w)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                            ? SizedBox(width: 24.w, height: 24.h, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isEmailLogin ? l10n.continueText : l10n.getOtp, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16.sp)),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isEmailLogin = !_isEmailLogin;
                          });
                        },
                        child: Text(
                          _isEmailLogin ? l10n.usePhone : l10n.useEmail,
                          style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: '${l10n.agreementText}\n',
                          style: TextStyle(fontSize: 10.sp, color: context.primaryTextColor.withValues(alpha: 0.7)),
                          children: [
                            TextSpan(text: l10n.termsOfService, style: TextStyle(color: context.primaryTextColor, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' & '),
                            TextSpan(text: l10n.privacyPolicy, style: TextStyle(color: context.primaryTextColor, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
