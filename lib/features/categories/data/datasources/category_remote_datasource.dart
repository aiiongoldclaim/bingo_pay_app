import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/categories_response_model.dart';
import '../models/sub_category_model.dart';

abstract class CategoryRemoteDataSource {
  Future<CategoryResponseModel> getCategories();

  Future<List<CategoryBreadcrumbModel>> getBreadcrumb(String categoryUuid);

  Future<List<SubCategoryModel>> getSubCategories(String categoryUuid);
}

@Injectable(as: CategoryRemoteDataSource)
class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
  final ApiClient _client;

  const CategoryRemoteDataSourceImpl(this._client);

  @override
  Future<CategoryResponseModel> getCategories() async {
    final response = await _client.dio.get(ApiEndpoints.categories);

    return CategoryResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<CategoryBreadcrumbModel>> getBreadcrumb(
    String categoryUuid,
  ) async {
    final response = await _client.dio.get(
      ApiEndpoints.categoryBreadcrumb(categoryUuid),
    );

    return CategoryBreadcrumbModel.listFromResponse(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<List<SubCategoryModel>> getSubCategories(String categoryUuid) async {
    final response = await _client.dio.get(
      ApiEndpoints.categoryChildren(categoryUuid),
    );

    return SubCategoryModel.listFromResponse(
      response.data as Map<String, dynamic>,
    );
  }
}
