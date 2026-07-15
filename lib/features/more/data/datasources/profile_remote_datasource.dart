import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/vendor_document_model.dart';
import '../models/vendor_profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<VendorProfileModel> getProfile();
  Future<List<VendorDocumentModel>> getVendorDocuments();
}

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  final SharedPreferences _prefs;

  ProfileRemoteDataSourceImpl(this._apiClient, this._secureStorage, this._prefs);

  @override
  Future<VendorProfileModel> getProfile() async {
    // Primary: vendor UUID saved at login/register
    String? uuid = await _secureStorage.getVendorUuid();

    // Fallback: read from cached vendor JSON (sessions before vendor UUID was stored)
    if (uuid == null) {
      final json = _prefs.getString('cached_vendor');
      if (json != null) {
        final data = jsonDecode(json) as Map<String, dynamic>;
        uuid = data['uuid'] as String?;
        // Backfill so future calls skip this fallback
        if (uuid != null) await _secureStorage.saveVendorUuid(uuid);
      }
    }

    if (uuid == null) throw Exception('Vendor UUID not found — please log in again.');

    final response = await _apiClient.dio.get(
      ApiEndpoints.vendorProfile(uuid),
      options: Options(headers: {'x-api-key': 'mysecreate-key'}),
    );
    final outer = response.data['data'] as Map<String, dynamic>;
    return VendorProfileModel.fromJson(
      (outer['data'] ?? outer) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<VendorDocumentModel>> getVendorDocuments() async {
    final response = await _apiClient.dio.get(ApiEndpoints.vendorDocuments);
    var list = response.data['data'];
    if (list is Map) list = list['data'];
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map((e) => VendorDocumentModel.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }
}
