import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
import '../models/categories_response_model.dart';

abstract class CategoryRemoteDataSource {
  Future<CategoryResponseModel> getCategories();
}

@Injectable(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _client;

  const CategoryRemoteDataSourceImpl(this._client);

  @override
  Future<CategoryResponseModel> getCategories() async {
    final response = await _client.dio.get(
      '${AppConfig.categoriesApiBaseUrl}${ApiEndpoints.categories}',
    );

    return CategoryResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
