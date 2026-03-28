import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';

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
            if (mounted) context.go('/home');
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
          context.go('/home');
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
    return Scaffold(
      backgroundColor: context.scaffoldColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E60FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.home_outlined, color: Colors.white, size: 32),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('WELCOME TO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1, height: 1.1)),
                    ),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text('SAMPATTI\nBAZAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1, color: Color(0xFF1E60FF), height: 1.1)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isEmailLogin ? 'Enter your email to continue' : 'Enter your phone number to get started', 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.primaryTextColor)
                    ),
                    const SizedBox(height: 32),
                    
                    if (!_isEmailLogin) ...[
                      const Text('MOBILE NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('+91', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: context.primaryTextColor)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              cursorColor: const Color(0xFF1E60FF),
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: context.primaryTextColor, letterSpacing: 2.0),
                              decoration: InputDecoration(
                                hintText: '00000 00000',
                                hintStyle: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.grey.shade300, letterSpacing: 2.0),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(height: 2, color: context.primaryTextColor, margin: const EdgeInsets.only(top: 8)),
                    ] else ...[
                      const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: const Color(0xFF1E60FF),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: context.primaryTextColor),
                        decoration: InputDecoration(
                          hintText: 'you@example.com',
                          hintStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.grey.shade300),
                          border: const UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryTextColor, width: 2)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('PASSWORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        cursorColor: const Color(0xFF1E60FF),
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: context.primaryTextColor),
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          hintStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.grey.shade300),
                          border: const UnderlineInputBorder(),
                          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: context.primaryTextColor, width: 2)),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : (_isEmailLogin ? _onEmailLogin : _onGetOtp),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E60FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: _isLoading 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(_isEmailLogin ? 'Continue' : 'Get OTP', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _isEmailLogin = !_isEmailLogin;
                          });
                        },
                        child: Text(
                          _isEmailLogin ? 'Use Phone Number instead' : 'Continue with Email instead',
                          style: TextStyle(color: context.primaryTextColor, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'By continuing, you agree to our\n',
                          style: TextStyle(fontSize: 10, color: context.primaryTextColor.withValues(alpha: 0.7)),
                          children: [
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: context.primaryTextColor, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                            const TextSpan(text: ' & '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(color: context.primaryTextColor, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
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
