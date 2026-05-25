import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/theme.dart';
import '../services/firestore_service.dart';
import 'product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'notification_screen.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/product_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/login_prompt.dart';

class ProductListingScreen extends StatefulWidget {
  final String? initialCategory;
  final bool autoFocusSearch;
  
  const ProductListingScreen({super.key, this.initialCategory, this.autoFocusSearch = false});

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All Items';
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late Stream<List<Product>> _productsStream;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _productsStream = FirestoreService().getProductsStream();
    
    if (widget.initialCategory != null && widget.initialCategory!.isNotEmpty) {
      _searchQuery = widget.initialCategory!;
      _searchController.text = _searchQuery;
    }
    
    if (widget.autoFocusSearch) {
      _searchFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  final List<String> _filters = ['All Items', 'Outerwear', 'Footwear', 'Basics'];

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    return allProducts.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            product.category.toLowerCase().contains(_searchQuery.toLowerCase());
      
      bool matchesFilter = true;
      if (_selectedFilter != 'All Items') {
        if (_selectedFilter == 'Outerwear') {
          matchesFilter = product.category.toLowerCase().contains('jacket');
        } else if (_selectedFilter == 'Footwear') {
          matchesFilter = product.category.toLowerCase().contains('shoe') || product.category.toLowerCase().contains('boot');
        } else if (_selectedFilter == 'Basics') {
          matchesFilter = product.category.toLowerCase().contains('shirt') || product.category.toLowerCase().contains('jean') || product.category.toLowerCase().contains('tee');
        }
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoorTheme.background(context),
      appBar: _buildAppBar(context),
      body: StreamBuilder<List<Product>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return Center(child: CircularProgressIndicator(color: NoorTheme.textColor(context)));
          }
          final products = snapshot.data ?? [];
          final filteredProducts = _getFilteredProducts(products);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroHeader(context),
                      const SizedBox(height: 32),
                      _buildSearchBar(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyFilterDelegate(
                  child: _buildFiltersBar(context),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 100),
                sliver: _buildDynamicBentoGrid(context, filteredProducts),
              ),
            ],
          );
        }
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: NoorTheme.textColor(context)),
        onPressed: () => Navigator.pop(context),
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

  Widget _buildHeroHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NEW SEASON 2026',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF775A19), // secondary
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ESSENTIAL\nMAN.',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                      letterSpacing: -1.5,
                      color: NoorTheme.textColor(context),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 140,
              child: Text(
                'Curated silhouettes for the modern masculine wardrobe. Minimalist design meets uncompromising quality.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: NoorTheme.textMuted(context), // on-surface-variant
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NoorTheme.inputBg(context), // surface-container-high
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
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
    );
  }

  Widget _buildFiltersBar(BuildContext context) {
    return Container(
      color: NoorTheme.background(context).withValues(alpha: 0.95),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Options buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: NoorTheme.iconBg(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.tune, size: 14, color: NoorTheme.textColor(context)),
                  const SizedBox(width: 8),
                  Text('Filter', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: NoorTheme.iconBg(context),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text('Sort: Popularity', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context))),
                  const SizedBox(width: 4),
                  Icon(Icons.expand_more, size: 16, color: NoorTheme.textColor(context)),
                ],
              ),
            ),
            const SizedBox(width: 24),
            // Text filters mapping
            ..._filters.map((filter) {
              final isSelected = _selectedFilter == filter;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        filter.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: isSelected ? NoorTheme.textColor(context) : NoorTheme.textMuted(context),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          height: 2,
                          width: filter.length * 6.0,
                          color: NoorTheme.textColor(context),
                        )
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // A custom Sliver builder that constructs the exact bento-styled layout 
  Widget _buildDynamicBentoGrid(BuildContext context, List<Product> prods) {
    if (prods.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState(context));
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 1200 ? 5 : (screenWidth > 800 ? 4 : (screenWidth > 600 ? 3 : 2));

    List<Widget> layoutBlocks = [];
    int index = 0;

    // Block 1: Product 1 (Hero Full Width 16:9)
    if (index < prods.length) {
      layoutBlocks.add(_buildProductCardHero(context, prods[index]));
      layoutBlocks.add(const SizedBox(height: 32));
      index++;
    }

    Widget buildRow(List<Product> rowProds) {
       return Row(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           for (int i = 0; i < crossAxisCount; i++) ...[
             if (i > 0) const SizedBox(width: 16),
             Expanded(child: i < rowProds.length ? _buildStandardProductCard(context, rowProds[i]) : const SizedBox()),
           ],
         ],
       );
    }

    // Block 2 & 3: Standard Rows (we use loop for 2 rows)
    for (int r = 0; r < 2; r++) {
      if (index < prods.length) {
        List<Product> rowProds = [];
        for (int i = 0; i < crossAxisCount && index < prods.length; i++) {
          rowProds.add(prods[index++]);
        }
        layoutBlocks.add(buildRow(rowProds));
        layoutBlocks.add(const SizedBox(height: 32));
      }
    }

    // Block 4: Jumbo Vertical Full Width
    if (index < prods.length) {
      layoutBlocks.add(_buildProductCardJumbo(context, prods[index]));
      layoutBlocks.add(const SizedBox(height: 32));
      index++;
    }

    // Block 5: Remaining products as standard grid
    while (index < prods.length) {
      List<Product> rowProds = [];
      for (int i = 0; i < crossAxisCount && index < prods.length; i++) {
        rowProds.add(prods[index++]);
      }
      layoutBlocks.add(buildRow(rowProds));
      layoutBlocks.add(const SizedBox(height: 32));
    }
    
    layoutBlocks.add(
      Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 40),
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: NoorTheme.textColor(context),
              foregroundColor: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'LOAD MORE ITEMS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2.0),
            ),
          ),
        ),
      ),
    );

    return SliverList(
      delegate: SliverChildListDelegate(layoutBlocks),
    );
  }

  Widget _buildProductCardHero(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => _navToDetail(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9, // Native mapping to HTML aspect-[16/9]
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ProductImage(imageUrl: product.imageUrl),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Consumer<WishlistProvider>(
                  builder: (context, wishlist, child) {
                    final isWishlisted = wishlist.isInWishlist(product.id);
                    return GestureDetector(
                      onTap: () {
                        if (FirebaseAuth.instance.currentUser == null) {
                          showLoginPrompt(context);
                        } else {
                          wishlist.toggleWishlist(product);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: NoorTheme.cardColor(context).withValues(alpha: 0.9),
                          shape: BoxShape.circle,
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
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: NoorTheme.textColor(context),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'NEW ARRIVAL',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: NoorTheme.isDark(context) ? NoorTheme.surfaceDark : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: NoorTheme.textColor(context)),
                  ),
                  Text(
                    product.category.toUpperCase(),
                    style: TextStyle(fontSize: 12, color: NoorTheme.textMuted(context)), // on-surface-variant
                  ),
                ],
              ),
              Text(
                'LKR ${product.price.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: NoorTheme.textColor(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCardJumbo(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => _navToDetail(product),
      child: Container(
        height: 600, // min-h-[600px] natively mapped
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: NoorTheme.cardAlt(context),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProductImage(imageUrl: product.imageUrl),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                ),
              ),
            ),
            Positioned(
              bottom: 32,
              left: 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: const BoxDecoration(color: Color(0xFF775A19)),
                    child: const Text(
                      'LIMITED EDITION',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3.0),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 250,
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.0,
                        letterSpacing: -1.0,
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LKR ${product.price.toStringAsFixed(0)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandardProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => _navToDetail(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ProductImage(imageUrl: product.imageUrl),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.2,
                        color: NoorTheme.textColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: NoorTheme.textMuted(context), // outline
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<WishlistProvider>(
                builder: (context, wishlist, child) {
                  final isWishlisted = wishlist.isInWishlist(product.id);
                  return GestureDetector(
                    onTap: () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        showLoginPrompt(context);
                      } else {
                        wishlist.toggleWishlist(product);
                      }
                    },
                    child: Icon(
                      isWishlisted ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: isWishlisted ? Colors.red : NoorTheme.textMuted(context),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'LKR ${product.price.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: NoorTheme.textColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: NoorTheme.textColor(context).withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'NOTHING FOUND',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: NoorTheme.textColor(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No items match your filter criteria.',
              style: TextStyle(color: NoorTheme.textMuted(context)),
            )
          ],
        ),
      ),
    );
  }

  void _navToDetail(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }
}

class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyFilterDelegate({required this.child});

  @override
  double get minExtent => 60.0;

  @override
  double get maxExtent => 60.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
