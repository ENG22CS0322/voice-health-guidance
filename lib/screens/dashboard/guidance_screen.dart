import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/guidance_provider.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = Provider.of<GuidanceProvider>(context);
    final guidance = gp.currentGuidance;

    if (guidance == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light medical green
      appBar: AppBar(
        title: Text('Healthcare Guidance', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FadeInDown(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.teal.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info, color: Colors.teal, size: 30),
                        const SizedBox(width: 15),
                        Text(
                          guidance.emergencyGuidance.title,
                          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal[800]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ...guidance.emergencyGuidance.points.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(p, style: const TextStyle(fontSize: 16)),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInLeft(
              child: _buildGuidanceCard(
                context,
                title: guidance.immediateSteps.title,
                points: guidance.immediateSteps.points,
                icon: Icons.checklist,
                color: Colors.blue[800]!,
              ),
            ),
            const SizedBox(height: 20),
            FadeInRight(
              child: _buildGuidanceCard(
                context,
                title: guidance.whenToCall.title,
                points: guidance.whenToCall.points,
                icon: Icons.emergency,
                color: Colors.red[800]!,
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      guidance.importantNote.title,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 10),
                    ...guidance.importantNote.points.map((p) => Text(
                      p,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            FadeInUp(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00796B), foregroundColor: Colors.white),
                child: const Text('BACK TO DASHBOARD'),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidanceCard(BuildContext context, {required String title, required List<String> points, required IconData icon, required Color color}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 15),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ...points.map((p) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(child: Text(p, style: const TextStyle(fontSize: 16))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
