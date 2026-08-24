import 'package:injectable/injectable.dart';
import '../../data/datasources/services_remote_datasource.dart';
import '../entities/service_entity.dart';
import '../entities/availability_entity.dart';

@injectable
class GetServiceDetailUseCase {
  final ServiceRemoteDataSource _dataSource;

  GetServiceDetailUseCase(this._dataSource);

  Future<ServiceEntity> call(String serviceUuid) async {
    final response = await _dataSource.getServiceDetail(serviceUuid);

    return ServiceEntity(
      id: response.id,
      uuid: response.uuid,
      title: response.title,
      slug: response.slug,
      description: response.description,
      durationMinutes: response.durationMinutes,
      averageRating: response.averageRating,
      totalReviews: response.totalReviews,
      vendorName: response.vendor.shopName,
      categoryName: response.category.name,
      imageUrl: response.imageUrl,
      price: response.price,
      displayPrice: response.displayPrice,
      locationLabel: response.locationLabel,
      latitude: response.latitude,
      longitude: response.longitude,
      allowSameDayBooking: response.allowSameDayBooking,
      allowPayAfterService: response.allowPayAfterService,
      offerings: response.offerings
          .map((o) => OfferingEntity(
                id: o.id,
                uuid: o.uuid,
                code: o.code,
                title: o.title,
                offeringName: o.offeringName,
                basePrice: o.basePrice,
                salePrice: o.salePrice,
                currency: o.currency,
                durationMinutes: o.durationMinutes,
                isDefault: o.isDefault,
              ))
          .toList(),
    );
  }
}

@injectable
class GetServiceAvailabilityUseCase {
  final ServiceRemoteDataSource _dataSource;

  GetServiceAvailabilityUseCase(this._dataSource);

  Future<AvailabilityEntity> call({
    required String serviceUuid,
    required String offeringUuid,
    int participants = 1,
  }) async {
    final response = await _dataSource.getServiceAvailability(
      serviceUuid: serviceUuid,
      offeringUuid: offeringUuid,
      participants: participants,
    );

    return AvailabilityEntity(
      schedulingModel: response.data.data.schedulingModel,
      leadTimeMinutes: response.data.data.leadTimeMinutes,
      days: response.data.data.days
          .map((day) => DayEntity(
                date: day.date,
                slots: day.slots
                    .map((slot) => SlotEntity(
                          uuid: slot.uuid,
                          startsAt: slot.startsAt,
                          endsAt: slot.endsAt,
                          remaining: slot.remaining,
                          offeringUuid: slot.offering.uuid,
                          offeringCode: slot.offering.code,
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}
