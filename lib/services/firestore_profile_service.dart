import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_model.dart';

class FirestoreProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get the document reference for the user's personal profile data
  DocumentReference _getProfileDoc(String uid) {
    return _db.collection('users').doc(uid).collection('personal').doc('profileData');
  }

  /// Save or update profile data in Firestore
  Future<void> saveProfile(ProfileModel profile) async {
    try {
      // Save to personal/profileData subcollection
      await _getProfileDoc(profile.uid).set(
        profile.toMap(),
        SetOptions(merge: true),
      );
      
      // Also sync key fields back to the root users/{uid} document
      await _db.collection('users').doc(profile.uid).set({
        'name': profile.fullName,
        'email': profile.email,
        'gender': profile.gender,
        'profileImageUrl': profile.profileImageUrl,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save profile to Firestore: $e');
    }
  }

  /// Fetch the profile data from Firestore
  Future<ProfileModel?> getProfile(String uid) async {
    try {
      final doc = await _getProfileDoc(uid).get();
      if (doc.exists && doc.data() != null) {
        return ProfileModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch profile from Firestore: $e');
    }
  }

  /// Real-time stream of the profile data
  Stream<ProfileModel?> getProfileStream(String uid) {
    return _getProfileDoc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return ProfileModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Update specific fields in the profile
  Future<void> updateProfileFields(String uid, Map<String, dynamic> data) async {
    try {
      // Update personal/profileData subcollection
      await _getProfileDoc(uid).update(data);
      
      // Mirror allowed fields to the root document
      final rootData = <String, dynamic>{};
      if (data.containsKey('fullName')) rootData['name'] = data['fullName'];
      if (data.containsKey('email')) rootData['email'] = data['email'];
      if (data.containsKey('gender')) rootData['gender'] = data['gender'];
      if (data.containsKey('profileImageUrl')) rootData['profileImageUrl'] = data['profileImageUrl'];
      
      if (rootData.isNotEmpty) {
        await _db.collection('users').doc(uid).set(rootData, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to update profile fields: $e');
    }
  }
}
