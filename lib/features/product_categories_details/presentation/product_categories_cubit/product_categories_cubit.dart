import 'dart:math' show min;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/product_categories_model.dart';
import '../../data/services/product_cache_service.dart';
import 'product_categories_state.dart';


class _CategoryPageBatch {
  const _CategoryPageBatch(this.pages, this.rateLimitError);

  final List<List<ListingProductModel>> pages;
  final RateLimitFailure? rateLimitError;

  Iterable<ListingProductModel> get flattened => pages.expand((p) => p);
}

class ProductListingCubit extends Cubit<ProductListingState> {
  ProductListingCubit() : super(const ProductListingLoading());

  String? _lastCategoryName;
  String? _lastCategoryUuid;
  ProductCacheService? _cacheService;

  // Prevent race conditions from multiple rapid taps
  String? _currentRequestId;
  bool _isLoading = false;

  static const int _pageSize = 20;

  static const int _maxConcurrentRequests = 6;

  List<String> _categoryUuidsForPaging = [];
  final Map<String, bool> _categoryExhausted = {};
  bool _isLoadingMore = false;

  Future<void> _initCache() async {
    _cacheService ??= ProductCacheService(await SharedPreferences.getInstance());
  }

  Future<void> loadCategory(String categoryName, String categoryUuid) async {
    // If same category already loading, ignore duplicate request
    if (_isLoading && _lastCategoryUuid == categoryUuid) {
      return;
    }

    _lastCategoryName = categoryName;
    _lastCategoryUuid = categoryUuid;

    // Generate unique request ID to validate responses
    _currentRequestId = DateTime.now().millisecondsSinceEpoch.toString();
    await _loadCategoryInternal(categoryName, categoryUuid, _currentRequestId!);
  }

  Future<void> retryLoadCategory() async {
    if (_lastCategoryName != null && _lastCategoryUuid != null) {
      _currentRequestId = DateTime.now().millisecondsSinceEpoch.toString();
      await _loadCategoryInternal(
          _lastCategoryName!, _lastCategoryUuid!, _currentRequestId!);
    }
  }

  Future<void> _loadCategoryInternal(
      String categoryName,
      String categoryUuid,
      String requestId,
      ) async {
    try {
      _isLoading = true;
      // New request: forget the previous category's pagination progress.
      _categoryUuidsForPaging = [];
      _categoryExhausted.clear();
      await _initCache();

      // Only emit if this is still the current request
      if (_currentRequestId == requestId) {
        emit(const ProductListingLoading());
      } else {
        return; // Newer request already started, ignore this one
      }

      // Check cache first - if exists, show it while trying to refresh
      final cached = await _cacheService?.getCachedProducts(categoryUuid);
      if (cached != null && cached.products.isNotEmpty) {
        // Only emit if still current request
        if (_currentRequestId == requestId) {
          // Show cached data while attempting to refresh
          emit(
            ProductListingLoaded(
              categoryName: categoryName,
              products: cached.products,
              filteredProducts: cached.products,
              isCachedData: true,
              cachedTimeAgo: cached.cachedTimeAgo,
            ),
          );
        } else {
          return; // Newer request started, stop processing
        }
      }

      final client = GetIt.I<ApiClient>();
      RateLimitFailure? rateLimitError;
      List<String> categoryUuids = [];

      // Try to resolve category tree, but catch rate limit errors
      try {
        categoryUuids = await _resolveCategoryUuids(client, categoryUuid);
      } catch (e) {
        final failure =
        e is Exception ? ErrorHandler.mapExceptionToFailure(e) : null;
        if (failure is RateLimitFailure) {
          rateLimitError = failure;
          // Fall back to just the tapped category
          categoryUuids = [categoryUuid];
        } else {
          // Re-throw non-rate-limit errors
          rethrow;
        }
      }

      _categoryUuidsForPaging = categoryUuids;

      final batch = await _fetchCategoryPages(client, categoryUuids, page: 1);
      rateLimitError ??= batch.rateLimitError;

      if (_currentRequestId != requestId) return;

      final seen = <String>{};
      final products = <ListingProductModel>[];
      for (final product in batch.flattened) {
        if (seen.add(product.id)) products.add(product);
      }

      if (products.isNotEmpty) {
        await _cacheService?.cacheProducts(categoryUuid, products);

        // Only emit if still current request
        if (_currentRequestId == requestId) {
          final hasMore =
          categoryUuids.any((u) => _categoryExhausted[u] != true);
          emit(
            ProductListingLoaded(
              categoryName: categoryName,
              products: products,
              filteredProducts: products,
              isCachedData: false, // Fresh data from API
              currentPage: 1,
              hasMorePages: hasMore,
            ),
          );
        }
      } else if (rateLimitError != null) {
        final currentState = state;
        if (currentState is ProductListingLoaded && currentState.isCachedData) {

          return;
        }
        // Otherwise try to show cache, only if still current request
        if (_currentRequestId == requestId) {
          await _handleRateLimitWithCache(
              categoryName, categoryUuid, rateLimitError, requestId);
        }
      } else {
        // No products and no specific error
        if (_currentRequestId == requestId) {
          emit(
            ProductListingLoaded(
              categoryName: categoryName,
              products: [],
              filteredProducts: [],
            ),
          );
        }
      }
    } catch (e) {
      final failure =
      e is Exception ? ErrorHandler.mapExceptionToFailure(e) : null;

      // Only emit if still current request
      if (_currentRequestId == requestId) {
        // If rate limited, try to show cached data instead of error
        if (failure is RateLimitFailure) {
          await _handleRateLimitWithCache(
              categoryName, categoryUuid, failure, requestId);
        } else {
          final errorMessage = failure?.message ?? e.toString();
          emit(ProductListingError(message: errorMessage));
        }
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _handleRateLimitWithCache(
      String categoryName,
      String categoryUuid,
      RateLimitFailure failure, [
        String? requestId,
      ]) async {
    final cached = await _cacheService?.getCachedProducts(categoryUuid);

    // Check if request is still current before emitting
    final isCurrentRequest = requestId == null || _currentRequestId == requestId;
    if (!isCurrentRequest) return;

    if (cached != null && cached.products.isNotEmpty) {
      // Show cached data instead of error
      emit(
        ProductListingLoaded(
          categoryName: categoryName,
          products: cached.products,
          filteredProducts: cached.products,
          isCachedData: true,
          cachedTimeAgo: cached.cachedTimeAgo,
        ),
      );
    } else {
      // No cache available, show empty state instead of error screen
      emit(
        ProductListingLoaded(
          categoryName: categoryName,
          products: [],
          filteredProducts: [],
          isCachedData: false,
        ),
      );
    }
  }

  Future<_CategoryPageBatch> _fetchCategoryPages(
      ApiClient client,
      List<String> uuids, {
        required int page,
      }) async {
    final pages = List<List<ListingProductModel>>.generate(
      uuids.length,
          (_) => const <ListingProductModel>[],
      growable: false,
    );
    RateLimitFailure? rateLimitError;

    for (var start = 0; start < uuids.length; start += _maxConcurrentRequests) {
      final end = min(start + _maxConcurrentRequests, uuids.length);

      await Future.wait([
        for (var i = start; i < end; i++)
          _fetchInto(client, uuids[i], page, (products) {
            pages[i] = products;
          }, (failure) {
            rateLimitError ??= failure;
          }),
      ]);
    }

    return _CategoryPageBatch(pages, rateLimitError);
  }

  Future<void> _fetchInto(
      ApiClient client,
      String uuid,
      int page,
      void Function(List<ListingProductModel>) onSuccess,
      void Function(RateLimitFailure) onRateLimit,
      ) async {
    try {
      final products = await _fetchProducts(client, uuid, page: page);
      _categoryExhausted[uuid] = products.length < _pageSize;
      onSuccess(products);
    } catch (e) {
      final failure =
      e is Exception ? ErrorHandler.mapExceptionToFailure(e) : null;
      if (failure is RateLimitFailure) {
        onRateLimit(failure);
      }

    }
  }

  Future<List<ListingProductModel>> _fetchProducts(
      ApiClient client,
      String categoryUuid, {
        int page = 1,
      }) async {
    final url = '${AppConfig.apiBaseUrl}/api/v1/products';
    final response = await client.dio.get(
      url,
      queryParameters: {
        if (categoryUuid.isNotEmpty) 'categoryUuid': categoryUuid,
        'page': page,
        'limit': _pageSize,
      },
    );

    final raw = response.data as Map<String, dynamic>;
    final dataMap = raw['data'] as Map<String, dynamic>;
    final dataList = (dataMap['data'] as List<dynamic>?) ?? [];
    return dataList
        .map((e) => ListingProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> loadMoreProducts() async {
    final s = state;
    if (s is! ProductListingLoaded) return;
    if (_isLoadingMore || !s.hasMorePages) return;

    _isLoadingMore = true;
    final nextPage = s.currentPage + 1;
    emit(s.copyWith(isLoadingMore: true));

    try {
      final client = GetIt.I<ApiClient>();
      final uuidsToFetch = _categoryUuidsForPaging
          .where((u) => _categoryExhausted[u] != true)
          .toList();

      final batch =
      await _fetchCategoryPages(client, uuidsToFetch, page: nextPage);

      final seen = s.products.map((p) => p.id).toSet();
      final newProducts =
      batch.flattened.where((p) => seen.add(p.id)).toList(growable: false);

      final mergedProducts = [...s.products, ...newProducts];
      final mergedFiltered = _applyRatingFilter(
        _applyPriceFilter(mergedProducts, s.selectedPriceFilter),
        s.selectedRatingFilter,
      );
      final hasMore =
      _categoryUuidsForPaging.any((u) => _categoryExhausted[u] != true);

      final current = state;
      if (current is ProductListingLoaded) {
        emit(
          current.copyWith(
            products: mergedProducts,
            filteredProducts: mergedFiltered,
            currentPage: nextPage,
            hasMorePages: hasMore,
            isLoadingMore: false,
          ),
        );
      }
    } catch (_) {
      final current = state;
      if (current is ProductListingLoaded) {
        emit(current.copyWith(isLoadingMore: false));
      }
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<List<String>> _resolveCategoryUuids(
      ApiClient client,
      String categoryUuid,
      ) async {
    if (categoryUuid.isEmpty) return [''];

    try {
      final url = '${AppConfig.apiBaseUrl}${ApiEndpoints.categories}';
      final response = await client.dio.get(url);
      final raw = response.data as Map<String, dynamic>;
      final dataMap = raw['data'] as Map<String, dynamic>;
      final categories = ((dataMap['data'] as List<dynamic>?) ?? [])
          .cast<Map<String, dynamic>>();

      final root = categories.firstWhere(
            (c) => c['uuid'] == categoryUuid,
        orElse: () => const <String, dynamic>{},
      );
      if (root.isEmpty) return [categoryUuid];

      final childrenByParentId = <String, List<Map<String, dynamic>>>{};
      for (final c in categories) {
        final parentId = c['parentId'] as String?;
        if (parentId != null) {
          childrenByParentId.putIfAbsent(parentId, () => []).add(c);
        }
      }

      final uuids = <String>[categoryUuid];
      void collectDescendants(String id) {
        for (final child in childrenByParentId[id] ?? const []) {
          uuids.add(child['uuid'] as String);
          collectDescendants(child['id'] as String);
        }
      }

      collectDescendants(root['id'] as String);
      return uuids;
    } catch (_) {
      // Fall back to filtering by just the tapped category if the
      // category tree can't be resolved.
      return [categoryUuid];
    }
  }

  void toggleViewMode() {
    final s = state;
    if (s is! ProductListingLoaded) return;
    emit(s.copyWith(
      viewMode: s.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
    ));
  }

  void applySort(SortOption sort) {
    final s = state;
    if (s is! ProductListingLoaded) return;
    final sorted = List<ListingProductModel>.from(s.filteredProducts);
    switch (sort) {
      case SortOption.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.relevant:
        break;
    }
    emit(s.copyWith(filteredProducts: sorted, selectedSort: sort));
  }

  void applyPriceFilter(String label) {
    final s = state;
    if (s is! ProductListingLoaded) return;
    if (s.selectedPriceFilter == label) {
      emit(s.copyWith(
        filteredProducts: _applyRatingFilter(s.products, s.selectedRatingFilter),
        clearPriceFilter: true,
      ));
      return;
    }
    List<ListingProductModel> filtered = s.products;
    switch (label) {
      case 'Under \$20k':
        filtered = s.products.where((p) => p.price < 20000).toList();
        break;
      case '\$20k–\$50k':
        filtered = s.products
            .where((p) => p.price >= 20000 && p.price <= 50000)
            .toList();
        break;
      case 'Above \$50k':
        filtered = s.products.where((p) => p.price > 50000).toList();
        break;
    }
    filtered = _applyRatingFilter(filtered, s.selectedRatingFilter);
    emit(s.copyWith(filteredProducts: filtered, selectedPriceFilter: label));
  }

  void applyRatingFilter(String label) {
    final s = state;
    if (s is! ProductListingLoaded) return;
    if (s.selectedRatingFilter == label) {
      emit(s.copyWith(
        filteredProducts: _applyPriceFilter(s.products, s.selectedPriceFilter),
        clearRatingFilter: true,
      ));
      return;
    }
    List<ListingProductModel> filtered =
    _applyPriceFilter(s.products, s.selectedPriceFilter);
    if (label == '4★ & up') {
      filtered = filtered.where((p) => (p.rating ?? 0) >= 4.0).toList();
    }
    emit(s.copyWith(filteredProducts: filtered, selectedRatingFilter: label));
  }

  void clearFilters() {
    final s = state;
    if (s is! ProductListingLoaded) return;
    emit(
      s.copyWith(
        filteredProducts: s.products,
        clearPriceFilter: true,
        clearRatingFilter: true,
      ),
    );
  }

  void toggleFavourite(String productId) {
    final s = state;
    if (s is! ProductListingLoaded) return;
    final updated = s.filteredProducts.map((p) {
      return p.id == productId ? p.copyWith(isFavourite: !p.isFavourite) : p;
    }).toList();
    emit(s.copyWith(filteredProducts: updated));
  }

  List<ListingProductModel> _applyPriceFilter(
      List<ListingProductModel> list, String? label) {
    if (label == null) return list;
    switch (label) {
      case 'Under \$20k':
        return list.where((p) => p.price < 20000).toList();
      case '\$20k–\$50k':
        return list.where((p) => p.price >= 20000 && p.price <= 50000).toList();
      case 'Above \$50k':
        return list.where((p) => p.price > 50000).toList();
    }
    return list;
  }

  List<ListingProductModel> _applyRatingFilter(
      List<ListingProductModel> list, String? label) {
    if (label == null) return list;
    if (label == '4★ & up') {
      return list.where((p) => (p.rating ?? 0) >= 4.0).toList();
    }
    return list;
  }
}