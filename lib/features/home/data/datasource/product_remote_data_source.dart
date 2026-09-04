import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    String? categoryUuid,
    int page = 1,
    int limit = 20,
  });
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  ProductRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<ProductModel>> getProducts({
    String? categoryUuid,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _client.dio.get(
      ApiEndpoints.allProducts,   // hardcoded string nahi
      queryParameters: {
        if (categoryUuid != null && categoryUuid.isNotEmpty)
          'categoryUuid': categoryUuid,
        'page': page,
        'limit': limit,
      },
    );

    // Envelope unwrap sirf yahan, poore app mein ek jagah.
    final raw = response.data as Map<String, dynamic>;
    final dataMap = raw['data'] as Map<String, dynamic>;
    final dataList = (dataMap['data'] as List<dynamic>?) ?? [];
    return dataList
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}