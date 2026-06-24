// lib/features/account/data/datasource/account_remote_datasource.dart

import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../account_model/account_profile_response.dart';

abstract class AccountRemoteDataSource {
  Future<AccountResponseModel> getProfile({required String email});
}

@Injectable(as: AccountRemoteDataSource)
class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiClient _client;
  const AccountRemoteDataSourceImpl(this._client);

  @override
  Future<AccountResponseModel> getProfile({required String email}) async {
    final response = await _client.dio.post(
      ApiEndpoints.profile,
      data: {'email': email},
    );

    return AccountResponseModel.fromJson(response.data);
  }
}
