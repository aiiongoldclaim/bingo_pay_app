import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/server_health_model.dart';

@injectable
class HealthRemoteDataSource {
  final ApiClient _client;

  HealthRemoteDataSource(this._client);

  /// Lightweight reachability check. Returns the server's greeting, e.g.
  /// "Hello World! server is running on : 5001".
  Future<String> ping() async {
    final response = await _client.dio.get(ApiEndpoints.hello);
    final responseData = response.data;
    if (responseData is! Map<String, dynamic> ||
        responseData['success'] != true) {
      throw const FormatException('Invalid hello response');
    }
    return responseData['data']?.toString().trim() ?? '';
  }

  Future<ServerHealthModel> getHealth() async {
    dynamic responseData;
    try {
      final response = await _client.dio.get(ApiEndpoints.health);
      responseData = response.data;
    } on DioException catch (e) {
      // A degraded backend may answer 503 with the same health body — read
      // it so the app knows which service is down. Otherwise rethrow.
      responseData = e.response?.data;
      if (responseData is! Map<String, dynamic>) rethrow;
    }

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid health response');
    }

    dynamic healthJson = responseData['data'];
    while (healthJson is Map &&
        healthJson['services'] == null &&
        healthJson['data'] != null) {
      healthJson = healthJson['data'];
    }

    if (healthJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid health payload');
    }

    return ServerHealthModel.fromJson(healthJson);
  }
}
