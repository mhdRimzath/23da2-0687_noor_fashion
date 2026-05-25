
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to save/load profile images locally for offline support.
/// All keys are scoped per-user using the UID to prevent image bleed between accounts.
class LocalStorageService {
  /// Returns the SharedPreferences key scoped to a specific user.
  static String _localImagePathKey(String uid) => 'local_profile_image_path_$uid';

  /// Save image bytes to a permanent local file and store its path.
  /// Returns the absolute local file path.
  Future<String?> saveImageLocally(String uid, Uint8List imageBytes) async {
    try {
      if (kIsWeb) {
        debugPrint('⚠️ Local file storage not available on web.');
        return null;
      }

      final Directory appDir = await getApplicationDocumentsDirectory();
      final String filePath = '${appDir.path}/profile_$uid.jpg';
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // Persist the path in SharedPreferences using a UID-scoped key
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localImagePathKey(uid), filePath);

      debugPrint('✅ Image saved locally at: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('❌ Error saving image locally: $e');
      return null;
    }
  }

  /// Get the saved local image path from SharedPreferences for a specific user.
  Future<String?> getLocalImagePath(String uid) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_localImagePathKey(uid));
    } catch (e) {
      debugPrint('❌ Error reading local image path: $e');
      return null;
    }
  }

  /// Load the local image bytes from disk for a specific user.
  Future<Uint8List?> loadLocalImageBytes(String uid) async {
    try {
      if (kIsWeb) return null;

      final path = await getLocalImagePath(uid);
      if (path == null) return null;

      final File file = File(path);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error loading local image bytes: $e');
      return null;
    }
  }

  /// Delete the local image file for a specific user.
  Future<void> deleteLocalImage(String uid) async {
    try {
      if (kIsWeb) return;

      final path = await getLocalImagePath(uid);
      if (path == null) return;

      final File file = File(path);
      if (await file.exists()) {
        await file.delete();
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_localImagePathKey(uid));
    } catch (e) {
      debugPrint('❌ Error deleting local image: $e');
    }
  }
}
