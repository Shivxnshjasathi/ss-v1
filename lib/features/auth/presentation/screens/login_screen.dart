import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onGetOtp() {
    if (_phoneController.text.length >= 10) {
      context.push('/otp', extra: _phoneController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                    const Text('WELCOME TO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1, color: Colors.black, height: 1.1)),
                    const Text('SAMPATTI\nBAZAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1, color: Color(0xFF1E60FF), height: 1.1)),
                    const SizedBox(height: 16),
                    const Text('Enter your phone number to get started', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                    const SizedBox(height: 32),
                    const Text('MOBILE NUMBER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text('+91', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.black)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _phoneController,
                            readOnly: false,
                            keyboardType: TextInputType.phone,
                            showCursor: true,
                            cursorColor: const Color(0xFF1E60FF),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Colors.black, letterSpacing: 2.0),
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
                    Container(
                      height: 2,
                      color: Colors.black,
                      margin: const EdgeInsets.only(top: 8),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onGetOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E60FF),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Get OTP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'By continuing, you agree to our\n',
                          style: const TextStyle(fontSize: 10, color: Colors.black54),
                          children: const [
                            TextSpan(text: 'Terms of Service', style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
                            TextSpan(text: ' & '),
                            TextSpan(text: 'Privacy Policy', style: TextStyle(color: Colors.black, decoration: TextDecoration.underline, fontWeight: FontWeight.bold)),
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
