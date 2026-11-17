import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/favorite_service.dart';
import 'description_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final _favoriteService = FavoriteService();
  StreamSubscription<void>? _wishlistSubscription;
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
    _wishlistSubscription = _favoriteService.onFavoritesChanged.listen((_) {
      _loadWishlist();
    });
  }

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadWishlist() async {
    try {
      final products = await _favoriteService.getFavorites();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = error.toString();
        });
      }
    }
  }

  Future<void> _openProduct(Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product),
      ),
    );
    _loadWishlist();
  }

  Future<void> _removeProduct(Product product) async {
    await _favoriteService.removeFavorite(product.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} dihapus dari wishlist'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _products.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border, size: 52),
                          SizedBox(height: 12),
                          Text('Wishlist kamu masih kosong.'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadWishlist,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _products.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Card(
                            child: ListTile(
                              onTap: () => _openProduct(product),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  product.thumbnail,
                                  width: 58,
                                  height: 58,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(
                                    width: 58,
                                    height: 58,
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                              title: Text(
                                product.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                '${product.category}  •  \$${product.price.toStringAsFixed(2)}',
                              ),
                              trailing: IconButton(
                                tooltip: 'Hapus dari wishlist',
                                onPressed: () => _removeProduct(product),
                                icon: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
