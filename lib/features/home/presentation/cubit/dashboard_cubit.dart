import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/product_cache_service.dart';
import '../../../account/data/account_model/account_profile_response.dart';
import '../../../categories/data/models/categories_model.dart';
import '../../../categories/data/models/categories_response_model.dart';
import '../../data/models/product_model.dart';
import 'dashboard_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading));

    final client = GetIt.I<ApiClient>();
    List<CategoryModel> categories = [];
    String userName = '';
    double bigoldBalance = 0.0;

    // Fetch categories
    try {
      final categoryResponse = await client.dio.get(
        '${AppConfig.categoriesApiBaseUrl}${ApiEndpoints.categories}',
      );
      final categoryResult = CategoryResponseModel.fromJson(
        categoryResponse.data as Map<String, dynamic>,
      );
      categories = categoryResult.data
          .where((e) => e.parentId == null && e.isActive)
          .toList();
      debugPrint('Categories loaded: ${categories.length}');
    } catch (e) {
      debugPrint('Category error: $e');
    }

    // Fetch profile
    try {
      final profileRes = await client.dio.get(ApiEndpoints.profile);
      final profile = AccountResponseModel.fromJson(
        profileRes.data as Map<String, dynamic>,
      );
      userName = profile.account.fullName;
      bigoldBalance = profile.account.bigoldBalance / 1e8;
    } catch (_) {}

    // Fetch products with throttling cache fallback
    List<ProductModel> products = [];
    try {
      final url = '${AppConfig.categoriesApiBaseUrl}/api/v1/products';
      final response = await client.dio.get(
        url,
        queryParameters: {'page': 1, 'limit': 20},
      );
      final raw = response.data as Map<String, dynamic>;
      final dataMap = raw['data'] as Map<String, dynamic>;
      final dataList = (dataMap['data'] as List<dynamic>?) ?? [];
      products = dataList
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Cache the products on successful load
      final cacheService = GetIt.I<ProductCacheService>();
      await cacheService.cacheHomeProducts(products);

      debugPrint('✓ Loaded ${products.length} products from API');
    } catch (e) {
      // Handle throttling (429) and other errors gracefully
      debugPrint('✗ Failed to fetch products: $e');

      final isDioError = e is DioException;
      final isThrottled = isDioError && e.response?.statusCode == 429;

      if (isThrottled) {
        debugPrint('⚠ API throttled (429), attempting to load from cache...');
      }

      // Try to load from cache
      final cacheService = GetIt.I<ProductCacheService>();
      final cachedProducts = await cacheService.getHomeProductsCache();

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        products = cachedProducts;
        debugPrint(
          '✓ Loaded ${products.length} products from cache (API ${isThrottled ? 'throttled' : 'failed'})',
        );
      } else {
        debugPrint('✗ No cached products available');
        products = [];
      }
    }

    emit(state.copyWith(
      status: HomeStatus.loaded,
      userName: userName,
      bigoldBalance: bigoldBalance,
      categories: categories,
      flashDeals: products.take(6).toList(),
      recommended: products,
    ));
  }
}
