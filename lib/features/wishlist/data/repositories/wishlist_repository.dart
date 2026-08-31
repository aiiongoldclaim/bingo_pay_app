import '../../../product_details/data/models/product_details_model.dart';

abstract class WishlistRepository {
  /// Product ka poora detail laata hai.
  Future<ProductDetailModel> getProductDetail(String uuid);

  Future<String?> resolveVariantUuid(String productUuid);
}