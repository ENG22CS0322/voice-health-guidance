import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> {
  int _countdown = 10;
  bool _sosActivated = false;

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0 && !_sosActivated) {
        setState(() => _countdown--);
        if (_countdown == 0) {
          setState(() => _sosActivated = true);
        } else {
          _startCountdown();
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD32F2F), // Emergency Red
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_sosActivated) ...[
                Pulse(
                  infinite: true,
                  child: const Icon(FontAwesomeIcons.truckMedical, color: Colors.white, size: 100),
                ),
                const SizedBox(height: 40),
                Text(
                  'SOS ALERT IN',
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '$_countdown',
                  style: GoogleFonts.outfit(fontSize: 120, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Locating you & Alerting Help...',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const Spacer(),
                FadeInUp(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red[900],
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text('CANCEL (I AM SAFE)'),
                  ),
                ),
              ] else ...[
                FadeInDown(
                  child: const Icon(Icons.check_circle, color: Colors.white, size: 100),
                ),
                const SizedBox(height: 30),
                Text(
                  'HELP IS ON THE WAY',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Calling National Ambulance (108)...',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 40),
                      const SizedBox(height: 10),
                      const Text(
                        'YOUR LOCATION DETECTED:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Rampur Village, Block A',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FadeInUp(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white24,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                    ),
                    child: const Text('BACK TO DASHBOARD'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
