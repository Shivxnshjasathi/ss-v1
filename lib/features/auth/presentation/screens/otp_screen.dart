import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _otpCode = '';



  void _onVerify() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 32),
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
                  const Text('VERIFY YOUR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1, color: Colors.black, height: 1.1)),
                  const Text('NUMBER', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1, color: Color(0xFF1E60FF), height: 1.1)),
                  const SizedBox(height: 16),
                  Text('Enter the 6-digit code sent to\n+91 ${widget.phoneNumber}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87, height: 1.5)),
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
                  
                  const SizedBox(height: 32),
                  
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: 'Didn\'t receive code? ',
                        style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.bold),
                        children: const [
                          TextSpan(text: 'Resend in 00:45', style: TextStyle(color: Color(0xFF1E60FF), fontWeight: FontWeight.bold)),
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
      width: 48,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
           bottom: BorderSide(
             color: isActive ? const Color(0xFF1E60FF) : (hasValue ? Colors.black : Colors.grey.shade300),
             width: isActive ? 3 : 2,
           ),
        ),
      ),
      child: Text(
        digit,
        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 32, color: Colors.black),
      ),
    );
  }
}
