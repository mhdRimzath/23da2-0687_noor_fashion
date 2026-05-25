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
  final Completer<void> _ready = Completer<void>();

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
    final systemDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    _settings['darkMode'] = systemDark;
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final systemDark = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    if (_prefs != null && _prefs!.containsKey('darkMode')) {
      _settings['darkMode'] = _prefs!.getBool('darkMode') ?? systemDark;
      notifyListeners();
    } else {
      _settings['darkMode'] = systemDark;
      notifyListeners();
    }

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _initSettingsStream(user.uid);
      } else {
        _settingsSubscription?.cancel();
        // Reset to defaults on logout, BUT keep the user's cached dark mode preference
        final currentDarkMode = _prefs?.getBool('darkMode') ?? _settings['darkMode'] ?? systemDark;
        _settings = {
          'pushNotifications': true,
          'emailNotifications': true,
          'darkMode': currentDarkMode,
          'biometricAuth': false,
        };
        notifyListeners();
      }
    });
    // Mark provider as ready for callers that need the preference synchronously
    if (!_ready.isCompleted) _ready.complete();
  }

  /// Wait until the provider has completed initial preference loading.
  Future<void> waitUntilReady() => _ready.future;

  void _initSettingsStream(String userId) {
    _settingsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _settingsSubscription = _firestoreService.getSettingsStream(userId).listen((settingsData) {
      _isLoading = false;
      if (settingsData != null) {
        // Prefer an explicit darkMode value from Firestore, otherwise keep the
        // locally cached preference (or system default) to avoid unexpected flips.
        final bool darkModeValue = settingsData.containsKey('darkMode')
            ? (settingsData['darkMode'] as bool)
            : (_prefs?.getBool('darkMode') ?? _settings['darkMode'] ?? 
                WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);

        _settings = {
          'pushNotifications': settingsData['pushNotifications'] ?? _settings['pushNotifications'] ?? true,
          'emailNotifications': settingsData['emailNotifications'] ?? _settings['emailNotifications'] ?? true,
          'darkMode': darkModeValue,
          'biometricAuth': settingsData['biometricAuth'] ?? _settings['biometricAuth'] ?? false,
        };

        // Cache the resolved dark mode preference locally
        if (_prefs != null) {
          _prefs!.setBool('darkMode', _settings['darkMode']);
        }
      } else {
        // If settings don't exist in Firestore, save the current local settings to Firestore
        _firestoreService.updateSettings(userId, {
          'pushNotifications': _settings['pushNotifications'] ?? true,
          'emailNotifications': _settings['emailNotifications'] ?? true,
          'darkMode': _settings['darkMode'] ?? false,
          'biometricAuth': _settings['biometricAuth'] ?? false,
        });
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
