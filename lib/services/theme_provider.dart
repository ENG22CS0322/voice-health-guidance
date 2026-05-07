import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { colorful, light, dark }

class ThemeProvider extends ChangeNotifier {
  AppThemeMode _themeMode = AppThemeMode.colorful;

  AppThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final String? themeStr = prefs.getString('theme_mode');
    if (themeStr != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (e) => e.toString() == themeStr, 
        orElse: () => AppThemeMode.colorful
      );
      notifyListeners();
    }
  }

  void setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme_mode', mode.toString());
  }

  // Basic Colors
  Color get backgroundColor {
    switch (_themeMode) {
      case AppThemeMode.colorful: return const Color(0xFFF1F8E9);
      case AppThemeMode.light: return const Color(0xFFF8F9FA);
      case AppThemeMode.dark: return const Color(0xFF121212);
    }
  }

  Color get cardColor {
    switch (_themeMode) {
      case AppThemeMode.colorful: return Colors.white;
      case AppThemeMode.light: return Colors.white;
      case AppThemeMode.dark: return const Color(0xFF1E1E1E);
    }
  }

  Color get textColor {
    switch (_themeMode) {
      case AppThemeMode.colorful: return const Color(0xFF004D40);
      case AppThemeMode.light: return Colors.black87;
      case AppThemeMode.dark: return Colors.white;
    }
  }

  Color get secondaryTextColor {
    switch (_themeMode) {
      case AppThemeMode.colorful: return Colors.grey[700]!;
      case AppThemeMode.light: return Colors.black54;
      case AppThemeMode.dark: return Colors.white70;
    }
  }

  Color get appBarColor {
    switch (_themeMode) {
      case AppThemeMode.colorful: return Colors.white;
      case AppThemeMode.light: return Colors.white;
      case AppThemeMode.dark: return const Color(0xFF1E1E1E);
    }
  }

  Color get iconColor {
    switch (_themeMode) {
      case AppThemeMode.colorful: return const Color(0xFF00796B);
      case AppThemeMode.light: return Colors.black87;
      case AppThemeMode.dark: return Colors.white;
    }
  }

  Color get sosColor {
    switch (_themeMode) {
      case AppThemeMode.colorful: return const Color(0xFFD32F2F);
      case AppThemeMode.light: return const Color(0xFFE53935);
      case AppThemeMode.dark: return const Color(0xFFB71C1C);
    }
  }

  // Card specific colors (for Colorful mode)
  Color getCardAccentColor(Color vibrantColor) {
    switch (_themeMode) {
      case AppThemeMode.colorful: return vibrantColor;
      case AppThemeMode.light: return Colors.black87;
      case AppThemeMode.dark: return Colors.white70;
    }
  }
}
