import 'package:injectable/injectable.dart';
import '../../data/datasources/services_remote_datasource.dart';
import '../entities/service_entity.dart';

@injectable
class GetServicesUseCase {
  final ServiceRemoteDataSource _dataSource;

  GetServicesUseCase(this._dataSource);

  Future<List<ServiceEntity>> call({int limit = 8, int page = 1}) async {
    final response = await _dataSource.getServices(limit: limit, page: page);

    return response.data.data.map((serviceModel) {
      return ServiceEntity(
        id: serviceModel.id,
        uuid: serviceModel.uuid,
        title: serviceModel.title,
        slug: serviceModel.slug,
        description: serviceModel.description,
        durationMinutes: serviceModel.durationMinutes,
        averageRating: serviceModel.averageRating,
        totalReviews: serviceModel.totalReviews,
        vendorName: serviceModel.vendor.shopName,
        categoryName: serviceModel.category.name,
        imageUrl: serviceModel.imageUrl,
        price: serviceModel.price,
        displayPrice: serviceModel.displayPrice,
        locationLabel: serviceModel.locationLabel,
        latitude: serviceModel.latitude,
        longitude: serviceModel.longitude,
        allowSameDayBooking: serviceModel.allowSameDayBooking,
        allowPayAfterService: serviceModel.allowPayAfterService,
      );
    }).toList();
  }
}
