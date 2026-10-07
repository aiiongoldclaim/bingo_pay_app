import 'package:json_annotation/json_annotation.dart';
import 'service_model.dart';

part 'service_detail_model.g.dart';

@JsonSerializable()
class ServiceDetailModel extends ServiceModel {
  ServiceDetailModel({
    required super.id,
    required super.uuid,
    required super.vendorId,
    required super.title,
    required super.slug,
    required super.description,
    required super.durationMinutes,
    required super.averageRating,
    required super.totalReviews,
    required super.vendor,
    required super.category,
    required super.media,
    required super.offerings,
    super.locationLabel,
    super.latitude,
    super.longitude,
    required super.allowSameDayBooking,
    required super.allowPayAfterService,
  });

  factory ServiceDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceDetailModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ServiceDetailModelToJson(this);
}
