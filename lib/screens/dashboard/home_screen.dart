import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../services/auth_provider.dart';
import '../../services/theme_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Random _random = Random();
  
  int _currentTipIndex = 0;
  int _currentRemedyIndex = 0;

  bool _isHindi = false;

  final List<String> _itTips = [
    "Your spine is not designed for 9-hour Zoom meetings.",
    "Blue light at 2 AM is not a personality trait.",
    "Ctrl + S saves files. Sleep saves humans.",
    "Drinking 4 cups of coffee is not a substitute for 8 hours of sleep.",
    "Looking at a screen to relax after looking at a screen all day is a trap.",
    "Your kidneys are working harder than your group project teammates. Drink water.",
    "Walking for 10 minutes after food helps more than scrolling reels."
  ];

  final List<Map<String, dynamic>> _itRemedies = [
    {
      "symptom": "Eye Strain",
      "remedy": ["20-20-20 eye rule", "Blink more frequently", "Adjust screen brightness"],
      "icon": Icons.remove_red_eye_outlined,
    },
    {
      "symptom": "Neck/Back Pain",
      "remedy": ["Stretch every hour", "Posture correction", "Light walks after work"],
      "icon": Icons.airline_seat_recline_normal_outlined,
    },
    {
      "symptom": "Poor Sleep",
      "remedy": ["Sleep hygiene", "No screens 1hr before bed", "Read a book"],
      "icon": Icons.bedtime_outlined,
    },
    {
      "symptom": "Dehydration",
      "remedy": ["Drink water reminders", "Keep a bottle at desk", "Limit caffeine"],
      "icon": Icons.water_drop_outlined,
    },
  ];

  final List<String> _farmerTips = [
    "खेत में काम करते समय टोपी जरूर पहनें और पानी पीते रहें।",
    "शरीर दर्द होने पर हल्दी वाला दूध पीना बहुत फायदेमंद है।",
    "नींबू पानी और छाछ आपको गर्मी से बचा सकते हैं।",
    "थकान महसूस होने पर थोड़ा आराम करना ज़रूरी है, मशीन की तरह काम न करें।",
    "तुलसी और अदरक की चाय सर्दी-खांसी के लिए बेहतरीन है।",
    "काम के बीच में थोड़ा आराम करें, सेहत सबसे बड़ी दौलत है।"
  ];

  final List<Map<String, dynamic>> _farmerRemedies = [
    {
      "symptom": "डिहाइड्रेशन (पानी की कमी)",
      "remedy": ["नींबू पानी", "छाछ पिएं", "आराम और पानी पीना"],
      "icon": Icons.water_drop_outlined,
    },
    {
      "symptom": "शरीर दर्द",
      "remedy": ["हल्दी वाला दूध", "सरसों के तेल से मालिश", "गर्म सिकाई"],
      "icon": Icons.healing_outlined,
    },
    {
      "symptom": "सर्दी और खांसी",
      "remedy": ["तुलसी चाय", "अदरक का काढ़ा", "भाप लें"],
      "icon": Icons.medical_services_outlined,
    },
    {
      "symptom": "थकान",
      "remedy": ["जीरा पानी", "गुड़ और चना", "भरपूर नींद"],
      "icon": Icons.battery_alert_outlined,
    },
  ];

  @override
  void initState() {
    super.initState();
    // We will initialize indices in build to avoid issues, or initialize randomly here
    _currentTipIndex = 0;
    _currentRemedyIndex = 0;
  }

  void _randomizeIndices(bool isHindi) {
    int tipCount = isHindi ? _farmerTips.length : _itTips.length;
    int remedyCount = isHindi ? _farmerRemedies.length : _itRemedies.length;
    _currentTipIndex = _random.nextInt(tipCount);
    _currentRemedyIndex = _random.nextInt(remedyCount);
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _randomizeIndices(_isHindi);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    
    // Determine user profile type
    _isHindi = (user?.occupation?.toLowerCase() == 'farmer');

    // Make sure indices are within bounds when switching profiles
    int tipCount = _isHindi ? _farmerTips.length : _itTips.length;
    int remedyCount = _isHindi ? _farmerRemedies.length : _itRemedies.length;
    if (_currentTipIndex >= tipCount) _currentTipIndex = _random.nextInt(tipCount);
    if (_currentRemedyIndex >= remedyCount) _currentRemedyIndex = _random.nextInt(remedyCount);

    final currentTips = _isHindi ? _farmerTips : _itTips;
    final currentRemedies = _isHindi ? _farmerRemedies : _itRemedies;

    final themeProvider = Provider.of<ThemeProvider>(context);

    // Dynamic Labels
    final String title = _isHindi ? 'डैशबोर्ड' : 'DASHBOARD';
    final String greeting = _isHindi ? 'नमस्ते' : 'Namaste';
    final String subtitle = _isHindi ? 'हम आपकी कैसे मदद कर सकते हैं?' : 'How can we help you today?';
    final String sosTitle = _isHindi ? 'आपातकालीन एसओएस' : 'EMERGENCY SOS';
    final String sosSub = _isHindi ? 'तत्काल सहायता और 108 अलर्ट' : 'Immediate help & 108 Alert';
    final String remedyTitle = _isHindi ? 'घरेलू उपचार:' : 'Indian Home Remedies:';
    final String tipTitle = _isHindi ? 'दैनिक स्वास्थ्य टिप' : 'DAILY HEALTH TIP';

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: themeProvider.textColor),
        ),
        backgroundColor: themeProvider.appBarColor,
        elevation: 0,
        actions: [
          DropdownButton<AppThemeMode>(
            value: themeProvider.themeMode,
            underline: const SizedBox(),
            icon: Icon(Icons.palette, color: themeProvider.iconColor),
            items: const [
              DropdownMenuItem(value: AppThemeMode.colorful, child: Text("Colorful")),
              DropdownMenuItem(value: AppThemeMode.light, child: Text("Light")),
              DropdownMenuItem(value: AppThemeMode.dark, child: Text("Dark")),
            ],
            onChanged: (mode) {
              if (mode != null) themeProvider.setTheme(mode);
            },
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: Icon(Icons.account_circle_outlined, color: themeProvider.iconColor, size: 28),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: themeProvider.iconColor,
        backgroundColor: themeProvider.cardColor,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                child: Text(
                  '$greeting, ${user?.name ?? 'User'}!',
                  style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: themeProvider.textColor),
                ),
              ),
              const SizedBox(height: 5),
              FadeIn(
                child: Text(
                  subtitle,
                  style: GoogleFonts.outfit(fontSize: 18, color: themeProvider.secondaryTextColor),
                ),
              ),
              const SizedBox(height: 30),

              // SOS Alert Box
              FadeInLeft(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/sos'),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: themeProvider.sosColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: themeProvider.sosColor.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(FontAwesomeIcons.truckMedical, color: Colors.white, size: 30),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sosTitle,
                                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                sosSub,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Remedy Card
              FadeInUp(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: themeProvider.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: themeProvider.iconColor.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: themeProvider.iconColor.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(currentRemedies[_currentRemedyIndex]['icon'], color: themeProvider.iconColor, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            currentRemedies[_currentRemedyIndex]['symptom'].toUpperCase(),
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: themeProvider.textColor, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        remedyTitle,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: themeProvider.textColor),
                      ),
                      const SizedBox(height: 8),
                      ...(currentRemedies[_currentRemedyIndex]['remedy'] as List<String>).map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 16, color: themeProvider.secondaryTextColor),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item, style: TextStyle(fontSize: 15, color: themeProvider.textColor))),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Main Services Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                children: [
                  _buildServiceCard(
                    context,
                    title: _isHindi ? 'लक्षण\nपहचानें' : 'Identify\nSymptoms',
                    subtitle: _isHindi ? 'स्वास्थ्य जाँच' : 'Fast Health Checker',
                    icon: FontAwesomeIcons.stethoscope,
                    color: const Color(0xFF00796B),
                    onTap: () => Navigator.pushNamed(context, '/symptom-selection'),
                  ),
                  _buildServiceCard(
                    context,
                    title: _isHindi ? 'वॉइस\nअसिस्टेंट' : 'Voice\nAssistant',
                    subtitle: _isHindi ? 'बोलकर पूछें' : 'Speak your concern',
                    icon: FontAwesomeIcons.microphone,
                    color: const Color(0xFF5C6BC0),
                    onTap: () => Navigator.pushNamed(context, '/voice-assistant'),
                  ),
                  _buildServiceCard(
                    context,
                    title: _isHindi ? 'पीएचसी\nखोजें' : 'PHC\nLocator',
                    subtitle: _isHindi ? 'नज़दीकी क्लिनिक' : 'Find nearest clinic',
                    icon: FontAwesomeIcons.mapLocationDot,
                    color: Colors.orange[800]!,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(_isHindi ? 'नज़दीकी क्लिनिक खोजा जा रहा है...' : 'Locating local PHCs...'))
                      );
                    },
                  ),
                  _buildServiceCard(
                    context,
                    title: _isHindi ? 'चैट\nकरें' : 'Chat\nNow',
                    subtitle: _isHindi ? '24/7 बॉट' : '24/7 Bot Assistant',
                    icon: FontAwesomeIcons.whatsapp,
                    color: const Color(0xFF25D366),
                    onTap: () => Navigator.pushNamed(context, '/chat'),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Health Tips
              FadeInUp(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: themeProvider.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: themeProvider.iconColor.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(color: themeProvider.iconColor.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: themeProvider.iconColor),
                          const SizedBox(width: 10),
                          Text(
                            tipTitle,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: themeProvider.secondaryTextColor, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentTips[_currentTipIndex],
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: themeProvider.textColor, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final accentColor = themeProvider.getCardAccentColor(color);

    return FadeInUp(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: themeProvider.cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: themeProvider.iconColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accentColor, size: 28),
              const SizedBox(height: 15),
              Text(
                title,
                style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: themeProvider.textColor),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: themeProvider.secondaryTextColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
