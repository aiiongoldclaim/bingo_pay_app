import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/brand_model.dart';

abstract class BrandRemoteDataSource {
  Future<List<BrandModel>> getBrands();
}

@Injectable(as: BrandRemoteDataSource)
class BrandRemoteDataSourceImpl implements BrandRemoteDataSource {
  final ApiClient _client;

  const BrandRemoteDataSourceImpl(this._client);

  @override
  Future<List<BrandModel>> getBrands() async {
    final url = '${AppConfig.categoriesApiBaseUrl}/api/v1/brands';
    final response = await _client.dio.get(url);

    final raw = response.data as Map<String, dynamic>;
    final dataWrapper = raw['data'] as Map<String, dynamic>?;
    final dataList = (dataWrapper?['data'] as List<dynamic>?) ?? [];

    return dataList
        .map((e) => BrandModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
