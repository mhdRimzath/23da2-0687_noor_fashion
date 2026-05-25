import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../core/theme.dart';
import '../screens/product_detail_screen.dart';

class ProductSearchDelegate extends SearchDelegate<String> {
  @override
  String get searchFieldLabel => 'Search Collections...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: NoorTheme.primaryNavy),
        titleTextStyle: TextStyle(color: NoorTheme.primaryNavy, fontSize: 16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: NoorTheme.primaryNavy.withValues(alpha: 0.5)),
      ),
      scaffoldBackgroundColor: NoorTheme.backgroundChalk,
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: FirestoreService().getProductsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: NoorTheme.primaryNavy));
        }

        final allProducts = snapshot.data ?? [];
        final results = allProducts.where((product) {
          final queryLower = query.toLowerCase();
          final nameLower = product.name.toLowerCase();
          final categoryLower = product.category.toLowerCase();
          return nameLower.contains(queryLower) || categoryLower.contains(queryLower);
        }).toList();

        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 60, color: NoorTheme.primaryNavy.withValues(alpha: 0.2)),
                const SizedBox(height: 16),
                const Text(
                  'NO RESULTS FOUND',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                    color: NoorTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different keyword.',
                  style: TextStyle(color: NoorTheme.primaryNavy.withValues(alpha: 0.6)),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          itemCount: results.length,
          separatorBuilder: (context, _) => const Divider(height: 32, color: Color(0xFFEBE8E3)),
          itemBuilder: (context, index) {
            final product = results[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(product: product),
                  ),
                );
              },
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F3EE),
                  borderRadius: BorderRadius.circular(4),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                product.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              subtitle: Text(
                product.category.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: Color(0xFF76777D),
                ),
              ),
              trailing: Text(
                'LKR ${product.price.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            );
          },
        );
      }
    );
  }
}
