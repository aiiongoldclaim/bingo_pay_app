import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../profile_model/profile_response.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileResponseModel> getProfile();
}

@Injectable(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient _client;
  const ProfileRemoteDataSourceImpl(this._client);

  @override
  Future<ProfileResponseModel> getProfile() async {
    final response = await _client.dio.get(ApiEndpoints.profile);
    return ProfileResponseModel.fromJson(response.data as Map<String, dynamic>);
  }
}
