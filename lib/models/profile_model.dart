import 'dart:convert';

class ProfileModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final String dob;
  final String profileImageUrl;
  final String localImagePath;
  final String profileImageBase64;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSyncTime;
  final String deviceId;
  final bool isSynced;
  final String migrationStatus; // pending, syncing, completed, failed

  ProfileModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.dob,
    required this.profileImageUrl,
    required this.localImagePath,
    required this.profileImageBase64,
    required this.createdAt,
    required this.updatedAt,
    this.lastSyncTime,
    required this.deviceId,
    required this.isSynced,
    this.migrationStatus = 'pending',
  });

  ProfileModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phone,
    String? address,
    String? gender,
    String? dob,
    String? profileImageUrl,
    String? localImagePath,
    String? profileImageBase64,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSyncTime,
    String? deviceId,
    bool? isSynced,
    String? migrationStatus,
  }) {
    return ProfileModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      localImagePath: localImagePath ?? this.localImagePath,
      profileImageBase64: profileImageBase64 ?? this.profileImageBase64,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      deviceId: deviceId ?? this.deviceId,
      isSynced: isSynced ?? this.isSynced,
      migrationStatus: migrationStatus ?? this.migrationStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'dob': dob,
      'profileImageUrl': profileImageUrl,
      'localImagePath': localImagePath,
      'profileImageBase64': profileImageBase64,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'lastSyncTime': lastSyncTime?.millisecondsSinceEpoch,
      'deviceId': deviceId,
      'isSynced': isSynced,
      'migrationStatus': migrationStatus,
    };
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      gender: map['gender'] ?? '',
      dob: map['dob'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      localImagePath: map['localImagePath'] ?? '',
      profileImageBase64: map['profileImageBase64'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] ?? DateTime.now().millisecondsSinceEpoch),
      lastSyncTime: map['lastSyncTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['lastSyncTime']) : null,
      deviceId: map['deviceId'] ?? '',
      isSynced: map['isSynced'] ?? false,
      migrationStatus: map['migrationStatus'] ?? 'pending',
    );
  }

  String toJson() => json.encode(toMap());

  factory ProfileModel.fromJson(String source) => ProfileModel.fromMap(json.decode(source));
}
