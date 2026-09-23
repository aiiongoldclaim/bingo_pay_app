import '../models/product_model.dart';
abstract class ProductRepository {
  /// [listingLevel] (e.g. "LUXE", "ULTRA_LUXE") asks the backend for that
  /// tier specifically — omitting it returns the regular public catalogue
  /// only. Membership-gated (MEMBERS_ONLY) products are never included
  /// unless the tier is requested explicitly, no matter the caller's page
  /// size, so Vaults Luxe / Ultra Luxe content must always pass this.
  Future<List<ProductModel>> getAllProducts({
    int page = 1,
    int limit = 100,
    String? listingLevel,
  });
}