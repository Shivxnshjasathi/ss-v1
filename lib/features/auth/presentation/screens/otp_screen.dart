import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/utils/routing_utils.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';
import 'package:sampatti_bazar/core/utils/responsive.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;
  const OtpScreen({super.key, required this.phoneNumber, required this.verificationId});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otpCode = '';
  bool _isLoading = false;
  int _timerSeconds = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() => timer.cancel());
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  Future<void> _onVerify() async {
    LoggerService.i('Triggered OTP verification for: ${widget.phoneNumber}');
    if (_otpCode.length < 6) return;
    
    setState(() { _isLoading = true; });
    try {
      final authRepo = ref.read(authRepositoryProvider);
      LoggerService.i('Attempting verifyOTP');
      final userCredential = await authRepo.verifyOTP(verificationId: widget.verificationId, smsCode: _otpCode);
      
      if (userCredential.user != null && mounted) {
        LoggerService.i('OTP Verified for UID: ${userCredential.user!.uid}');
        // Check if user exists in Firestore
        final userRepo = ref.read(userRepositoryProvider);
        LoggerService.i('Checking for existing user profile');
        final userDoc = await userRepo.getUser(userCredential.user!.uid);
        
        if (mounted) {
          if (userDoc == null || userDoc.name == null || userDoc.name!.isEmpty) {
            LoggerService.i('No profile found. Routing to /onboarding');
            context.go('/onboarding');
          } else {
            LoggerService.i('Profile found. Navigating based on role');
            RoutingUtils.navigateByRole(context, userDoc.role);
          }
        }
      }
    } catch (e, stackTrace) {
      LoggerService.e('Error during OTP verification', error: e, stack: stackTrace);
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP or error occurred: $e')));
      }
    }
  }

  Future<void> _onResend() async {
    if (_timerSeconds > 0) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).verifyPhoneNumber(
        phoneNumber: '+91${widget.phoneNumber}',
        verificationCompleted: (cred) async {
           await FirebaseAuth.instance.signInWithCredential(cred);
        },
        verificationFailed: (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Resend failed')));
          }
        },
        codeSent: (verificationId) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP Resent Successfully')));
            _startTimer();
          }
        },
        codeAutoRetrievalTimeout: (id) {},
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        backgroundColor: context.scaffoldColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: context.iconColor, size: 32.w),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 16.0.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.verifyYour, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32.sp, letterSpacing: -1, height: 1.1.h)),
                  ),
                   FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.number, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32.sp, letterSpacing: -1, color: AppTheme.primaryBlue, height: 1.1.h)),
                  ),
                  SizedBox(height: 16.h),
                  Text('${l10n.otpEntryHint}\n+91 ${widget.phoneNumber}', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: context.primaryTextColor, height: 1.5.h)),
                  SizedBox(height: 48.h),
                  
                  // Custom OTP Boxes
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (index) => _buildOtpBox(index)),
                      ),
                      Positioned.fill(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          autofocus: true,
                          cursorColor: Colors.transparent,
                          enabled: !_isLoading,
                          style: TextStyle(color: Colors.transparent, fontSize: 1.sp),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            counterText: '',
                            fillColor: Colors.transparent,
                            filled: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _otpCode = value;
                            });
                            if (value.length == 6) {
                              Future.delayed(const Duration(milliseconds: 300), _onVerify);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  if (_isLoading)
                    Padding(
                      padding: EdgeInsets.only(top: 24.0.h),
                      child: Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
                    ),
                  
                  SizedBox(height: 32.h),
                  
                  Center(
                    child: GestureDetector(
                      onTap: _timerSeconds == 0 ? _onResend : null,
                      child: Text.rich(
                        TextSpan(
                          text: l10n.didntReceiveCode,
                          style: TextStyle(fontSize: 12.sp, color: context.primaryTextColor.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: _timerSeconds > 0 
                                ? ' ${l10n.resendIn} 00:${_timerSeconds.toString().padLeft(2, '0')}'
                                : ' ${l10n.resendOTP}', 
                              style: TextStyle(
                                color: _timerSeconds > 0 ? Colors.grey : AppTheme.primaryBlue, 
                                fontWeight: FontWeight.bold
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    bool hasValue = index < _otpCode.length;
    bool isActive = index == _otpCode.length;
    String digit = hasValue ? _otpCode[index] : '';

    return Container(
      width: 44.w, 
      height: 56.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.scaffoldColor,
        border: Border(
           bottom: BorderSide(
             color: isActive ? AppTheme.primaryBlue : (hasValue ? context.primaryTextColor : context.borderColor),
             width: isActive ? 3 : 2,
           ),
        ),
      ),
      child: Text(
        digit,
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32.sp, color: context.primaryTextColor),
      ),
    );
  }
}
