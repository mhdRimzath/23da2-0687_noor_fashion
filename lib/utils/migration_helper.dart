import '../models/profile_model.dart';

class MigrationHelper {
  /// Compares local and remote profiles and returns the most up-to-date merged profile.
  /// Strategy: 
  /// - Keep the one with the latest `updatedAt` timestamp.
  /// - Alternatively, you could merge field-by-field.
  static ProfileModel mergeProfiles({
    required ProfileModel local,
    required ProfileModel remote,
  }) {
    if (local.updatedAt.isAfter(remote.updatedAt)) {
      // Local is newer. But keep the remote profileImageUrl if local doesn't have a new one uploaded yet
      return local.copyWith(
        profileImageUrl: local.profileImageUrl.isNotEmpty ? local.profileImageUrl : remote.profileImageUrl,
      );
    } else {
      // Remote is newer or same. Keep remote but retain localImagePath if we need it for offline display
      return remote.copyWith(
        localImagePath: remote.localImagePath.isEmpty ? local.localImagePath : remote.localImagePath,
      );
    }
  }

  /// Determines if an upload is necessary by comparing timestamps
  static bool requiresUpload(ProfileModel local, ProfileModel? remote) {
    if (remote == null) return true;
    return local.updatedAt.isAfter(remote.updatedAt);
  }
}
