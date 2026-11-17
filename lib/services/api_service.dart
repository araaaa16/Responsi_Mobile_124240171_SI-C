import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  static const String _baseUrl = 'https://dummyjson.com/products';

  Future<ProductResponse> getProducts({
    int limit = 20,
    int skip = 0,
    String? category,
  }) async {
    final path = category == null || category.isEmpty
        ? _baseUrl
        : '$_baseUrl/category/${Uri.encodeComponent(category)}';
    final uri = Uri.parse(path).replace(
      queryParameters: {'limit': '$limit', 'skip': '$skip'},
    );
    final json = await _getJson(uri);
    return ProductResponse.fromJson(json);
  }

  Future<Product> getProductById(int id) async {
    final json = await _getJson(Uri.parse('$_baseUrl/$id'));
    return Product.fromJson(json);
  }

  Future<List<String>> getCategories() async {
    final uri = Uri.parse('$_baseUrl/category-list');
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }

    return (jsonDecode(response.body) as List<dynamic>).cast<String>();
  }

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Request failed (${response.statusCode}): $uri');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
