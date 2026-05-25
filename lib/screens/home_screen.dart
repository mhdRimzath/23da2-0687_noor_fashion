import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product_model.dart';
import '../core/theme.dart';
import '../services/firestore_service.dart';
import '../providers/wishlist_provider.dart';
import 'product_detail_screen.dart';
import 'product_listing_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/profile_provider.dart';
import 'settings_screen.dart';
import 'notification_screen.dart';
import '../widgets/product_image.dart';
import '../widgets/login_prompt.dart';

class HomeScreen extends StatelessWidget {
  final bool isLoggedIn;

  const HomeScreen({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      drawer: const SettingsScreen(),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
                    child: Consumer<ProfileProvider>(
                      builder: (context, profileProvider, child) {
                        final profile = profileProvider.profile;
                        final user = FirebaseAuth.instance.currentUser;
                        final firstName = profile?.fullName.isNotEmpty == true 
                            ? profile!.fullName.split(' ').first 
                            : user?.displayName?.split(' ').first ?? 'Guest';
                        
                        return Text(
                          'Hi $firstName, Welcome to Noor Fashion.',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: NoorTheme.textColor(context).withValues(alpha: 0.7),
                          ),
                        );
                      }
                    ),
                  ),
                if (!isLoggedIn) _buildGuestAuthButtons(context),
                _buildSearchBar(context),
                _buildHeroBanner(context),
                _buildCategoriesSection(context),
                _buildSectionHeader(context, 'Curated Selects'),
                _buildDynamicProductGrid(context),
                const SizedBox(height: 100), // Spacing for bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      backgroundColor: NoorTheme.appBarBg(context),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu, color: NoorTheme.textColor(context)),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
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
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: NoorTheme.textColor(context)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGuestAuthButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NoorTheme.textColor(context),
              foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 2,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text(
              'LOGIN',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register'); 
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: NoorTheme.textColor(context),
              backgroundColor: NoorTheme.background(context),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              side: BorderSide(color: NoorTheme.textColor(context), width: 1),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              elevation: 2,
            ),
            child: const Text(
              'REGISTER',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductListingScreen(autoFocusSearch: true)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: NoorTheme.inputBg(context), // surface-container-high
            borderRadius: BorderRadius.circular(12),
          ),
          child: IgnorePointer(
            child: TextField(
              readOnly: true,
              style: TextStyle(color: NoorTheme.textColor(context)),
              decoration: InputDecoration(
                hintText: 'Search for products...',
                hintStyle: TextStyle(
                  color: NoorTheme.textMuted(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Icon(Icons.search, color: NoorTheme.textMuted(context)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 530,
          width: double.infinity,
          decoration: BoxDecoration(color: NoorTheme.cardAlt(context)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              StreamBuilder<Product?>(
                stream: FirestoreService().getProductStream('20'),
                builder: (context, snapshot) {
                  final bannerImageUrl = snapshot.data?.imageUrl ?? '';
                  return ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.1),
                      BlendMode.darken,
                    ),
                    child: ProductImage(
                      imageUrl: bannerImageUrl,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 32,
                left: 32,
                right: 32,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NEW SEASON ARRIVAL',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 2.0,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'THE ART OF\nRESTRAINT.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: NoorTheme.primaryNavy,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text(
                        'EXPLORE COLLECTION',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final categories = [
      {'name': 'T-Shirts', 'icon': Icons.dry_cleaning},
      {'name': 'Shirts', 'icon': Icons.checkroom},
      {'name': 'Jeans', 'icon': Icons.straighten},
      {'name': 'Shoes', 'icon': Icons.snowshoeing},
      {'name': 'Accessories', 'icon': Icons.watch},
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 12),
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isFirst = index == 0;
            final categoryName = categories[index]['name'] as String;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductListingScreen(initialCategory: categoryName),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: NoorTheme.cardAlt(context), // surface-container-low
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isFirst ? NoorTheme.accentGold : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        categories[index]['icon'] as IconData,
                        color: NoorTheme.textColor(context),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      categoryName.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: isFirst ? NoorTheme.textColor(context) : NoorTheme.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                fontFamily: 'Manrope',
                color: NoorTheme.textColor(context),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductListingScreen()),
              );
            },
            child: const Text(
              'VIEW ALL ITEMS',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF775A19), // secondary
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicProductGrid(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: FirestoreService().getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(color: NoorTheme.textColor(context)),
            ),
          );
        }
        
        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text('No products available.', style: TextStyle(color: NoorTheme.textColor(context))),
            ),
          );
        }

        final double screenWidth = MediaQuery.of(context).size.width;
        final int crossAxisCount = screenWidth > 1200 ? 5 : (screenWidth > 800 ? 4 : (screenWidth > 600 ? 3 : 2));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              if (products.isNotEmpty) _buildHeroProductCard(context, products[0]),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length - 1,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.51,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 32,
                ),
                itemBuilder: (context, index) {
                  return _buildStandardProductCard(context, products[index + 1]);
                },
              ),
              const SizedBox(height: 60),
              Center(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProductListingScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                    side: BorderSide(color: NoorTheme.border(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  child: Text(
                    'LOAD MORE ITEMS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                      color: NoorTheme.textColor(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildHeroProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 4 / 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(imageUrl: product.imageUrl),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Consumer<WishlistProvider>(
                  builder: (context, wishlist, child) {
                    final isWishlisted = wishlist.isInWishlist(product.id);
                    return GestureDetector(
                      onTap: () {
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: NoorTheme.cardColor(context).withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isWishlisted ? Colors.red : NoorTheme.textColor(context),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: NoorTheme.cardColor(context),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(
                    'MUST HAVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: NoorTheme.textColor(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.category.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: NoorTheme.textMuted(context), // outline
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: NoorTheme.textColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'LKR ${product.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: NoorTheme.textMuted(context), // on-surface-variant
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandardProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: ProductImage(imageUrl: product.imageUrl),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Consumer<WishlistProvider>(
                    builder: (context, wishlist, child) {
                      final isWishlisted = wishlist.isInWishlist(product.id);
                      return GestureDetector(
                        onTap: () {
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
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: NoorTheme.cardColor(context).withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: isWishlisted ? Colors.red : NoorTheme.textColor(context),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.category.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: NoorTheme.textMuted(context),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
              color: NoorTheme.textColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'LKR ${product.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: NoorTheme.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}
