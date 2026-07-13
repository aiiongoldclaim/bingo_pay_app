import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/error_handler.dart';
import '../../data/models/product_categories_model.dart';
import 'product_categories_state.dart';

class ProductListingCubit extends Cubit<ProductListingState> {
  ProductListingCubit() : super(const ProductListingLoading());

  Future<void> loadCategory(String categoryName, String categoryUuid) async {
    try {
      emit(const ProductListingLoading());

      final client = GetIt.I<ApiClient>();

      // Products are only ever attached to leaf/child categories, never to
      // the top-level category shown on the Categories screen, so a plain
      // categoryUuid filter on the tapped (top-level) category always comes
      // back empty. Resolve the whole subtree and query every descendant too.
      final categoryUuids = await _resolveCategoryUuids(client, categoryUuid);

      final results = await Future.wait(
        categoryUuids.map((uuid) => _fetchProducts(client, uuid)),
      );

      final seen = <String>{};
      final products = <ListingProductModel>[];
      for (final list in results) {
        for (final product in list) {
          if (seen.add(product.id)) products.add(product);
        }
      }

      emit(
        ProductListingLoaded(
          categoryName: categoryName,
          products: products,
          filteredProducts: products,
        ),
      );
    } catch (e) {
      final errorMessage = e is Exception
          ? ErrorHandler.mapExceptionToFailure(e).message
          : e.toString();
      emit(ProductListingError(errorMessage));
    }
  }

  Future<List<ListingProductModel>> _fetchProducts(
    ApiClient client,
    String categoryUuid,
  ) async {
    final url = '${AppConfig.categoriesApiBaseUrl}/api/v1/products';
    final response = await client.dio.get(
      url,
      queryParameters: {
        if (categoryUuid.isNotEmpty) 'categoryUuid': categoryUuid,
        'page': 1,
        'limit': 20,
      },
    );

    final raw = response.data as Map<String, dynamic>;
    final dataMap = raw['data'] as Map<String, dynamic>;
    final dataList = (dataMap['data'] as List<dynamic>?) ?? [];
    return dataList
        .map((e) => ListingProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> _resolveCategoryUuids(
    ApiClient client,
    String categoryUuid,
  ) async {
    if (categoryUuid.isEmpty) return [''];

    try {
      final url =
          '${AppConfig.categoriesApiBaseUrl}${ApiEndpoints.categories}';
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
    emit(
      s.copyWith(
        viewMode: s.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
      ),
    );
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
        return list
            .where((p) => p.price >= 20000 && p.price <= 50000)
            .toList();
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
