import 'dart:async';

import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/favorite_service.dart';
import 'description_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenWishlist;

  const HomeScreen({super.key, required this.onOpenWishlist});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _apiService = ApiService();
  final _authService = AuthService();
  final _favoriteService = FavoriteService();
  StreamSubscription<void>? _wishlistSubscription;

  List<Product> _products = [];
  List<String> _categories = [];
  Set<int> _wishlistIds = {};
  String _selectedCategory = '';
  String _userName = 'Pengguna';
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _loadUser();
    _loadWishlistIds();
    _wishlistSubscription = _favoriteService.onFavoritesChanged.listen((_) {
      _loadWishlistIds();
    });
  }

  @override
  void dispose() {
    _wishlistSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final name = await _authService.getUserName();
    if (mounted && name != null && name.isNotEmpty) {
      setState(() => _userName = name);
    }
  }

  Future<void> _loadWishlistIds() async {
    final ids = await _favoriteService.getFavoriteIds();
    if (mounted) setState(() => _wishlistIds = ids);
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _apiService.getProducts(
        limit: 30,
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
      );
      if (mounted) {
        setState(() {
          _products = result.products;
          if (_selectedCategory.isEmpty) {
            _categories = result.products
                .map((product) => product.category)
                .toSet()
                .toList();
          }
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleWishlist(Product product) async {
    final isSaved = _wishlistIds.contains(product.id);
    if (isSaved) {
      await _favoriteService.removeFavorite(product.id);
    } else {
      await _favoriteService.addFavorite(product);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved ? 'Dihapus dari wishlist' : 'Ditambahkan ke wishlist',
        ),
        backgroundColor: isSaved ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Future<void> _openProduct(Product product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product)),
    );
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ShoppingHub'),
            Text(
              'Halo, $_userName',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Buka wishlist',
            onPressed: widget.onOpenWishlist,
            icon: const Icon(Icons.favorite_border),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'logout', child: Text('Keluar')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.filter_list),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Semua kategori'),
                      ),
                      ..._categories.map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category.replaceAll('-', ' ')),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _selectedCategory = value ?? '');
                      _loadProducts();
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildProductBody()),
        ],
      ),
    );
  }

  Widget _buildProductBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _loadProducts,
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (_products.isEmpty) {
      return const Center(child: Text('Produk tidak ditemukan.'));
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.66,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return _ProductCard(
            product: product,
            isWishlisted: _wishlistIds.contains(product.id),
            onTap: () => _openProduct(product),
            onWishlistTap: () => _toggleWishlist(product),
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onWishlistTap;

  const _ProductCard({
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    product.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 40),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filledTonal(
                      tooltip: isWishlisted
                          ? 'Hapus dari wishlist'
                          : 'Tambah ke wishlist',
                      onPressed: onWishlistTap,
                      icon: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
