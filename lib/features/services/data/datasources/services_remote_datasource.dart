import 'package:injectable/injectable.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/availability_model.dart';
import '../models/service_detail_model.dart';
import '../models/service_detail_response_model.dart';
import '../models/services_response_model.dart';

abstract class ServiceRemoteDataSource {
  // List services
  Future<ServicesResponseModel> getServices({int limit = 8, int page = 1});
  
  // Service detail
  Future<ServiceDetailModel> getServiceDetail(String serviceUuid);
  
  // Service availability
  Future<AvailabilityResponseModel> getServiceAvailability({
    required String serviceUuid,
    required String offeringUuid,
    int participants = 1,
  });
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
      ApiEndpoints.services,
      queryParameters: {
        'limit': limit,
        'page': page,
      },
    );

    return ServicesResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<ServiceDetailModel> getServiceDetail(String serviceUuid) async {
    final response = await _client.dio.get(
      ApiEndpoints.serviceDetail(serviceUuid),
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
      ApiEndpoints.serviceAvailability(serviceUuid),
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
