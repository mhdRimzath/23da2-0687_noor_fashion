import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class WishlistProvider extends ChangeNotifier {
  List<Product> _items = [];
  StreamSubscription<List<Map<String, dynamic>>>? _wishlistSubscription;

  WishlistProvider() {
    // Listen to Auth state changes to manage the wishlist subscription
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // User logged in: Subscribe to their Firestore wishlist stream
        _wishlistSubscription?.cancel();
        _wishlistSubscription = FirestoreService().getWishlistStream(user.uid).listen((itemsData) {
          _items = itemsData.map((data) {
            return Product(
              id: data['id'] ?? '',
              name: data['name'] ?? '',
              description: data['description'] ?? '',
              price: (data['price'] as num?)?.toDouble() ?? 0.0,
              imageUrl: data['imageUrl'] ?? '',
              category: data['category'] ?? '',
              isHero: data['isHero'] ?? false,
            );
          }).toList();
          notifyListeners();
        });
      } else {
        // User logged out: clear subscription and local items
        _wishlistSubscription?.cancel();
        _items.clear();
        notifyListeners();
      }
    });
  }

  List<Product> get items => _items;

  bool isInWishlist(String productId) {
    return _items.any((item) => item.id == productId);
  }

  void toggleWishlist(Product product) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().toggleWishlistItem(user.uid, product);
    } else {
      final existingIndex = _items.indexWhere((item) => item.id == product.id);
      if (existingIndex >= 0) {
        _items.removeAt(existingIndex);
      } else {
        _items.add(product);
      }
      notifyListeners();
    }
  }

  Future<void> migrateGuestWishlistToFirestore(String userId) async {
    if (_items.isEmpty) return;
    
    // Create a copy of items to migrate
    final itemsToMigrate = List<Product>.from(_items);
    
    // Clear local items
    _items.clear();
    notifyListeners();

    // Add each item to Firestore
    for (final product in itemsToMigrate) {
      // Toggle it to add it if it doesn't exist
      // Since it's a migration, it's safer to just set it to avoid toggling it off if it already exists
      // But toggleWishlist will remove it if it exists. We should write a specific add method, or use toggle and check first.
      // Alternatively, we can just use the toggle logic but ensuring it's an add.
      // Let's check if it exists in stream. This is simpler:
      final exists = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(product.id)
        .get()
        .then((doc) => doc.exists);
        
      if (!exists) {
        await FirestoreService().toggleWishlistItem(userId, product);
      }
    }
  }

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }
}
