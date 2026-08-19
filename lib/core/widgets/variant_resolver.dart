import 'package:get_it/get_it.dart';

import '../../features/product_details/data/models/product_details_model.dart';
import '../api/api_client.dart';
import '../config/app_config.dart';

class VariantResolver {
  static Future<String?> resolve(String productUuid) async {
    try {
      final client = GetIt.I<ApiClient>();
      final url = '${AppConfig.apiBaseUrl}/api/v1/products/$productUuid';
      final response = await client.dio.get(url);

      final product = ProductDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      if (product.variants.isEmpty) return null;

      final inStock = product.variants
          .where((v) => v.availableStock > 0 && v.uuid.isNotEmpty);

      final chosen = inStock.isNotEmpty ? inStock.first : product.variants.first;

      return chosen.uuid.isEmpty ? null : chosen.uuid;
    } catch (_) {
      return null;
    }
  }
}