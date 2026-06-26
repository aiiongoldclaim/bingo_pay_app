import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../data/models/product_categories_model.dart';
import 'product_categories_state.dart';

class ProductListingCubit extends Cubit<ProductListingState> {
  ProductListingCubit() : super(const ProductListingLoading());

  Future<void> loadCategory(String categoryName, String categoryUuid) async {
    try {
      emit(const ProductListingLoading());

      final client = GetIt.I<ApiClient>();
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
      final dataList = (raw['data'] as List<dynamic>?) ?? [];
      final products = dataList
          .map((e) =>
              ListingProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      emit(
        ProductListingLoaded(
          categoryName: categoryName,
          products: products,
          filteredProducts: products,
        ),
      );
    } catch (e) {
      emit(ProductListingError(e.toString()));
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
