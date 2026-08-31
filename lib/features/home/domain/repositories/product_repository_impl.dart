import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/services/product_cache_service.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/all_products_repo.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ApiClient _apiClient;
  final ProductCacheService _cacheService;

  ProductRepositoryImpl({
    required ApiClient apiClient,
    required ProductCacheService cacheService,
  })  : _apiClient = apiClient,
        _cacheService = cacheService;

  @override
  Future<List<ProductModel>> getAllProducts({
    int page = 1,
    int limit = 100,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiEndpoints.allProducts,
        queryParameters: {'page': page, 'limit': limit},
      );
      final raw = response.data as Map<String, dynamic>;
      final dataMap = raw['data'] as Map<String, dynamic>;
      final dataList = (dataMap['data'] as List<dynamic>?) ?? [];
      final products = dataList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await _cacheService.cacheHomeProducts(products);
      debugPrint('✓ Loaded and cached ${products.length} products from API');
      return products;
    } catch (e) {
      debugPrint('✗ Failed to fetch products: $e');

      final isDioError = e is DioException;
      final isThrottled = isDioError && e.response?.statusCode == 429;

      if (isThrottled) {
        debugPrint('⚠ API throttled (429), attempting to load from cache...');
      }

      final cachedProducts = await _cacheService.getHomeProductsCache();
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        debugPrint(
          '✓ Loaded ${cachedProducts.length} products from cache (API ${isThrottled ? 'throttled' : 'failed'})',
        );
        return cachedProducts;
      }

      debugPrint('✗ No cached products available, rethrowing error');
      rethrow;
    }
  }
}