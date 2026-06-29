import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/api/apps_script_client.dart';
import '../models/attribute_option_model.dart';
import '../models/brand_model.dart';
import '../models/category_attribute_model.dart';
import '../models/category_form_model.dart';
import '../models/category_model.dart';

abstract interface class ProductRemoteDataSource {
  Future<void> addProduct(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getProducts();
  Future<Map<String, dynamic>> getProductDetail(String uuid);
  Future<Map<String, dynamic>> updateProduct(String uuid, Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getProductVariants(String productUuid);
  Future<Map<String, dynamic>> createVariant(String productUuid, Map<String, dynamic> payload);
  Future<Map<String, dynamic>> updateVariant(String productUuid, String variantUuid, Map<String, dynamic> payload);
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoryTree();
  Future<List<BrandModel>> getBrands();
  Future<List<CategoryAttributeModel>> getCategoryAttributes();
  Future<List<AttributeOptionModel>> getAttributeOptions();
  Future<List<Map<String, dynamic>>> getProductMedia(String productUuid);
  Future<Map<String, dynamic>> uploadThumbnail(String productUuid, String filePath, {String? altText});
  Future<List<String>> uploadGallery(String productUuid, List<String> filePaths);
  Future<List<Map<String, dynamic>>> uploadGalleryWithIds(String productUuid, List<String> filePaths);
  Future<void> deleteMedia(String mediaId);
  Future<void> saveSpecifications(String productUuid, Map<String, String> specs);
  Future<List<Map<String, dynamic>>> getProductSpecifications(String productUuid);
  Future<CategoryFormData> getCategoryForm(String categoryUuid);
  Future<Map<String, dynamic>> submitProduct(String productUuid);
}

@Injectable(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final AppsScriptClient _client;
  final ApiClient _apiClient;

  ProductRemoteDataSourceImpl(this._client, this._apiClient);

  @override
  Future<void> addProduct(Map<String, dynamic> payload) async {
    await _client.post('addProduct', payload);
  }

  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _apiClient.dio.get(ApiEndpoints.myProducts);
    final list = response.data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getProductDetail(String uuid) async {
    final response = await _apiClient.dio.get(ApiEndpoints.productDetail(uuid));
    final data = response.data['data'];
    if (data is! Map) return {};
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  @override
  Future<Map<String, dynamic>> updateProduct(String uuid, Map<String, dynamic> payload) async {
    final response = await _apiClient.dio.patch(ApiEndpoints.productDetail(uuid), data: payload);
    final data = response.data['data'];
    if (data is! Map) return {};
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  @override
  Future<List<Map<String, dynamic>>> getProductVariants(String productUuid) async {
    final response = await _apiClient.dio.get(ApiEndpoints.productVariants(productUuid));
    final list = response.data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> createVariant(String productUuid, Map<String, dynamic> payload) async {
    final response = await _apiClient.dio.post(ApiEndpoints.productVariants(productUuid), data: payload);
    final data = response.data['data'];
    if (data is! Map) return {};
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  @override
  Future<Map<String, dynamic>> updateVariant(String productUuid, String variantUuid, Map<String, dynamic> payload) async {
    final response = await _apiClient.dio.patch(ApiEndpoints.variantDetail(variantUuid), data: payload);
    final data = response.data['data'];
    if (data is! Map) return {};
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.dio.get(ApiEndpoints.categories);
    final list = response.data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => CategoryModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }

  @override
  Future<List<CategoryModel>> getCategoryTree() async {
    final response = await _apiClient.dio.get(ApiEndpoints.categoryTree);
    final list = response.data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => CategoryModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
        .where((c) => c.depth == 0)
        .toList();
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    final response = await _apiClient.dio.get(ApiEndpoints.brands);
    final list = response.data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => BrandModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }

  @override
  Future<List<CategoryAttributeModel>> getCategoryAttributes() async {
    final response = await _apiClient.dio.get(ApiEndpoints.categoryAttributes);
    final list = response.data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => CategoryAttributeModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }

  @override
  Future<List<AttributeOptionModel>> getAttributeOptions() async {
    final response = await _apiClient.dio.get(ApiEndpoints.attributeOptions);
    final list = response.data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => AttributeOptionModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getProductMedia(String productUuid) async {
    final response = await _apiClient.dio.get(ApiEndpoints.productAllMedia(productUuid));
    final list = response.data['data'];
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
  }

  @override
  Future<Map<String, dynamic>> uploadThumbnail(
    String productUuid,
    String filePath, {
    String? altText,
  }) async {
    final formData = FormData.fromMap({
      if (altText != null && altText.isNotEmpty) 'altText': altText,
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.dio.post(
      ApiEndpoints.productThumbnail(productUuid),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = response.data['data'];
    if (data is! Map) return {};
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    await _apiClient.dio.delete(ApiEndpoints.productMedia(mediaId));
  }

  @override
  Future<void> saveSpecifications(String productUuid, Map<String, String> specs) async {
    final payload = {
      'specifications': specs.entries
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => {'attributeUuid': e.key, 'value': e.value.trim()})
          .toList(),
    };
    await _apiClient.dio.post(ApiEndpoints.productSpecifications(productUuid), data: payload);
  }

  @override
  Future<List<Map<String, dynamic>>> getProductSpecifications(String productUuid) async {
    final response = await _apiClient.dio.get(ApiEndpoints.productSpecifications(productUuid));
    final list = response.data['data'];
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
  }

  @override
  Future<CategoryFormData> getCategoryForm(String categoryUuid) async {
    final response = await _apiClient.dio.get(ApiEndpoints.categoryForm(categoryUuid));

    List<FormAttribute> parseList(dynamic raw) => (raw is List ? raw : [])
        .whereType<Map>()
        .map((e) => FormAttribute.fromJson(e.map((k, v) => MapEntry(k.toString(), v))))
        .toList();

    return CategoryFormData(
      specificationAttributes: parseList(response.data['specificationAttributes']),
      variantAttributes: parseList(response.data['variantAttributes']),
    );
  }

  @override
  Future<Map<String, dynamic>> submitProduct(String productUuid) async {
    final response = await _apiClient.dio.post(ApiEndpoints.productSubmit(productUuid));
    final data = response.data['data'];
    if (data is! Map) return {};
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  Future<List<Map<String, dynamic>>> _postGallery(String productUuid, List<String> filePaths) async {
    final files = await Future.wait(filePaths.map((p) => MultipartFile.fromFile(p)));
    final formData = FormData.fromMap({'files': files});
    final response = await _apiClient.dio.post(
      ApiEndpoints.productGallery(productUuid),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final list = response.data['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  @override
  Future<List<String>> uploadGallery(String productUuid, List<String> filePaths) async {
    final items = await _postGallery(productUuid, filePaths);
    return items
        .map((e) => e['url']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> uploadGalleryWithIds(String productUuid, List<String> filePaths) async {
    return _postGallery(productUuid, filePaths);
  }
}
