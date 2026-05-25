import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../core/theme.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/product_image.dart';
import 'notification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/login_prompt.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String _selectedSize = 'M';

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 550,
            pinned: true,
            backgroundColor: NoorTheme.appBarBg(context),
            foregroundColor: NoorTheme.textColor(context),
            elevation: 0,
            title: Text(
              'NOOR FASHION',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    color: NoorTheme.textColor(context),
                  ),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: NoorTheme.cardColor(context).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back, size: 20, color: NoorTheme.textColor(context)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: NoorTheme.cardColor(context).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.notifications_none_outlined, size: 20, color: NoorTheme.textColor(context)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationScreen()),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: product.id,
                  child: ProductImage(imageUrl: product.imageUrl),
                ),
              ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                     children: [
                        Text(
                          'COLLECTIONS / ',
                          style: TextStyle(
                            color: NoorTheme.textMuted(context).withValues(alpha: 0.4),
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          product.category.toUpperCase(),
                          style: TextStyle(
                            color: NoorTheme.textMuted(context).withValues(alpha: 0.8),
                            fontSize: 10,
                            letterSpacing: 2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                     ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1.0,
                          height: 1.1,
                          color: NoorTheme.textColor(context),
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ref. N-${product.id}',
                    style: TextStyle(
                      color: NoorTheme.textMuted(context),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'LKR ${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: NoorTheme.textColor(context),
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        'LKR ${(product.price * 1.3).toStringAsFixed(0)}',
                        style: TextStyle(
                          color: NoorTheme.textMuted(context).withValues(alpha: 0.4),
                          fontSize: 16,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: NoorTheme.textColor(context),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          height: 1.6,
                          color: NoorTheme.textColor(context),
                        ),
                  ),
                  const SizedBox(height: 40),
                  _buildSizeSelector(context),
                  const SizedBox(height: 40),
                  _buildDeliveryInfo(context),
                  const SizedBox(height: 160), // Spacing for fabric
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  showLoginPrompt(context);
                } else {
                  context.read<CartProvider>().addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} added to bag'),
                      backgroundColor: NoorTheme.textColor(context),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: NoorTheme.textColor(context),
                foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 18),
                  SizedBox(width: 8),
                  Text('ADD TO CART', style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w900, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Consumer<WishlistProvider>(
              builder: (context, wishlist, child) {
                final isWishlisted = wishlist.isInWishlist(product.id);
                return OutlinedButton(
                  onPressed: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      showLoginPrompt(context);
                    } else {
                      wishlist.toggleWishlist(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isWishlisted ? '${product.name} removed from wishlist' : '${product.name} added to wishlist'),
                          backgroundColor: NoorTheme.textColor(context),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 55),
                    backgroundColor: NoorTheme.iconBg(context),
                    side: BorderSide.none,
                    foregroundColor: NoorTheme.textColor(context),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isWishlisted ? Icons.favorite : Icons.favorite_border, size: 18, color: isWishlisted ? Colors.red : NoorTheme.textColor(context)),
                      const SizedBox(width: 8),
                      Text(isWishlisted ? 'WISHLISTED' : 'WISHLIST', style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.w900, fontSize: 12, color: NoorTheme.textColor(context))),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelector(BuildContext context) {
    final sizes = ['S', 'M', 'L', 'XL', 'XXL'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT SIZE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: NoorTheme.textColor(context),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: sizes.map((size) {
            bool isSelected = size == _selectedSize;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 15),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? NoorTheme.accentGold : NoorTheme.textColor(context).withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? NoorTheme.textColor(context) : Colors.transparent,
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? NoorTheme.background(context) : NoorTheme.textColor(context),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  Widget _buildDeliveryInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NoorTheme.cardAlt(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.local_shipping_outlined, color: NoorTheme.accentGold, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('COMPLIMENTARY SHIPPING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: NoorTheme.textColor(context))),
                    const SizedBox(height: 5),
                    Text('Estimated delivery: 2-4 business days within Colombo.', style: TextStyle(fontSize: 12, color: NoorTheme.textMuted(context))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_outlined, color: NoorTheme.accentGold, size: 24),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AUTHENTICITY GUARANTEED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: NoorTheme.textColor(context))),
                    const SizedBox(height: 5),
                    Text('Each piece is verified by our in-house atelier experts.', style: TextStyle(fontSize: 12, color: NoorTheme.textMuted(context))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
