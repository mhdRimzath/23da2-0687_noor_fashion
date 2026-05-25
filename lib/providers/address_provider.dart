import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class AddressProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Map<String, dynamic>>>? _addressesSubscription;
  StreamSubscription<User?>? _authSubscription;

  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;

  List<Map<String, dynamic>> get addresses => _addresses;
  bool get isLoading => _isLoading;

  Map<String, dynamic>? get defaultAddress {
    if (_addresses.isEmpty) return null;
    try {
      return _addresses.firstWhere((addr) => addr['isDefault'] == true);
    } catch (e) {
      return _addresses.first;
    }
  }

  AddressProvider() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _addressesSubscription?.cancel();
      if (user != null) {
        _isLoading = true;
        notifyListeners();
        
        _addressesSubscription = _firestoreService.getAddressesStream(user.uid).listen(
          (addresses) {
            _addresses = addresses;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Error loading addresses: $error');
            _isLoading = false;
            notifyListeners();
          },
        );
      } else {
        _addresses = [];
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> addAddress(Map<String, dynamic> addressData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.addAddress(user.uid, addressData);
    }
  }

  Future<void> deleteAddress(String addressId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.deleteAddress(user.uid, addressId);
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firestoreService.setDefaultAddress(user.uid, addressId);
    }
  }

  @override
  void dispose() {
    _addressesSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
