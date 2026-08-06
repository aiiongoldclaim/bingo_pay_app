import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../models/availability_model.dart';
import '../models/service_detail_model.dart';
import '../models/service_detail_response_model.dart';

abstract class ServiceDetailDataSource {
  Future<ServiceDetailModel> getServiceDetail(String serviceUuid);
  Future<AvailabilityResponseModel> getServiceAvailability({
    required String serviceUuid,
    required String offeringUuid,
    int participants = 1,
  });
}

@Injectable(as: ServiceDetailDataSource)
class ServiceDetailDataSourceImpl implements ServiceDetailDataSource {
  final ApiClient _client;

  const ServiceDetailDataSourceImpl(this._client);

  @override
  Future<ServiceDetailModel> getServiceDetail(String serviceUuid) async {
    final response = await _client.dio.get(
      '${AppConfig.apiBaseUrl}/api/v1/services/$serviceUuid',
    );

    final detailResponse = ServiceDetailResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );

    return detailResponse.data.data;
  }

  @override
  Future<AvailabilityResponseModel> getServiceAvailability({
    required String serviceUuid,
    required String offeringUuid,
    int participants = 1,
  }) async {
    final response = await _client.dio.get(
      '${AppConfig.apiBaseUrl}/api/v1/services/$serviceUuid/availability',
      queryParameters: {
        'offeringUuid': offeringUuid,
        'participants': participants,
      },
    );

    return AvailabilityResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}
