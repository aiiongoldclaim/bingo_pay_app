// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_detail_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceDetailModel _$ServiceDetailModelFromJson(Map<String, dynamic> json) =>
    ServiceDetailModel(
      id: json['id'] as String,
      uuid: json['uuid'] as String,
      vendorId: json['vendorId'] as String,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: (json['totalReviews'] as num).toInt(),
      vendor: VendorModel.fromJson(json['vendor'] as Map<String, dynamic>),
      category: ServiceCategoryModel.fromJson(
        json['category'] as Map<String, dynamic>,
      ),
      media: (json['media'] as List<dynamic>)
          .map((e) => MediaModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      offerings: (json['offerings'] as List<dynamic>)
          .map((e) => OfferingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      locationLabel: json['locationLabel'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      allowSameDayBooking: json['allowSameDayBooking'] as bool,
      allowPayAfterService: json['allowPayAfterService'] as bool,
    );

Map<String, dynamic> _$ServiceDetailModelToJson(ServiceDetailModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'vendorId': instance.vendorId,
      'title': instance.title,
      'slug': instance.slug,
      'description': instance.description,
      'durationMinutes': instance.durationMinutes,
      'averageRating': instance.averageRating,
      'totalReviews': instance.totalReviews,
      'vendor': instance.vendor,
      'category': instance.category,
      'media': instance.media,
      'offerings': instance.offerings,
      'locationLabel': instance.locationLabel,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'allowSameDayBooking': instance.allowSameDayBooking,
      'allowPayAfterService': instance.allowPayAfterService,
    };
