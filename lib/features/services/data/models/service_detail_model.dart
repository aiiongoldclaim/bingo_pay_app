import 'package:json_annotation/json_annotation.dart';
import 'service_model.dart';

part 'service_detail_model.g.dart';

@JsonSerializable()
class ServiceDetailModel extends ServiceModel {
  ServiceDetailModel({
    required String id,
    required String uuid,
    required String vendorId,
    required String title,
    required String slug,
    required String description,
    required int durationMinutes,
    required double averageRating,
    required int totalReviews,
    required VendorModel vendor,
    required ServiceCategoryModel category,
    required List<MediaModel> media,
    required List<OfferingModel> offerings,
    String? locationLabel,
    String? latitude,
    String? longitude,
    required bool allowSameDayBooking,
    required bool allowPayAfterService,
  }) : super(
    id: id,
    uuid: uuid,
    vendorId: vendorId,
    title: title,
    slug: slug,
    description: description,
    durationMinutes: durationMinutes,
    averageRating: averageRating,
    totalReviews: totalReviews,
    vendor: vendor,
    category: category,
    media: media,
    offerings: offerings,
    locationLabel: locationLabel,
    latitude: latitude,
    longitude: longitude,
    allowSameDayBooking: allowSameDayBooking,
    allowPayAfterService: allowPayAfterService,
  );

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceDetailModelToJson(this);
}
