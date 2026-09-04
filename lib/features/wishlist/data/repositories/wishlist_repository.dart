import '../../../product_details/data/models/product_details_model.dart';

abstract class WishlistRepository {

  Future<ProductDetailModel> getProductDetail(String uuid);

  Future<String?> resolveVariantUuid(String productUuid);
}