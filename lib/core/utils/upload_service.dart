import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../api/api_client.dart';
import '../api/api_endpoints.dart';

enum UploadFolder {
  productImage('productimage'),
  profileImage('profileimage'),
  bannerImage('bannerimage'),
  categoryImage('categoryimage'),
  kycDocument('kycdocument');

  const UploadFolder(this.folderName);
  final String folderName;
}

class UploadResult {
  final String url;
  final String publicId;
  final String format;
  final String resourceType;

  const UploadResult({
    required this.url,
    required this.publicId,
    required this.format,
    required this.resourceType,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: json['url'] as String? ?? '',
      publicId: json['public_id'] as String? ?? '',
      format: json['format'] as String? ?? '',
      resourceType: json['resource_type'] as String? ?? '',
    );
  }
}

@lazySingleton
class UploadService {
  final ApiClient _apiClient;

  UploadService(this._apiClient);

  /// Upload a file from a local path.
  Future<UploadResult> uploadFile(
    String filePath,
    UploadFolder folder, {
    String? mimeType,
  }) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        contentType: mimeType != null ? DioMediaType.parse(mimeType) : null,
      ),
    });
    return _post(formData, folder);
  }

  /// Upload raw bytes (e.g. from image_picker on web / memory).
  Future<UploadResult> uploadBytes(
    List<int> bytes,
    String filename,
    UploadFolder folder, {
    String? mimeType,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        bytes,
        filename: filename,
        contentType: mimeType != null ? DioMediaType.parse(mimeType) : null,
      ),
    });
    return _post(formData, folder);
  }

  Future<UploadResult> _post(FormData formData, UploadFolder folder) async {
    final response = await _apiClient.dio.post(
      ApiEndpoints.uploads,
      queryParameters: {'folder': folder.folderName},
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return UploadResult.fromJson(data);
  }
}
