import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../product_details/data/models/product_details_model.dart';

/// Purane wishlist items me `variantUuid` save nahi hua tha.
/// Ye product API hit karke pehla in-stock variant nikaal deta hai,
/// taaki "Move to Bag" bina product screen khole kaam kare.
class WishlistVariantResolver {
  static Future<String?> resolve(String productUuid) async {
    try {
      final client = GetIt.I<ApiClient>();
      final url = '${AppConfig.apiBaseUrl}/api/v1/products/$productUuid';
      final response = await client.dio.get(url);

      final product = ProductDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (product.variants.isEmpty) return null;

      // Pehla in-stock variant; koi stock me nahi to pehla hi.
      final inStock = product.variants
          .where((v) => v.availableStock > 0 && v.uuid.isNotEmpty);

      final chosen = inStock.isNotEmpty
          ? inStock.first
          : product.variants.first;

      return chosen.uuid.isEmpty ? null : chosen.uuid;
    } catch (_) {
      return null;
    }
  }
}