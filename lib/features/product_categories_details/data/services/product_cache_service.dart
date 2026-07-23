import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_categories_model.dart';

class ProductCacheService {
  static const String _cachePrefix = 'product_cache_';
  static const String _timestampSuffix = '_timestamp';

  final SharedPreferences _prefs;

  ProductCacheService(this._prefs);

  /// Cache products for a category
  Future<void> cacheProducts(
    String categoryUuid,
    List<ListingProductModel> products,
  ) async {
    try {
      final key = '$_cachePrefix$categoryUuid';
      final timestampKey = '$key$_timestampSuffix';

      final jsonList = products
          .map((p) => jsonEncode(p.toJson()))
          .toList();

      await Future.wait([
        _prefs.setStringList(key, jsonList),
        _prefs.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch),
      ]);

      if (kDebugMode) debugPrint('[ProductCache] Cached ${products.length} products for $categoryUuid');
    } catch (e) {
      if (kDebugMode) debugPrint('[ProductCache] Error caching products: $e');
    }
  }

  /// Get cached products for a category
  Future<CachedProducts?> getCachedProducts(String categoryUuid) async {
    try {
      final key = '$_cachePrefix$categoryUuid';
      final timestampKey = '$key$_timestampSuffix';

      final jsonList = _prefs.getStringList(key);
      if (jsonList == null || jsonList.isEmpty) return null;

      final products = jsonList
          .map((json) => ListingProductModel.fromJson(
                jsonDecode(json) as Map<String, dynamic>,
              ))
          .toList();

      final timestamp = _prefs.getInt(timestampKey) ?? 0;

      if (kDebugMode) debugPrint('[ProductCache] Retrieved ${products.length} cached products for $categoryUuid');

      return CachedProducts(
        products: products,
        cachedAt: DateTime.fromMillisecondsSinceEpoch(timestamp),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[ProductCache] Error retrieving cached products: $e');
      return null;
    }
  }

  /// Clear cache for a specific category
  Future<void> clearCategoryCache(String categoryUuid) async {
    try {
      final key = '$_cachePrefix$categoryUuid';
      final timestampKey = '$key$_timestampSuffix';

      await Future.wait([
        _prefs.remove(key),
        _prefs.remove(timestampKey),
      ]);

      if (kDebugMode) debugPrint('[ProductCache] Cleared cache for $categoryUuid');
    } catch (e) {
      if (kDebugMode) debugPrint('[ProductCache] Error clearing cache: $e');
    }
  }

  /// Clear all product caches
  Future<void> clearAllCache() async {
    try {
      final keys = _prefs.getKeys();
      final cacheKeys = keys
          .where((k) => k.startsWith(_cachePrefix))
          .toList();

      await Future.wait(cacheKeys.map((k) => _prefs.remove(k)));

      if (kDebugMode) debugPrint('[ProductCache] Cleared all cache (${cacheKeys.length} entries)');
    } catch (e) {
      if (kDebugMode) debugPrint('[ProductCache] Error clearing all cache: $e');
    }
  }
}

class CachedProducts {
  final List<ListingProductModel> products;
  final DateTime cachedAt;

  CachedProducts({
    required this.products,
    required this.cachedAt,
  });

  /// Get human-readable cached time
  String get cachedTimeAgo {
    final now = DateTime.now();
    final diff = now.difference(cachedAt);

    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

