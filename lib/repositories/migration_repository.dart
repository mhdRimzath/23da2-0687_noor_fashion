import 'dart:async';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../services/firestore_profile_service.dart';
import '../services/firebase_storage_service.dart';
import '../utils/migration_helper.dart';

class MigrationRepository {
  final FirestoreProfileService _firestoreService;
  final FirebaseStorageService _storageService;
  static const String _localProfileKey = 'local_user_profile';

  MigrationRepository({
    required FirestoreProfileService firestoreService,
    required FirebaseStorageService storageService,
  })  : _firestoreService = firestoreService,
        _storageService = storageService;

  /// Fetch local profile from SharedPreferences
  Future<ProfileModel?> getLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_localProfileKey);
    if (profileJson != null) {
      return ProfileModel.fromJson(profileJson);
    }
    return null;
  }

  /// Save profile locally
  Future<void> saveLocalProfile(ProfileModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localProfileKey, profile.toJson());
  }

  /// Perform the main migration logic when a user logs in
  Future<ProfileModel> migrateAndSyncProfile(String uid, ProfileModel localProfile) async {
    try {
      // 1. Fetch remote profile
      final remoteProfile = await _firestoreService.getProfile(uid);

      ProfileModel finalProfile;

      // 2. If remote does not exist, upload local to remote
      if (remoteProfile == null) {
        finalProfile = await _uploadProfileWithImage(uid, localProfile);
      } else {
        // 3. If exists, merge intelligently
        finalProfile = MigrationHelper.mergeProfiles(local: localProfile, remote: remoteProfile);
        
        // If local was newer, upload merged result
        if (MigrationHelper.requiresUpload(localProfile, remoteProfile)) {
           finalProfile = await _uploadProfileWithImage(uid, finalProfile);
        } else {
           // Remote was newer or same, just update local to match remote
           finalProfile = finalProfile.copyWith(isSynced: true, migrationStatus: 'completed');
        }
      }

      // 4. Save the final merged/synced profile locally
      await saveLocalProfile(finalProfile);
      return finalProfile;

    } catch (e) {
      // If sync fails, mark local as failed and keep it for retry
      final failedProfile = localProfile.copyWith(isSynced: false, migrationStatus: 'failed');
      await saveLocalProfile(failedProfile);
      throw Exception('Migration failed: $e');
    }
  }

  /// Helper to upload profile and its image
  Future<ProfileModel> _uploadProfileWithImage(String uid, ProfileModel profile) async {
    ProfileModel profileToUpload = profile.copyWith(migrationStatus: 'syncing');
    
    // Upload image if localImagePath exists and profileImageUrl is empty
    if (profile.localImagePath.isNotEmpty && profile.profileImageUrl.isEmpty) {
      final file = File(profile.localImagePath);
      if (await file.exists()) {
        final downloadUrl = await _storageService.uploadProfileImage(uid, file);
        if (downloadUrl != null) {
          profileToUpload = profileToUpload.copyWith(profileImageUrl: downloadUrl);
        }
      }
    }

    // Update timestamps and status
    profileToUpload = profileToUpload.copyWith(
      uid: uid,
      isSynced: true,
      lastSyncTime: DateTime.now(),
      migrationStatus: 'completed',
    );

    await _firestoreService.saveProfile(profileToUpload);
    return profileToUpload;
  }
}
