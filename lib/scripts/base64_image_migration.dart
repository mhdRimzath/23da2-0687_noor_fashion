import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class Base64ImageMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Migrates all users' base64 profile images to Firebase Storage.
  Future<void> migrateAllUsersImages() async {
    debugPrint('🚀 Starting Base64 Profile Image Migration...');
    int successCount = 0;
    int failureCount = 0;
    int skippedCount = 0;

    try {
      // 1. Fetch all user documents from the 'users' collection
      final QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      debugPrint('📦 Found ${usersSnapshot.docs.length} total users to process.');

      for (var doc in usersSnapshot.docs) {
        final uid = doc.id;
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          skippedCount++;
          continue;
        }

        // Check if the user has a base64 image
        final String? base64String = data['profileImageBase64'] as String?;

        if (base64String == null || base64String.isEmpty) {
          debugPrint('⏭️ Skipping user $uid: No Base64 image found.');
          skippedCount++;
          continue;
        }

        debugPrint('⏳ Processing user $uid...');

        try {
          // 2. Decode Base64 string to Uint8List
          // Note: sometimes base64 strings have data URI prefixes (e.g., "data:image/jpeg;base64,...")
          String cleanBase64 = base64String;
          if (cleanBase64.contains(',')) {
            cleanBase64 = cleanBase64.split(',').last;
          }
          
          final Uint8List imageBytes = base64Decode(cleanBase64);

          // 3. Upload image bytes to Firebase Storage
          final Reference storageRef = _storage.ref().child('users/$uid/profile.jpg');
          
          final UploadTask uploadTask = storageRef.putData(
            imageBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );

          final TaskSnapshot snapshot = await uploadTask;

          // 4. Generate Firebase download URL
          final String downloadUrl = await snapshot.ref.getDownloadURL();

          // 5. Update Firestore document (add URL, update timestamp, remove base64)
          await _firestore.collection('users').doc(uid).update({
            'profileImageUrl': downloadUrl,
            'updatedAt': FieldValue.serverTimestamp(),
            'profileImageBase64': FieldValue.delete(),
          });

          debugPrint('✅ Successfully migrated image for user $uid');
          successCount++;
          
        } catch (e) {
          debugPrint('❌ Failed to migrate user $uid: $e');
          failureCount++;
          // Continue to the next user even if this one fails
        }
      }

      debugPrint('🎉 Migration Completed!');
      debugPrint('📊 Summary:');
      debugPrint('   - Successfully Migrated: $successCount');
      debugPrint('   - Failed: $failureCount');
      debugPrint('   - Skipped (No Base64): $skippedCount');

    } catch (e) {
      debugPrint('💥 Critical Error during migration: $e');
    }
  }
}
