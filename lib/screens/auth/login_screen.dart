import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String? _errorMessage;

  void _handleLogin() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 10) {
      setState(() => _errorMessage = 'Enter a valid 10-digit number.');
      return;
    }

    if (auth.checkPhone(phone)) {
      Navigator.pushNamed(context, '/otp', arguments: phone);
    } else {
      setState(() => _errorMessage = 'Number not found. Please register.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('LOGIN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          children: [
            FadeInDown(
              child: const Icon(Icons.person_pin, size: 80, color: Color(0xFF00695C)),
            ),
            const SizedBox(height: 20),
            FadeInDown(
              child: Text(
                'Welcome Back',
                style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
              ),
            ),
            const SizedBox(height: 10),
            FadeInDown(
              child: Text(
                'Enter your regular mobile number to continue.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            FadeInLeft(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  errorText: _errorMessage,
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              child: ElevatedButton(
                onPressed: _handleLogin,
                child: const Text('SEND OTP'),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Don\'t have an account? REGISTER NOW', style: TextStyle(color: Color(0xFF00796B), fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            FadeIn(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueGrey[200]!),
                ),
                child: Column(
                  children: [
                    const Text('DEMO NUMBERS FOR ACADEMIC TESTING:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 5),
                    const Text('9999999999 (Rajesh)', style: TextStyle(fontSize: 14)),
                    const Text('8888888888 (Sunita)', style: TextStyle(fontSize: 14)),
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
