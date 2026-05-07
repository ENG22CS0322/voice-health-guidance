import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Import local files
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/dashboard/home_screen.dart';
import 'screens/dashboard/symptom_selection_screen.dart';
import 'screens/dashboard/guidance_screen.dart';
import 'screens/dashboard/sos_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/dashboard/chat_screen.dart';
import 'screens/dashboard/voice_assistant_screen.dart';
import 'services/auth_provider.dart';
import 'services/guidance_provider.dart';
import 'services/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
    runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GuidanceProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const HealthMaxApp(),
    ),
  );
}

class HealthMaxApp extends StatelessWidget {
  const HealthMaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Voice AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          primary: const Color(0xFF00796B),
          secondary: const Color(0xFF004D40),
          tertiary: const Color(0xFFD32F2F), // SOS Red
          surface: Colors.white,
          background: const Color(0xFFF1F8E9),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF004D40),
          ),
          bodyLarge: GoogleFonts.outfit(
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60), // Large rural-friendly buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/otp': (context) => const OTPScreen(),
        '/home': (context) => const HomeScreen(),
        '/symptom-selection': (context) => const SymptomSelectionScreen(),
        '/guidance': (context) => const GuidanceScreen(),
        '/sos': (context) => const SOSScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/chat': (context) => const ChatScreen(),
        '/voice-assistant': (context) => const VoiceAssistantScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}
