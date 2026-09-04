import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
import '../../domain/repositories/product_listing_repository.dart';
import '../models/product_categories_model.dart';

@LazySingleton(as: ProductListingRepository)
class ProductListingRepositoryImpl implements ProductListingRepository {
  final ApiClient _client;

  const ProductListingRepositoryImpl(this._client);

  @override
  Future<List<ListingProductModel>> fetchProducts({
    required String categoryUuid,
    required int page,
    required int limit,
  }) async {
    final url = '${AppConfig.apiBaseUrl}/api/v1/products';
    final response = await _client.dio.get(
      url,
      queryParameters: {
        if (categoryUuid.isNotEmpty) 'categoryUuid': categoryUuid,
        'page': page,
        'limit': limit,
      },
    );

    final raw = response.data as Map<String, dynamic>;
    final dataMap = raw['data'] as Map<String, dynamic>;
    final dataList = (dataMap['data'] as List<dynamic>?) ?? [];
    return dataList
        .map((e) => ListingProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<String>> resolveCategoryUuids(String categoryUuid) async {
    if (categoryUuid.isEmpty) return [''];

    try {
      final url = '${AppConfig.apiBaseUrl}${ApiEndpoints.categories}';
      final response = await _client.dio.get(url);
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
}
