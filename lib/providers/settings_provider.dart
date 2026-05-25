import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firestore_service.dart';

class SettingsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _settingsSubscription;
  StreamSubscription? _authSubscription;
  SharedPreferences? _prefs;

  bool _isLoading = false;
  Map<String, dynamic> _settings = {
    'pushNotifications': true,
    'emailNotifications': true,
    'darkMode': false,
    'biometricAuth': false,
  };

  bool get isLoading => _isLoading;
  bool get pushNotifications => _settings['pushNotifications'] ?? true;
  bool get emailNotifications => _settings['emailNotifications'] ?? true;
  bool get darkMode => _settings['darkMode'] ?? false;
  bool get biometricAuth => _settings['biometricAuth'] ?? false;

  SettingsProvider() {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (_prefs != null && _prefs!.containsKey('darkMode')) {
      _settings['darkMode'] = _prefs!.getBool('darkMode') ?? false;
      notifyListeners();
    }

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initSettingsStream(user.uid);
      } else {
        _settingsSubscription?.cancel();
        // Reset to defaults on logout, BUT keep the user's cached dark mode preference
        final currentDarkMode = _prefs?.getBool('darkMode') ?? _settings['darkMode'] ?? false;
        _settings = {
          'pushNotifications': true,
          'emailNotifications': true,
          'darkMode': currentDarkMode,
          'biometricAuth': false,
        };
        notifyListeners();
      }
    });
  }

  void _initSettingsStream(String userId) {
    _settingsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _settingsSubscription = _firestoreService.getSettingsStream(userId).listen((settingsData) {
      _isLoading = false;
      if (settingsData != null) {
        // Merge fetched data with defaults
        _settings = {
          'pushNotifications': settingsData['pushNotifications'] ?? true,
          'emailNotifications': settingsData['emailNotifications'] ?? true,
          'darkMode': settingsData['darkMode'] ?? false,
          'biometricAuth': settingsData['biometricAuth'] ?? false,
        };
        // Cache the latest dark mode state from Firestore
        if (_prefs != null) {
          _prefs!.setBool('darkMode', _settings['darkMode']);
        }
      }
      notifyListeners();
    }, onError: (e) {
      _isLoading = false;
      debugPrint('Error loading settings stream: $e');
      notifyListeners();
    });
  }

  Future<void> updateSetting(String key, bool value) async {
    // Update local state so it works for guests
    _settings[key] = value;
    if (key == 'darkMode' && _prefs != null) {
      await _prefs!.setBool('darkMode', value);
    }
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestoreService.updateSettings(user.uid, {key: value});
    } catch (e) {
      // Revert on error
      _settings[key] = !value;
      notifyListeners();
      debugPrint('Failed to update setting: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _settingsSubscription?.cancel();
    super.dispose();
  }
}
