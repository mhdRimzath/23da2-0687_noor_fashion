import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];
  StreamSubscription<List<Map<String, dynamic>>>? _cartSubscription;

  CartProvider() {
    // Listen to Auth state changes to manage the cart subscription
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // User logged in: Subscribe to their Firestore cart stream
        _cartSubscription?.cancel();
        _cartSubscription = FirestoreService().getCartStream(user.uid).listen((itemsData) {
          _items = itemsData.map((data) {
            return CartItem(
              product: Product(
                id: data['productId'] ?? '',
                name: data['name'] ?? '',
                description: data['description'] ?? '',
                price: (data['price'] as num?)?.toDouble() ?? 0.0,
                imageUrl: data['imageUrl'] ?? '',
                category: data['category'] ?? '',
                isHero: false,
              ),
              quantity: (data['quantity'] as num?)?.toInt() ?? 1,
            );
          }).toList();
          notifyListeners();
        });
      } else {
        // User logged out: clear subscription and local items
        _cartSubscription?.cancel();
        _items.clear();
        notifyListeners();
      }
    });
  }

  // Constructor to create an instance initialized with items (useful for StreamBuilder wrapping)
  CartProvider.withItems(List<CartItem> items) {
    _items = List.from(items);
  }

  List<CartItem> get items => _items;

  double get totalAmount {
    return _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void addToCart(Product product) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().addToCart(user.uid, product);
    } else {
      final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
      if (existingIndex >= 0) {
        _items[existingIndex].quantity += 1;
      } else {
        _items.add(CartItem(product: product));
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().removeFromCart(user.uid, productId);
    } else {
      _items.removeWhere((item) => item.product.id == productId);
      notifyListeners();
    }
  }

  void updateQuantity(String productId, int delta) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().updateCartQuantity(user.uid, productId, delta);
    } else {
      final index = _items.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        _items[index].quantity += delta;
        if (_items[index].quantity <= 0) {
          _items.removeAt(index);
        }
        notifyListeners();
      }
    }
  }

  void clear() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirestoreService().clearCart(user.uid);
    } else {
      _items.clear();
      notifyListeners();
    }
  }

  Future<void> migrateGuestCartToFirestore(String userId) async {
    if (_items.isEmpty) return;
    
    // Create a copy of items to migrate
    final itemsToMigrate = List<CartItem>.from(_items);
    
    // Clear local items
    _items.clear();
    notifyListeners();

    // Add each item to Firestore
    for (final item in itemsToMigrate) {
      for (int i = 0; i < item.quantity; i++) {
        try {
          await FirestoreService()
              .addToCart(userId, item.product)
              .timeout(const Duration(seconds: 4));
        } catch (e) {
          debugPrint('Cart migration for item timed out or failed: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
