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
  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getProducts();
  Future<Map<String, dynamic>> getProductDetail(String uuid);
  Future<void> deleteProduct(String uuid);
  Future<Map<String, dynamic>> updateProduct(
    String uuid,
    Map<String, dynamic> payload,
  );
  Future<List<Map<String, dynamic>>> getProductVariants(String productUuid);
  Future<Map<String, dynamic>> createVariant(
    String productUuid,
    Map<String, dynamic> payload,
  );
  Future<Map<String, dynamic>> updateVariant(
    String productUuid,
    String variantUuid,
    Map<String, dynamic> payload,
  );
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoryTree();
  Future<List<BrandModel>> getBrands();
  Future<List<CategoryAttributeModel>> getCategoryAttributes();
  Future<List<AttributeOptionModel>> getAttributeOptions();
  Future<List<Map<String, dynamic>>> getProductMedia(String productUuid);
  Future<Map<String, dynamic>> uploadThumbnail(
    String productUuid,
    String filePath, {
    String? altText,
  });
  Future<Map<String, dynamic>> replaceThumbnail(
    String productUuid,
    String filePath,
  );
  Future<List<String>> uploadGallery(
    String productUuid,
    List<String> filePaths,
  );
  Future<List<Map<String, dynamic>>> uploadGalleryWithIds(
    String productUuid,
    List<String> filePaths,
  );
  Future<void> deleteMedia(String mediaId);
  Future<void> saveSpecifications(
    String productUuid,
    Map<String, String> specs,
  );
  Future<List<Map<String, dynamic>>> getProductSpecifications(
    String productUuid,
  );
  Future<CategoryFormData> getCategoryForm(String categoryUuid);
  Future<Map<String, dynamic>> submitProduct(String productUuid);
  Future<Map<String, dynamic>> resubmitProduct(String productUuid);
  Future<List<int>> downloadBulkTemplate(String categoryUuid);
  Future<Map<String, dynamic>> importBulkProducts(
    String filePath, {
    void Function(int sent, int total)? onSendProgress,
  });
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

  // Single-object endpoints sometimes wrap the payload twice, e.g.
  // { data: { message, data: {...actual object...} } } — unwrap both layers.
  Map<String, dynamic> _unwrapObject(dynamic responseData) {
    var data = responseData is Map ? responseData['data'] : null;
    if (data is Map && data['data'] is Map) data = data['data'];
    if (data is! Map) return {};
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

  @override
  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.createProduct,
      data: payload,
    );
    return _unwrapObject(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await _apiClient.dio.get(ApiEndpoints.myProducts);
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getProductDetail(String uuid) async {
    final response = await _apiClient.dio.get(ApiEndpoints.productDetail(uuid));
    return _unwrapObject(response.data);
  }

  @override
  Future<void> deleteProduct(String uuid) async {
    await _apiClient.dio.delete(ApiEndpoints.productDetail(uuid));
  }

  @override
  Future<Map<String, dynamic>> updateProduct(
    String uuid,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.productDetail(uuid),
      data: payload,
    );
    return _unwrapObject(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> getProductVariants(
    String productUuid,
  ) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.productVariants(productUuid),
    );
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> createVariant(
    String productUuid,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.productVariants(productUuid),
      data: payload,
    );
    return _unwrapObject(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateVariant(
    String productUuid,
    String variantUuid,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.variantDetail(variantUuid),
      data: payload,
    );
    return _unwrapObject(response.data);
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.dio.get(ApiEndpoints.categories);
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map(
          (e) => CategoryModel.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .toList();
  }

  @override
  Future<List<CategoryModel>> getCategoryTree() async {
    final response = await _apiClient.dio.get(ApiEndpoints.categoryTree);
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map(
          (e) => CategoryModel.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .where((c) => c.depth == 0)
        .toList();
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    final response = await _apiClient.dio.get(ApiEndpoints.brands);
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map(
          (e) =>
              BrandModel.fromJson(e.map((k, v) => MapEntry(k.toString(), v))),
        )
        .toList();
  }

  @override
  Future<List<CategoryAttributeModel>> getCategoryAttributes() async {
    final response = await _apiClient.dio.get(ApiEndpoints.categoryAttributes);
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map(
          (e) => CategoryAttributeModel.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .toList();
  }

  @override
  Future<List<AttributeOptionModel>> getAttributeOptions() async {
    final response = await _apiClient.dio.get(ApiEndpoints.attributeOptions);
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map(
          (e) => AttributeOptionModel.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getProductMedia(String productUuid) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.productAllMedia(productUuid),
    );
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  // ImagePickerHelper.compressIfNeeded always converts to JPEG, so the file
  // part's content-type is pinned explicitly rather than inferred from the path.
  static final _jpegContentType = DioMediaType('image', 'jpeg');

  @override
  Future<Map<String, dynamic>> uploadThumbnail(
    String productUuid,
    String filePath, {
    String? altText,
  }) async {
    final formData = FormData.fromMap({
      if (altText != null && altText.isNotEmpty) 'altText': altText,
      'file': await MultipartFile.fromFile(
        filePath,
        contentType: _jpegContentType,
      ),
    });
    final response = await _apiClient.dio.post(
      ApiEndpoints.productThumbnail(productUuid),
      data: formData,
    );
    return _unwrapObject(response.data);
  }

  @override
  Future<Map<String, dynamic>> replaceThumbnail(
    String productUuid,
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        contentType: _jpegContentType,
      ),
    });
    final response = await _apiClient.dio.post(
      ApiEndpoints.productThumbnailReplace(productUuid),
      data: formData,
    );
    return _unwrapObject(response.data);
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    await _apiClient.dio.delete(ApiEndpoints.productMedia(mediaId));
  }

  @override
  Future<void> saveSpecifications(
    String productUuid,
    Map<String, String> specs,
  ) async {
    final payload = {
      'specifications': specs.entries
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => {'attributeUuid': e.key, 'value': e.value.trim()})
          .toList(),
    };
    await _apiClient.dio.post(
      ApiEndpoints.productSpecifications(productUuid),
      data: payload,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getProductSpecifications(
    String productUuid,
  ) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.productSpecifications(productUuid),
    );
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  @override
  Future<CategoryFormData> getCategoryForm(String categoryUuid) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.categoryForm(categoryUuid),
    );
    final data = response.data['data'] is Map
        ? response.data['data']
        : response.data;

    List<FormAttribute> parseList(dynamic raw) => (raw is List ? raw : [])
        .whereType<Map>()
        .map(
          (e) => FormAttribute.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .toList();

    return CategoryFormData(
      specificationAttributes: parseList(data['specificationAttributes']),
      variantAttributes: parseList(data['variantAttributes']),
    );
  }

  @override
  Future<Map<String, dynamic>> submitProduct(String productUuid) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.productSubmit(productUuid),
    );
    return _unwrapObject(response.data);
  }

  @override
  Future<Map<String, dynamic>> resubmitProduct(String productUuid) async {
    final response = await _apiClient.dio.patch(
      ApiEndpoints.productResubmit(productUuid),
    );
    return _unwrapObject(response.data);
  }

  @override
  Future<List<int>> downloadBulkTemplate(String categoryUuid) async {
    final response = await _apiClient.dio.get<List<int>>(
      ApiEndpoints.bulkImportTemplate,
      queryParameters: {'categoryUuid': categoryUuid},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }

  @override
  Future<Map<String, dynamic>> importBulkProducts(
    String filePath, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _apiClient.dio.post(
      ApiEndpoints.bulkImportUpload,
      data: formData,
      onSendProgress: onSendProgress,
      options: Options(receiveTimeout: const Duration(seconds: 120)),
    );
    return _unwrapObject(response.data);
  }

  Future<List<Map<String, dynamic>>> _postGallery(
    String productUuid,
    List<String> filePaths,
  ) async {
    final files = await Future.wait(
      filePaths.map(
        (p) => MultipartFile.fromFile(p, contentType: _jpegContentType),
      ),
    );
    final formData = FormData.fromMap({'files': files});
    final response = await _apiClient.dio.post(
      ApiEndpoints.productGallery(productUuid),
      data: formData,
    );
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  @override
  Future<List<String>> uploadGallery(
    String productUuid,
    List<String> filePaths,
  ) async {
    final items = await _postGallery(productUuid, filePaths);
    return items
        .map((e) => e['url']?.toString() ?? '')
        .where((url) => url.isNotEmpty)
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> uploadGalleryWithIds(
    String productUuid,
    List<String> filePaths,
  ) async {
    return _postGallery(productUuid, filePaths);
  }
}
