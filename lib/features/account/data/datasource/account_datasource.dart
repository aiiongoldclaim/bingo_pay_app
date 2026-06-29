import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../account_model/account_profile_response.dart';

abstract class AccountRemoteDataSource {
  Future<AccountResponseModel> getProfile();
}

@Injectable(as: AccountRemoteDataSource)
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiClient _client;
  const AccountRemoteDataSourceImpl(this._client);

  @override
  Future<AccountResponseModel> getProfile() async {
    final response = await _client.dio.get(ApiEndpoints.profile);
    return AccountResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
