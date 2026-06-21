import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../models/vendor_profile_model.dart';

abstract interface class ProfileRemoteDataSource {
  Future<VendorProfileModel> getProfile();
}

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  ProfileRemoteDataSourceImpl(this._apiClient, this._secureStorage);

  @override
  Future<VendorProfileModel> getProfile() async {
    final uuid = await _secureStorage.getUserId();
    final response =
        await _apiClient.dio.get(ApiEndpoints.vendorProfile(uuid!));
    return VendorProfileModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
