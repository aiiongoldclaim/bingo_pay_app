import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/public_settings_model.dart';

@injectable
class SettingsRemoteDataSource {
  final ApiClient _client;

  SettingsRemoteDataSource(this._client);

  Future<PublicSettingsModel> getPublicSettings() async {
    final response = await _client.dio.get(ApiEndpoints.publicSettings);

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid settings response');
    }

    dynamic settingsJson = responseData['data'];
    while (settingsJson is Map &&
        settingsJson['company'] == null &&
        settingsJson['data'] != null) {
      settingsJson = settingsJson['data'];
    }

    if (settingsJson is! Map<String, dynamic>) {
      throw const FormatException('Invalid settings payload');
    }

    return PublicSettingsModel.fromJson(settingsJson);
  }
}
