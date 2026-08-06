import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/services_response_model.dart';

abstract class ServiceRemoteDataSource {
  Future<ServicesResponseModel> getServices({int limit = 8, int page = 1});
}

@Injectable(as: ServiceRemoteDataSource)
class ServiceRemoteDataSourceImpl implements ServiceRemoteDataSource {
  final ApiClient _client;

  const ServiceRemoteDataSourceImpl(this._client);

  @override
  Future<ServicesResponseModel> getServices({
    int limit = 8,
    int page = 1,
  }) async {
    final response = await _client.dio.get(
      '${AppConfig.apiBaseUrl}/api/v1/services',
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );

    return ServicesResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
