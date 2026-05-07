import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../services/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.grey[50], // Very light grey
      appBar: AppBar(
        title: Text('MY HEALTH PROFILE', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
            icon: const Icon(Icons.edit, color: Color(0xFF00796B)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Column(
                children: [
                  FadeInDown(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.teal[50],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.teal, width: 4),
                      ),
                      child: const Center(
                        child: Icon(Icons.person, color: Color(0xFF00796B), size: 60),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeIn(
                    child: Text(
                      user.name,
                      style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF004D40)),
                    ),
                  ),
                  const SizedBox(height: 5),
                  FadeIn(
                    child: Text(
                      'Phone: +91 ${user.phone}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildProfileTile(Icons.cake, 'Age', '${user.age} Years'),
                  _buildProfileTile(Icons.people, 'Gender', user.gender),
                  _buildProfileTile(Icons.medical_services, 'Blood Group', user.bloodGroup),
                  _buildProfileTile(Icons.work, 'Occupation', user.occupation),
                  _buildProfileTile(Icons.history, 'Clinical Conditions', user.medicalConditions),
                  _buildProfileTile(Icons.warning, 'Allergies', user.allergies),

                  const SizedBox(height: 40),

                  FadeInUp(
                    child: ElevatedButton(
                      onPressed: () {
                        auth.logout();
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[50], foregroundColor: Colors.red[800], minimumSize: const Size(double.infinity, 60)),
                      child: const Text('LOGOUT ACCOUNT'),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value) {
    return FadeInLeft(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey[200]!)),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal, size: 28),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF004D40))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
