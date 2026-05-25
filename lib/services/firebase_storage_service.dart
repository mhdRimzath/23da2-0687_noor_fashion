import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
// Note: In a real project, consider using flutter_image_compress package.
// For this example, we'll demonstrate the structure.

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads an image file to Firebase Storage and returns the download URL
  Future<String?> uploadProfileImage(String uid, File imageFile) async {
    try {
      // 1. Compress Image (Simulated here - in production use flutter_image_compress)
      final compressedFile = await _compressImage(imageFile);

      // 2. Define the path in Firebase Storage
      final String path = 'users/$uid/profile_images/avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child(path);

      // 3. Upload the compressed file
      final UploadTask uploadTask = ref.putFile(
        compressedFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // 4. Wait for completion and get URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      debugPrint('Failed to upload profile image: $e');
      return null;
    }
  }

  /// Delete an existing profile image
  Future<void> deleteProfileImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('firebasestorage')) {
        final Reference ref = _storage.refFromURL(imageUrl);
        await ref.delete();
      }
    } catch (e) {
      debugPrint('Failed to delete old profile image: $e');
    }
  }

  /// Simulated image compression
  Future<File> _compressImage(File file) async {
    // In production, implement real compression:
    // var result = await FlutterImageCompress.compressAndGetFile(
    //   file.absolute.path, targetPath, quality: 70,
    // );
    // return result;
    
    // For now, return the original file
    return file;
  }
}
