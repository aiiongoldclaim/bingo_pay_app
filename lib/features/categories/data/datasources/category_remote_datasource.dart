// import 'package:dio/dio.dart';
// import 'package:injectable/injectable.dart';
//
// import '../../../../core/api/api_client.dart';
// import '../../../../core/api/api_endpoints.dart';
// import '../../../home/data/models/category_model.dart';
// import '../models/categories_response_model.dart';
//
// abstract interface class CategoryRemoteDataSource {
//   Future<List<CategoryModel>> getCategories();
// }
//
// @Injectable(as: CategoryRemoteDataSource)
// class CategoryRemoteDataSourceImpl implements CategoryRemoteDataSource {
//   final ApiClient _client;
//
//   CategoryRemoteDataSourceImpl(this._client);
//
//   Dio get _dio => _client.dio;
//
//   @override
//   Future<List<CategoryModel>> getCategories() async {
//     final response = await _dio.get(ApiEndpoints.categories);
//
//     final result = CategoryResponseModel.fromJson(response.data);
//
//     return result.data;
//   }
// }
