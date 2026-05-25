import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:async';


import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/image_picker_service.dart';
import '../services/local_storage_service.dart';
import '../services/profile_firebase_service.dart';

/// Provider for managing profile image state across the app.
/// Handles picking, local caching, uploading, and offline fallback.
class ProfileImageProvider extends ChangeNotifier {
  final ImagePickerService _pickerService = ImagePickerService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final ProfileFirebaseService _firebaseService = ProfileFirebaseService();
  StreamSubscription<User?>? _authSubscription;

  Uint8List? _imageBytes;
  String? _localImagePath;
  String? _profileImageUrl;
  bool _isUploading = false;
  String? _error;

  ProfileImageProvider() {
    // Auto-reload or clear image whenever the authenticated user changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadCurrentImage();
      } else {
        // User logged out — clear all image state immediately
        _imageBytes = null;
        _localImagePath = null;
        _profileImageUrl = null;
        _error = null;
        notifyListeners();
      }
    });
  }

  // Getters
  Uint8List? get imageBytes => _imageBytes;
  String? get localImagePath => _localImagePath;
  String? get profileImageUrl => _profileImageUrl;
  bool get isUploading => _isUploading;
  String? get error => _error;
  bool get hasImage => _imageBytes != null || _profileImageUrl != null;

  /// Initialize — load the cached local image and remote URL on startup.
  Future<void> loadCurrentImage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Load user-specific local cached image first (instant, offline-safe)
    _localImagePath = await _localStorageService.getLocalImagePath(user.uid);
    _imageBytes = await _localStorageService.loadLocalImageBytes(user.uid);

    // Also fetch the remote URL for fallback
    _profileImageUrl = await _firebaseService.getProfileImageUrl(user.uid);

    notifyListeners();
  }

  /// Pick image from Camera, compress, save locally, upload to Firebase.
  Future<bool> pickFromCamera() async {
    final bytes = await _pickerService.pickFromCamera();
    if (bytes == null) return false;
    return await _processAndUpload(bytes);
  }

  /// Pick image from Gallery, compress, save locally, upload to Firebase.
  Future<bool> pickFromGallery() async {
    final bytes = await _pickerService.pickFromGallery();
    if (bytes == null) return false;
    return await _processAndUpload(bytes);
  }

  /// Pick image from File Manager, save locally, upload to Firebase.
  Future<bool> pickFromFileManager() async {
    final bytes = await _pickerService.pickFromFileManager();
    if (bytes == null) return false;
    return await _processAndUpload(bytes);
  }

  /// Core workflow: save locally → update UI → upload to Firebase → update Firestore.
  Future<bool> _processAndUpload(Uint8List imageBytes) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = 'User not logged in.';
      notifyListeners();
      return false;
    }

    _error = null;
    _isUploading = true;

    // Step 1: Instantly update UI with the new image (optimistic update)
    _imageBytes = imageBytes;
    notifyListeners();

    // Step 2: Try to save image to local permanent storage (will return null on Web)
    _localImagePath = await _localStorageService.saveImageLocally(user.uid, imageBytes);

    // Step 3: Compress bytes and store directly as Base64 in Firestore
    try {
      Uint8List finalBytes = imageBytes;
      
      // Heavily compress the image to ensure it stays under Firestore's 1MB limit
      if (!kIsWeb) {
        finalBytes = await FlutterImageCompress.compressWithList(
          imageBytes,
          minWidth: 256,
          minHeight: 256,
          quality: 60,
        );
      }

      final String base64Image = 'data:image/jpeg;base64,${base64Encode(finalBytes)}';
      
      if (base64Image.length > 1040000) {
        _error = 'Image is still too large for Firestore after compression. Please pick a smaller image.';
        _isUploading = false;
        notifyListeners();
        return false;
      }

      _profileImageUrl = base64Image;

      // Step 4: Update Firestore with the base64 string
      await _firebaseService.updateProfileImageData(
        uid: user.uid,
        profileImageUrl: base64Image, // Storing Base64 inside Firestore
        localImagePath: _localImagePath ?? '',
      );

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error storing image in Firestore: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sets an asset image path directly instead of uploading a file.
  Future<bool> setAssetProfileImage(String assetPath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _error = 'User not logged in.';
      notifyListeners();
      return false;
    }

    _error = null;
    _isUploading = true;
    
    // Clear local bytes since we are using an asset
    _imageBytes = null;
    _profileImageUrl = assetPath;
    _localImagePath = null;
    notifyListeners();

    try {
      // Clean up existing uploaded images (to avoid orphaned files)
      await _firebaseService.deleteProfileImage(user.uid);
      await _localStorageService.deleteLocalImage(user.uid); // pass UID

      await _firebaseService.updateProfileImageData(
        uid: user.uid,
        profileImageUrl: assetPath,
        localImagePath: '',
      );
      
      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error setting asset image: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  /// Retry uploading a locally cached image that failed previously.
  Future<bool> retryUpload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (_imageBytes == null && user != null) {
      // Load from disk using user-specific cache
      _imageBytes = await _localStorageService.loadLocalImageBytes(user.uid);
    }
    if (_imageBytes == null) {
      _error = 'No local image found to retry.';
      notifyListeners();
      return false;
    }
    return await _processAndUpload(_imageBytes!);
  }

  /// Clear error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
