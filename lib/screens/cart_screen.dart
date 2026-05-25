import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../core/theme.dart';

import 'checkout_screen.dart';
import 'settings_screen.dart';
import '../widgets/product_image.dart';
import 'notification_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'product_listing_screen.dart';

class CartScreen extends StatelessWidget {
  final bool isLoggedIn;

  const CartScreen({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    // We no longer need a StreamBuilder here because CartProvider now 
    // automatically syncs with Firestore in the background when logged in!
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      drawer: const SettingsScreen(),
      appBar: _buildAppBar(context, cart),
      body: !isLoggedIn ? _buildLoggedOutState(context) : (cart.items.isEmpty ? _buildEmptyState(context) : _buildCartContent(context, cart)),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CartProvider cart) {
    return AppBar(
      backgroundColor: NoorTheme.appBarBg(context),
      elevation: 0,
      centerTitle: true,
      title: Text(
        'NOOR FASHION',
        style: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: NoorTheme.textColor(context),
        ),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, size: 24, color: NoorTheme.textColor(context)),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none_outlined, color: NoorTheme.textColor(context)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                );
              },
            ),
            if (cart.items.isNotEmpty)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF775A19), // secondary
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${cart.items.length}',
                    style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: NoorTheme.textColor(context).withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          Text(
            'YOUR BAG IS EMPTY',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: NoorTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Discover the Atelier collection.',
            style: TextStyle(
              color: NoorTheme.textMuted(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListingScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NoorTheme.textColor(context),
              foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('START SHOPPING', style: TextStyle(fontSize: 10, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedOutState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 80,
              color: NoorTheme.textColor(context).withValues(alpha: 0.1),
            ),
            const SizedBox(height: 24),
            Text(
              'LOGIN TO VIEW BAG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: NoorTheme.textColor(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Sign in to sync your bag across all your devices and checkout faster.',
              style: TextStyle(
                color: NoorTheme.textMuted(context),
                fontSize: 12,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: NoorTheme.textColor(context),
                foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('LOGIN', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: NoorTheme.textColor(context),
                side: BorderSide(color: NoorTheme.textColor(context)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('REGISTER', style: TextStyle(fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartProvider cart) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: 48),
          ...cart.items.map((item) => Column(
            children: [
              _buildCartItem(context, item),
              Divider(color: NoorTheme.border(context), height: 32, thickness: 1), // outline-variant/20
            ],
          )),
          const SizedBox(height: 24),
          _buildOrderSummary(context, cart),
          const SizedBox(height: 80),
          _buildUpsellSection(context),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SHOPPING BAG',
          style: TextStyle(
            color: Color(0xFF775A19), // secondary
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your Selection',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.5,
            color: NoorTheme.textColor(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(BuildContext context, CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Container
        Container(
          width: 100, // Matching mobile sizing
          height: 133,
          decoration: BoxDecoration(
            color: NoorTheme.cardAlt(context),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: ProductImage(imageUrl: item.product.imageUrl),
        ),
        const SizedBox(width: 24),
        // Details
        Expanded(
          child: SizedBox(
            height: 133,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              letterSpacing: -0.2,
                              color: NoorTheme.textColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'SIZE: L | COLOR: BONE WHITE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: NoorTheme.textMuted(context), // on-surface-variant
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: NoorTheme.textMuted(context)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        context.read<CartProvider>().removeFromCart(item.product.id);
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Quantity Selector Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: NoorTheme.iconBg(context), // surface-container-high
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => context.read<CartProvider>().updateQuantity(item.product.id, -1),
                            child: Text('-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context))),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              item.quantity.toString().padLeft(2, '0'),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context)),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.read<CartProvider>().updateQuantity(item.product.id, 1),
                            child: Text('+', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context))),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'LKR ${item.product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: NoorTheme.textColor(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: NoorTheme.cardAlt(context), // surface-container-low
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER SUMMARY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                        color: NoorTheme.textMuted(context), // on-surface-variant
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Standard shipping to Sri Lanka included.',
                      style: TextStyle(
                        fontSize: 10,
                        color: NoorTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: NoorTheme.textMuted(context), // on-surface-variant
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'LKR ',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context)),
                      ),
                      Text(
                        cart.totalAmount.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          color: NoorTheme.textColor(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CheckoutScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NoorTheme.textColor(context),
              foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'PROCEED TO CHECKOUT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock, size: 14, color: NoorTheme.textMuted(context)),
              const SizedBox(width: 8),
              Text(
                'SECURE CHECKOUT POWERED BY STRIPE',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: NoorTheme.textMuted(context),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpsellSection(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: FirestoreService().getProductsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }
        
        final recommendations = snapshot.data!.where((p) => !p.isHero).take(4).toList();
        if (recommendations.isEmpty) return const SizedBox.shrink();

        return Column(
          children: [
            Center(
              child: Text(
                'COMPLETE THE LOOK',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: NoorTheme.textMuted(context), // on-surface-variant
                ),
              ),
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recommendations.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: NoorTheme.iconBg(context),
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0,      0,      0,      1, 0,
                      ]), // Grayscale filter to match HTML default state
                      child: ProductImage(imageUrl: recommendations[index].imageUrl),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      }
    );
  }
}
