import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../product_details/data/models/product_details_model.dart';
import '../../data/repositories/wishlist_repository.dart';


@LazySingleton(as: WishlistRepository)
class ProductDetailRepositoryImpl implements WishlistRepository {
  final ApiClient _apiClient;

  ProductDetailRepositoryImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<ProductDetailModel> getProductDetail(String uuid) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.productDetail(uuid),
    );
    return ProductDetailModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<String?> resolveVariantUuid(String productUuid) async {
    if (productUuid.isEmpty) return null;

    try {
      final product = await getProductDetail(productUuid);
      if (product.variants.isEmpty) return null;

      final inStock = product.variants
          .where((variant) => variant.availableStock > 0 && variant.uuid.isNotEmpty);

      final chosen =
      inStock.isNotEmpty ? inStock.first : product.variants.first;

      return chosen.uuid.isEmpty ? null : chosen.uuid;
    } catch (error) {
      debugPrint('✗ Variant resolve failed for $productUuid: $error');
      return null;
    }
  }
}