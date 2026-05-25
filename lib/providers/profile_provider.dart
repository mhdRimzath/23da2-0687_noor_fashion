import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/profile_model.dart';
import '../repositories/migration_repository.dart';
import '../utils/sync_manager.dart';
import '../services/connectivity_service.dart';

class ProfileProvider extends ChangeNotifier {
  final MigrationRepository _repository;
  final ConnectivityService _connectivityService;
  
  ProfileModel? _profile;
  bool _isLoading = false;
  String _error = '';
  StreamSubscription? _connectivitySub;

  ProfileProvider({
    required MigrationRepository repository,
    required ConnectivityService connectivityService,
  })  : _repository = repository,
        _connectivityService = connectivityService {
    _initConnectivityListener();
  }

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String get error => _error;

  void _initConnectivityListener() {
    _connectivitySub = _connectivityService.connectionStream.listen((isConnected) {
      if (isConnected && _profile != null && !_profile!.isSynced) {
        // Auto-retry sync when connection is restored
        retrySync();
      }
    });
  }

  /// Initial load or migrate on login
  Future<void> loadAndMigrateProfile(String uid) async {
    if (uid.isEmpty) return; // Do nothing if logged out

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // 1. Load local profile or create empty one
      ProfileModel localProfile = await _repository.getLocalProfile() ?? _createEmptyProfile(uid);

      // 2. Try to sync/migrate
      if (await _connectivityService.isConnected()) {
        _profile = await _repository.migrateAndSyncProfile(uid, localProfile);
      } else {
        _profile = localProfile;
        _error = 'Offline mode. Changes will sync when online.';
      }
    } catch (e) {
      _error = e.toString();
      _profile = await _repository.getLocalProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update local profile and queue sync
  Future<void> updateProfile(ProfileModel updatedProfile) async {
    _profile = updatedProfile.copyWith(
      updatedAt: DateTime.now(),
      isSynced: false,
      migrationStatus: 'pending',
    );
    notifyListeners();

    await _repository.saveLocalProfile(_profile!);

    SyncManager().enqueue(() => retrySync());
  }

  /// Retry a failed sync
  Future<void> retrySync() async {
    if (_profile == null || _profile!.isSynced) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (!await _connectivityService.isConnected()) return;

    try {
      _profile = _profile!.copyWith(migrationStatus: 'syncing');
      notifyListeners();

      _profile = await _repository.migrateAndSyncProfile(user.uid, _profile!);
      _error = '';
    } catch (e) {
      _error = 'Sync failed. Will retry later.';
      _profile = _profile!.copyWith(migrationStatus: 'failed');
    } finally {
      notifyListeners();
    }
  }

  ProfileModel _createEmptyProfile(String uid) {
    return ProfileModel(
      uid: uid,
      fullName: '',
      email: '',
      phone: '',
      address: '',
      gender: '',
      dob: '',
      profileImageUrl: '',
      localImagePath: '',
      profileImageBase64: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deviceId: 'device_${DateTime.now().millisecondsSinceEpoch}',
      isSynced: false,
      migrationStatus: 'pending',
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
