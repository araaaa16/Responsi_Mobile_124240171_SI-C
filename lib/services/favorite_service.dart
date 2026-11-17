import 'dart:async';

import '../models/product_model.dart';
import 'hive_helper.dart';

class FavoriteService {
  static final FavoriteService _instance = FavoriteService._internal();

  factory FavoriteService() => _instance;

  FavoriteService._internal();

  final _favoritesStreamController = StreamController<void>.broadcast();

  Stream<void> get onFavoritesChanged => _favoritesStreamController.stream;

  Future<List<Product>> getFavorites() async {
    return HiveHelper.wishlistBox.values
        .map(
          (item) => Product.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<Set<int>> getFavoriteIds() async {
    return HiveHelper.wishlistBox.keys.cast<int>().toSet();
  }

  Future<bool> isFavorite(int productId) async {
    return HiveHelper.wishlistBox.containsKey(productId);
  }

  Future<void> addFavorite(Product product) async {
    await HiveHelper.wishlistBox.put(product.id, product.toJson());
    _favoritesStreamController.add(null);
  }

  Future<void> removeFavorite(int productId) async {
    await HiveHelper.wishlistBox.delete(productId);
    _favoritesStreamController.add(null);
  }
}
