import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/favorite_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _apiService = ApiService();
  final _favoriteService = FavoriteService();
  late Future<Product> _productFuture;
  bool _isWishlisted = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _apiService.getProductById(widget.product.id);
    _loadWishlistStatus();
  }

  Future<void> _loadWishlistStatus() async {
    final isWishlisted = await _favoriteService.isFavorite(widget.product.id);
    if (mounted) setState(() => _isWishlisted = isWishlisted);
  }

  Future<void> _toggleWishlist(Product product) async {
    final removing = _isWishlisted;
    if (removing) {
      await _favoriteService.removeFavorite(product.id);
    } else {
      await _favoriteService.addFavorite(product);
    }
    if (!mounted) return;
    setState(() => _isWishlisted = !removing);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          removing ? 'Dihapus dari wishlist' : 'Ditambahkan ke wishlist',
        ),
        backgroundColor: removing ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  void _retry() {
    setState(() {
      _productFuture = _apiService.getProductById(widget.product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          FutureBuilder<Product>(
            future: _productFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return IconButton(
                tooltip: _isWishlisted
                    ? 'Hapus dari wishlist'
                    : 'Tambah ke wishlist',
                onPressed: () => _toggleWishlist(snapshot.data!),
                icon: Icon(
                  _isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: _isWishlisted ? Colors.red : null,
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gagal memuat detail produk:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _retry, child: const Text('Coba lagi')),
                  ],
                ),
              ),
            );
          }

          final product = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: AspectRatio(
                  aspectRatio: 1.15,
                  child: Image.network(
                    product.thumbnail,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 56),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Chip(label: Text(product.category)),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _DetailRow(label: 'Brand', value: product.brand ?? 'Tidak tersedia'),
              _DetailRow(
                label: 'Rating',
                value: '${product.rating.toStringAsFixed(1)} / 5',
              ),
              _DetailRow(
                label: 'Diskon',
                value: '${product.discountPercentage.toStringAsFixed(1)}%',
              ),
              _DetailRow(label: 'Stok', value: '${product.stock}'),
              const SizedBox(height: 20),
              Text('Deskripsi', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(product.description),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _toggleWishlist(product),
                icon: Icon(
                  _isWishlisted ? Icons.favorite : Icons.favorite_border,
                ),
                label: Text(
                  _isWishlisted ? 'Hapus dari Wishlist' : 'Tambah ke Wishlist',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor:
                      _isWishlisted ? Colors.red.shade700 : null,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
