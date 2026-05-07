import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/auth_provider.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  String? _errorMessage;

  void _handleVerify() async {
    final phone = ModalRoute.of(context)!.settings.arguments as String;
    final otp = _otpController.text.trim();
    final auth = Provider.of<AuthProvider>(context, listen: false);

    bool result = await auth.verifyOTP(phone, otp);

    if (result) {
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } else {
      String correctOtp = phone == '9999999999' ? '654321' : '123456';
      setState(() => _errorMessage = 'Invalid OTP. Try $correctOtp.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('OTP VERIFICATION', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            FadeInDown(
              child: const Icon(Icons.security, size: 80, color: Color(0xFF00796B)),
            ),
            const SizedBox(height: 20),
            FadeInDown(
              child: Text(
                'Enter Verification Code',
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            FadeInDown(
              child: Text(
                'Verification SMS was sent to\n+91 $phone',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            FadeInRight(
              child: TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                autofocus: true,
                style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 10),
                decoration: InputDecoration(
                  hintText: '000000',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  errorText: _errorMessage,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              child: ElevatedButton(
                onPressed: _handleVerify,
                child: const Text('VERIFY NOW'),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Didn\'t receive code? '),
                  TextButton(
                    onPressed: () {}, // Resend OTP logic placeholder
                    child: const Text('RESEND SMS', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00796B))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FadeIn(
              child: Text(
                'HINT: Use Demo OTP (${phone == '9999999999' ? '654321' : '123456'})',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
