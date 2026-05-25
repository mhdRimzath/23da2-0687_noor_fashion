import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UrlPathMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Migrates all users by moving their `profileImageUrl` into `profileImageBase64` 
  /// and deleting the old `profileImageUrl` field, matching the new architecture.
  Future<void> migrateProfilePaths() async {
    debugPrint('🚀 Starting Profile URL Path Migration...');
    int successCount = 0;
    int failureCount = 0;
    int skippedCount = 0;

    try {
      final QuerySnapshot usersSnapshot = await _firestore.collection('users').get();
      debugPrint('📦 Found ${usersSnapshot.docs.length} total users to process.');

      for (var doc in usersSnapshot.docs) {
        final uid = doc.id;
        final data = doc.data() as Map<String, dynamic>?;

        if (data == null) {
          skippedCount++;
          continue;
        }

        // Check if the user has the old profileImageUrl field
        final String? oldUrl = data['profileImageUrl'] as String?;

        if (oldUrl == null || oldUrl.isEmpty) {
          debugPrint('⏭️ Skipping user $uid: No profileImageUrl found.');
          skippedCount++;
          continue;
        }

        debugPrint('⏳ Migrating path for user $uid...');

        try {
          // Update Firestore document: 
          // Move the URL to profileImageBase64, update timestamp, and delete old field
          await _firestore.collection('users').doc(uid).update({
            'profileImageBase64': oldUrl,
            'updatedAt': FieldValue.serverTimestamp(),
            'profileImageUrl': FieldValue.delete(),
          });

          debugPrint('✅ Successfully migrated path for user $uid');
          successCount++;
          
        } catch (e) {
          debugPrint('❌ Failed to migrate user $uid: $e');
          failureCount++;
        }
      }

      debugPrint('🎉 Path Migration Completed!');
      debugPrint('📊 Summary:');
      debugPrint('   - Successfully Migrated: $successCount');
      debugPrint('   - Failed: $failureCount');
      debugPrint('   - Skipped (No profileImageUrl): $skippedCount');

    } catch (e) {
      debugPrint('💥 Critical Error during migration: $e');
    }
  }
}
