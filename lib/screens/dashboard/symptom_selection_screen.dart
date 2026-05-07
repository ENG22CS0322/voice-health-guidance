import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/guidance_provider.dart';

class SymptomSelectionScreen extends StatelessWidget {
  const SymptomSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> symptoms = [
      {'name': 'Fever', 'icon': Icons.thermostat, 'color': Colors.red},
      {'name': 'Snake Bite', 'icon': Icons.dangerous, 'color': Colors.black},
      {'name': 'Stomach Pain', 'icon': Icons.sick, 'color': Colors.orange},
      {'name': 'Dehydration', 'icon': Icons.water_drop, 'color': Colors.blue},
      {'name': 'Cough/Cold', 'icon': Icons.coronavirus, 'color': Colors.teal},
      {'name': 'Headache', 'icon': Icons.headset_off, 'color': Colors.indigo},
    ];

    void _getGuidance(String symptom) {
      final gp = Provider.of<GuidanceProvider>(context, listen: false);
      gp.fetchGuidance(symptom);
      Navigator.pushNamed(context, '/guidance');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Symptom Checker', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            FadeInDown(
              child: Text(
                'Select your concern:',
                style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            FadeInDown(
              child: Text(
                'Our offline guide will provide immediate action steps.',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 40),
            ListView.separated(
              itemCount: symptoms.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final s = symptoms[index];
                return FadeInLeft(
                  delay: Duration(milliseconds: 100 * index),
                  child: InkWell(
                    onTap: () => _getGuidance(s['name']),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: s['color'].withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(s['icon'], color: s['color'], size: 30),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Text(
                              s['name'],
                              style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
