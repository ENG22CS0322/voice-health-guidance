import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  UserProfile? _currentUser;
  final String _prefKey = 'current_user_profile';

  // 2 Pre-registered demo numbers as required
  final List<String> _demoNumbers = ['8888888888', '9999999999'];

  bool get isLoggedIn => _isLoggedIn;
  UserProfile? get currentUser => _currentUser;
  List<String> get demoNumbers => _demoNumbers;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString(_prefKey);
    if (userJson != null) {
      _currentUser = UserProfile.fromJson(jsonDecode(userJson));
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  // Pre-process Login Check
  bool checkPhone(String phone) {
    return _demoNumbers.contains(phone);
  }

  // OTP Verification
  Future<bool> verifyOTP(String phone, String otp) async {
    bool isValid = false;
    if (phone == '8888888888' && otp == '123456') isValid = true;
    if (phone == '9999999999' && otp == '654321') isValid = true;

    if (isValid) {
      _isLoggedIn = true;
      // Default Profile for Demo Users if not found
      _currentUser = UserProfile(
          name: phone == '9999999999' ? 'Rajesh' : 'Sunita Devi',
          phone: phone,
          age: phone == '9999999999' ? 28 : 45,
          gender: phone == '9999999999' ? 'Male' : 'Female',
          bloodGroup: 'O+',
          medicalConditions: 'None',
          allergies: 'None',
          occupation: phone == '9999999999' ? 'IT Employee' : 'Farmer'
      );
      await _saveUserToStorage();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> registerUser(UserProfile profile) async {
    _currentUser = profile;
    _isLoggedIn = true;
    await _saveUserToStorage();
    notifyListeners();
  }

  Future<void> _saveUserToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentUser != null) {
      prefs.setString(_prefKey, jsonEncode(_currentUser!.toJson()));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile profile) async {
    _currentUser = profile;
    await _saveUserToStorage();
    notifyListeners();
  }
}
