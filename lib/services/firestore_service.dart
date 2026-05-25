import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // ─── Products ────────────────────────────────────────────────────────
  /// Real-time stream of all products from the 'products' collection.
  Stream<List<Product>> getProductsStream() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: data['id'] ?? doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] ?? '',
          category: data['category'] ?? '',
          isHero: data['isHero'] ?? false,
        );
      }).toList();
    });
  }

  /// Real-time stream of a single product by its field ID or document ID.
  Stream<Product?> getProductStream(String id) {
    // We check if the id field matches either the string or the integer representation
    final intId = int.tryParse(id);
    final query = intId != null
        ? _db.collection('products').where('id', whereIn: [id, intId]).limit(1)
        : _db.collection('products').where('id', isEqualTo: id).limit(1);

    return query.snapshots().asyncMap((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        final data = doc.data();
        return Product(
          id: data['id']?.toString() ?? doc.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] ?? '',
          category: data['category'] ?? '',
          isHero: data['isHero'] ?? false,
        );
      }
      
      // Fallback: Check if it's the document ID itself
      final docFallback = await _db.collection('products').doc(id).get();
      if (docFallback.exists) {
        final data = docFallback.data()!;
        return Product(
          id: data['id']?.toString() ?? docFallback.id,
          name: data['name'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] as num?)?.toDouble() ?? 0.0,
          imageUrl: data['imageUrl'] ?? '',
          category: data['category'] ?? '',
          isHero: data['isHero'] ?? false,
        );
      }
      
      return null;
    });
  }

  // ─── Cart ────────────────────────────────────────────────────────────
  /// Real-time stream of cart items for a specific user.
  Stream<List<Map<String, dynamic>>> getCartStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Add a product to the user's Firestore cart.
  Future<void> addToCart(String userId, Product product) async {
    final cartRef =
        _db.collection('users').doc(userId).collection('cart').doc(product.id);
    final doc = await cartRef.get();
    if (doc.exists) {
      await cartRef.update({'quantity': FieldValue.increment(1)});
    } else {
      await cartRef.set({
        'productId': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'description': product.description,
        'quantity': 1,
      });
    }
  }

  /// Remove a product from the user's Firestore cart.
  Future<void> removeFromCart(String userId, String productId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  /// Update the quantity of a cart item in Firestore.
  Future<void> updateCartQuantity(
      String userId, String productId, int delta) async {
    final cartRef =
        _db.collection('users').doc(userId).collection('cart').doc(productId);
    final doc = await cartRef.get();
    if (doc.exists) {
      final currentQty = (doc.data()?['quantity'] as num?)?.toInt() ?? 1;
      final newQty = currentQty + delta;
      if (newQty <= 0) {
        await cartRef.delete();
      } else {
        await cartRef.update({'quantity': newQty});
      }
    }
  }

  /// Clear all items in the user's Firestore cart.
  Future<void> clearCart(String userId) async {
    final cartDocs =
        await _db.collection('users').doc(userId).collection('cart').get();
    final batch = _db.batch();
    for (final doc in cartDocs.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ─── Wishlist ────────────────────────────────────────────────────────
  /// Real-time stream of wishlist items for a specific user.
  Stream<List<Map<String, dynamic>>> getWishlistStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }

  /// Toggle a product in the user's Firestore wishlist.
  Future<void> toggleWishlistItem(String userId, Product product) async {
    final wishlistRef = _db
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(product.id);
        
    final doc = await wishlistRef.get();
    if (doc.exists) {
      await wishlistRef.delete();
    } else {
      await wishlistRef.set({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'description': product.description,
        'isHero': product.isHero,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ─── Orders ──────────────────────────────────────────────────────────
  /// Place an order: writes to /orders and clears the user's cart.
  Future<void> placeOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double shippingFee,
    required double tax,
    required double totalAmount,
    required Map<String, String> shippingAddress,
    required String paymentMethod,
  }) async {
    await _db.collection('orders').add({
      'userId': userId,
      'items': items,
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'tax': tax,
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'status': 'Processing',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await clearCart(userId);
  }

  /// Real-time stream of orders for a specific user, sorted by date descending.
  Stream<List<Map<String, dynamic>>> getOrdersStream(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        final data = doc.data();
        data['orderId'] = doc.id;
        return data;
      }).toList();
      
      // Sort orders locally descending by date to avoid requiring a composite index in Firestore
      orders.sort((a, b) {
        final aTime = (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });
      
      return orders;
    });
  }

  // ─── Users ───────────────────────────────────────────────────────────
  /// Create a user document in Firestore on registration.
  Future<void> createUserDocument({
    required String userId,
    required String name,
    required String email,
  }) async {
    await _db.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'gender': 'Male',
      'profileImageUrl': 'assets/images/static_23.jpg',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Migrates an existing authenticated user's profile to Firestore if it doesn't exist.
  Future<void> migrateCurrentUserProfile(User user) async {
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await createUserDocument(
        userId: user.uid,
        name: user.displayName ?? 'Fashion Enthusiast',
        email: user.email ?? 'no-reply@noorfashion.com',
      );
      debugPrint('Migrated profile for user ${user.uid}');
    }
  }

  /// Real-time stream of a user's profile data.
  Stream<Map<String, dynamic>?> getUserStream(String userId) {
    return _db.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return doc.data();
      }
      return null;
    });
  }

  // ─── Addresses ───────────────────────────────────────────────────────
  /// Real-time stream of user addresses.
  Stream<List<Map<String, dynamic>>> getAddressesStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Add a new address for the user.
  Future<void> addAddress(String userId, Map<String, dynamic> addressData) async {
    final addressesRef = _db.collection('users').doc(userId).collection('addresses');
    
    // If this is the first address being added, or it's explicitly set as default
    if (addressData['isDefault'] == true) {
      // First, remove default status from all other addresses
      final existingAddresses = await addressesRef.where('isDefault', isEqualTo: true).get();
      final batch = _db.batch();
      for (final doc in existingAddresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }
      await batch.commit();
    } else {
      // Check if any addresses exist. If not, make this one the default.
      final existing = await addressesRef.limit(1).get();
      if (existing.docs.isEmpty) {
        addressData['isDefault'] = true;
      }
    }

    addressData['createdAt'] = FieldValue.serverTimestamp();
    await addressesRef.add(addressData);
  }

  /// Delete an address.
  Future<void> deleteAddress(String userId, String addressId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('addresses')
        .doc(addressId)
        .delete();
  }

  /// Set an address as default.
  Future<void> setDefaultAddress(String userId, String addressId) async {
    final addressesRef = _db.collection('users').doc(userId).collection('addresses');
    
    // Remove default status from all existing addresses
    final existingAddresses = await addressesRef.where('isDefault', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in existingAddresses.docs) {
      batch.update(doc.reference, {'isDefault': false});
    }
    
    // Set the selected address as default
    batch.update(addressesRef.doc(addressId), {'isDefault': true});
    await batch.commit();
  }

  // ─── Settings ────────────────────────────────────────────────────────
  /// Real-time stream of user settings.
  Stream<Map<String, dynamic>?> getSettingsStream(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  /// Real-time stream of global home settings (e.g. banner).
  Stream<Map<String, dynamic>?> getHomeSettingsStream() {
    return _db
        .collection('settings')
        .doc('home')
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  /// Update user settings.
  Future<void> updateSettings(String userId, Map<String, dynamic> settingsData) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('settings')
        .doc('preferences')
        .set(settingsData, SetOptions(merge: true));
  }
}
