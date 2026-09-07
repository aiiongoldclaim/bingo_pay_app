import '../../data/models/product_categories_model.dart';

abstract interface class ProductListingRepository {
  Future<List<String>> resolveCategoryUuids(String categoryUuid);

  Future<List<ListingProductModel>> fetchProducts({
    required String categoryUuid,
    required int page,
    required int limit,
    String brandUuid = '',
  });
}
