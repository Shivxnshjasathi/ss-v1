import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';
import 'package:sampatti_bazar/core/utils/routing_utils.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/shared/widgets/primary_button.dart';

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
      setState(() {
        _isLoading = true;
      });
      LoggerService.i('Attempting OTP verification for: +91$phone');
      try {
        await ref
            .read(authRepositoryProvider)
            .verifyPhoneNumber(
              phoneNumber: '+91$phone',
              verificationCompleted: (credential) async {
                LoggerService.i('Auto-verification completed for: +91$phone');
                await FirebaseAuth.instance.signInWithCredential(credential);
                if (mounted) {
                  final userRepo = ref.read(userRepositoryProvider);
                  final profile = await userRepo.getUser(
                    FirebaseAuth.instance.currentUser!.uid,
                  );
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
                LoggerService.e(
                  'Phone verification failed',
                  error: e,
                  stack: StackTrace.current,
                );
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.message ?? 'Verification failed')),
                  );
                }
              },
              codeSent: (verificationId) {
                if (mounted) {
                  LoggerService.i('OTP code sent to: +91$phone');
                  setState(() {
                    _isLoading = false;
                  });
                  context.push(
                    '/otp',
                    extra: {
                      'phoneNumber': phone,
                      'verificationId': verificationId,
                    },
                  );
                }
              },
              codeAutoRetrievalTimeout: (verificationId) {},
            );
      } catch (e) {
        LoggerService.e(
          'Error during phone authentication',
          error: e,
          stack: StackTrace.current,
        );
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  void _onEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    LoggerService.i('Attempting email login for: $email');
    try {
      final authRepo = ref.read(authRepositoryProvider);
      try {
        await authRepo.signInWithEmailAndPassword(email, password);
        LoggerService.i('Email login successful for: $email');
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-credential' ||
            e.code == 'invalid-email') {
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
      final profile = await userRepo.getUser(
        FirebaseAuth.instance.currentUser!.uid,
      );
      if (mounted) {
        if (profile == null) {
          context.go('/onboarding');
        } else {
          RoutingUtils.navigateByRole(context, profile.role);
        }
      }
    } catch (e) {
      LoggerService.e(
        'Error during email authentication',
        error: e,
        stack: StackTrace.current,
      );
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
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
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          borderRadius: BorderRadius.circular(16.w),
                        ),
                        child: Icon(
                          LucideIcons.house,
                          color: Colors.white,
                          size: 32.w,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      l10n.welcomeTo,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      l10n.sampattiBazar,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBlue,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      _isEmailLogin ? l10n.emailLoginHint : 'Enter your phone number to get started',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    if (!_isEmailLogin) ...[
                      Text(
                        l10n.mobileNumber.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '+91',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w900,
                              fontSize: 20.sp,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              cursorColor: AppTheme.primaryBlue,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w900,
                                fontSize: 20.sp,
                                color: Colors.blue.shade900,
                                letterSpacing: 2.0,
                              ),
                              decoration: InputDecoration(
                                hintText: '00000 00000',
                                hintStyle: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 20.sp,
                                  color: Colors.grey.shade100,
                                  letterSpacing: 2.0,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                filled: false,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 2.h,
                        color: Colors.black87,
                        margin: EdgeInsets.only(top: 8.h),
                      ),
                    ] else ...[
                      // Flat style for Email Login fields
                      Text(
                        l10n.emailAddress.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.h)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.h)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2.h)),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                          filled: false,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        l10n.password.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey.shade600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16.sp),
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.h)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2.h)),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2.h)),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                          filled: false,
                        ),
                      ),
                    ],

                    SizedBox(height: 48.h),
                    PrimaryButton(
                      text: _isEmailLogin ? l10n.continueText : l10n.getOtp,
                      isLoading: _isLoading,
                      onPressed: _isEmailLogin ? _onEmailLogin : _onGetOtp,
                    ),

                    SizedBox(height: 16.h),
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEmailLogin = !_isEmailLogin;
                            _isLoading = false;
                          });
                        },
                        icon: Icon(
                          _isEmailLogin ? LucideIcons.phone : LucideIcons.mail,
                          size: 14.w,
                          color: Colors.grey.shade700,
                        ),
                        label: Text(
                          _isEmailLogin ? l10n.usePhone : l10n.useEmail,
                          style: TextStyle(fontWeight: FontWeight.w800, color: Colors.grey.shade700, fontSize: 12.sp),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: '${l10n.agreementText}\n',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10.sp,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: l10n.termsOfService,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            const TextSpan(text: ' & '),
                            TextSpan(
                              text: l10n.privacyPolicy,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline,
                              ),
                            ),
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
