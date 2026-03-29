import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sampatti_bazar/core/theme/app_theme.dart';
import 'package:sampatti_bazar/features/auth/data/auth_repository.dart';
import 'package:sampatti_bazar/features/auth/data/user_repository.dart';
import 'package:sampatti_bazar/core/services/logger_service.dart';
import 'package:sampatti_bazar/l10n/app_localizations.dart';

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
            LoggerService.i('Profile found. Routing to /home');
            context.go('/home');
          }
        }
      } else {
        LoggerService.e('UserCredential user is null after verification');
      }
    } catch (e, stackTrace) {
      LoggerService.e('Error during OTP verification', error: e, stack: stackTrace);
      if (mounted) {
        setState(() { _isLoading = false; });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP or error occurred: $e')));
      }
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
          icon: Icon(Icons.chevron_left, color: context.iconColor, size: 32),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.verifyYour, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1, height: 1.1)),
                  ),
                   FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.number, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1, color: Color(0xFF1E60FF), height: 1.1)),
                  ),
                  const SizedBox(height: 16),
                  Text('${l10n.otpEntryHint}\n+91 ${widget.phoneNumber}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.primaryTextColor, height: 1.5)),
                  const SizedBox(height: 48),
                  
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
                          style: const TextStyle(color: Colors.transparent, fontSize: 1),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
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
                    const Padding(
                      padding: EdgeInsets.only(top: 24.0),
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF1E60FF))),
                    ),
                  
                  const SizedBox(height: 32),
                  
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: l10n.didntReceiveCode,
                        style: TextStyle(fontSize: 12, color: context.primaryTextColor.withValues(alpha: 0.6), fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: '${l10n.resendIn} 00:45', style: const TextStyle(color: Color(0xFF1E60FF), fontWeight: FontWeight.bold)),
                        ],
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
      width: 44, // Slightly smaller for better fit on narrow screens
      height: 56,
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
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: context.primaryTextColor),
      ),
    );
  }
}
