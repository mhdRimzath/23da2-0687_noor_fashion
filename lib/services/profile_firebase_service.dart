import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Service for uploading profile images to Firebase Storage
/// and updating Firestore with the resulting URL.
class ProfileFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload image byte code (Uint8List) to Firebase Storage using putData.
  /// Returns the download URL on success, null on failure.
  Future<String?> uploadProfileImage(String uid, Uint8List imageBytes) async {
    try {
      final Reference storageRef = _storage.ref().child('users/$uid/profile.jpg');

      final UploadTask uploadTask = storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      debugPrint('✅ Image uploaded to Firebase Storage. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('❌ Firebase Storage upload error: $e');
      return null;
    }
  }

  /// Update the user's Firestore document with profile image data.
  Future<bool> updateProfileImageData({
    required String uid,
    required String profileImageUrl,
    String? localImagePath,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'profileImageBase64': profileImageUrl, // Storing the URL/path in the legacy field name
        'profileImageUrl': FieldValue.delete(), // Automatically migrate by deleting the old field
        if (localImagePath != null && localImagePath.isNotEmpty) 'localImagePath': localImagePath,
        if (localImagePath == '') 'localImagePath': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
        'uid': uid,
      }, SetOptions(merge: true));

      debugPrint('✅ Firestore updated with new profile image URL.');
      return true;
    } catch (e) {
      debugPrint('❌ Firestore update error: $e');
      return false;
    }
  }

  /// Get the current user's profile image URL from Firestore.
  Future<String?> getProfileImageUrl(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        // Read from the new field where the URL is stored
        return doc.data()?['profileImageBase64'] as String? ?? doc.data()?['profileImageUrl'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching profile image URL: $e');
      return null;
    }
  }

  /// Delete existing profile image from Firebase Storage.
  Future<void> deleteProfileImage(String uid) async {
    try {
      final Reference ref = _storage.ref().child('users/$uid/profile.jpg');
      await ref.delete();
      debugPrint('✅ Deleted old profile image from Storage.');
    } catch (e) {
      debugPrint('⚠️ No existing image to delete or error: $e');
    }
  }
}
