import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../features/home/data/models/product_model.dart';

class ProductCacheService {
  static const String _homeProductsCacheKey = 'home_products_cache';
  static const String _categoryProductsCacheKey = 'category_products_cache_';
  static const String _cacheTimestampKey = 'cache_timestamp_';

  final SharedPreferences _prefs;

  ProductCacheService(this._prefs);

  Future<void> cacheHomeProducts(List<ProductModel> products) async {
    try {
      final jsonList = products.map((p) => p.toJson()).toList();
      await _prefs.setString(
        _homeProductsCacheKey,
        jsonEncode(jsonList),
      );
      await _prefs.setInt(
        '${_cacheTimestampKey}home',
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint('✓ Cached ${products.length} home products');
    } catch (e) {
      debugPrint('✗ Failed to cache home products: $e');
    }
  }

  Future<List<ProductModel>?> getHomeProductsCache() async {
    try {
      final cached = _prefs.getString(_homeProductsCacheKey);
      if (cached == null) return null;

      final jsonList = jsonDecode(cached) as List<dynamic>;
      final products = jsonList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      debugPrint(
        '✓ Retrieved ${products.length} products from home cache',
      );
      return products;
    } catch (e) {
      debugPrint('✗ Failed to retrieve home products from cache: $e');
      return null;
    }
  }

  Future<void> cacheCategoryProducts(
    String categorySlug,
    List<ProductModel> products,
  ) async {
    try {
      final jsonList = products.map((p) => p.toJson()).toList();
      final key = '$_categoryProductsCacheKey$categorySlug';
      await _prefs.setString(key, jsonEncode(jsonList));
      await _prefs.setInt(
        '${_cacheTimestampKey}category_$categorySlug',
        DateTime.now().millisecondsSinceEpoch,
      );
      debugPrint(
        '✓ Cached ${products.length} products for category: $categorySlug',
      );
    } catch (e) {
      debugPrint('✗ Failed to cache category products: $e');
    }
  }

  Future<List<ProductModel>?> getCategoryProductsCache(
    String categorySlug,
  ) async {
    try {
      final key = '$_categoryProductsCacheKey$categorySlug';
      final cached = _prefs.getString(key);
      if (cached == null) return null;

      final jsonList = jsonDecode(cached) as List<dynamic>;
      final products = jsonList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      debugPrint(
        '✓ Retrieved ${products.length} products from category cache',
      );
      return products;
    } catch (e) {
      debugPrint(
        '✗ Failed to retrieve category products from cache: $e',
      );
      return null;
    }
  }

  Future<void> clearExpiredCache({Duration expiryDuration = const Duration(hours: 1)}) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final keys = _prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_cacheTimestampKey)) {
          final timestamp = _prefs.getInt(key) ?? 0;
          final age = now - timestamp;

          if (age > expiryDuration.inMilliseconds) {
            final cacheKey = key.replaceFirst(_cacheTimestampKey, '');
            await _prefs.remove('$_homeProductsCacheKey$cacheKey');
            await _prefs.remove('$_categoryProductsCacheKey$cacheKey');
            await _prefs.remove(key);
            debugPrint('✓ Cleared expired cache for: $cacheKey');
          }
        }
      }
    } catch (e) {
      debugPrint('✗ Failed to clear expired cache: $e');
    }
  }

  Future<void> clearAllCache() async {
    try {
      final keys = _prefs.getKeys();
      for (final key in keys) {
        if (key.contains('cache')) {
          await _prefs.remove(key);
        }
      }
      debugPrint('✓ Cleared all cache');
    } catch (e) {
      debugPrint('✗ Failed to clear all cache: $e');
    }
  }

  bool isCacheExpired(String key, {Duration expiryDuration = const Duration(hours: 1)}) {
    try {
      final timestamp = _prefs.getInt('$_cacheTimestampKey$key') ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final age = now - timestamp;
      return age > expiryDuration.inMilliseconds;
    } catch (_) {
      return true;
    }
  }
}
