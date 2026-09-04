import '../../data/models/product_categories_model.dart';

abstract interface class ProductListingRepository {
  /// Resolves [categoryUuid] plus every descendant category uuid under it,
  /// so a listing can include products from child categories too.
  Future<List<String>> resolveCategoryUuids(String categoryUuid);

  Future<List<ListingProductModel>> fetchProducts({
    required String categoryUuid,
    required int page,
    required int limit,
  });
}
