// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ServiceModel _$ServiceModelFromJson(Map<String, dynamic> json) => ServiceModel(
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

Map<String, dynamic> _$ServiceModelToJson(ServiceModel instance) =>
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

VendorModel _$VendorModelFromJson(Map<String, dynamic> json) => VendorModel(
  uuid: json['uuid'] as String,
  shopName: json['shopName'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$VendorModelToJson(VendorModel instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'shopName': instance.shopName,
      'email': instance.email,
    };

ServiceCategoryModel _$ServiceCategoryModelFromJson(
  Map<String, dynamic> json,
) => ServiceCategoryModel(
  uuid: json['uuid'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
);

Map<String, dynamic> _$ServiceCategoryModelToJson(
  ServiceCategoryModel instance,
) => <String, dynamic>{
  'uuid': instance.uuid,
  'name': instance.name,
  'slug': instance.slug,
};

MediaModel _$MediaModelFromJson(Map<String, dynamic> json) => MediaModel(
  id: json['id'] as String,
  url: json['url'] as String,
  altText: json['altText'] as String,
  isPrimary: json['isPrimary'] as bool,
);

Map<String, dynamic> _$MediaModelToJson(MediaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'altText': instance.altText,
      'isPrimary': instance.isPrimary,
    };

OfferingModel _$OfferingModelFromJson(Map<String, dynamic> json) =>
    OfferingModel(
      id: json['id'] as String,
      uuid: json['uuid'] as String,
      code: json['code'] as String,
      title: json['title'] as String,
      offeringName: json['offeringName'] as String,
      basePrice: json['basePrice'] as String,
      salePrice: json['salePrice'] as String?,
      currency: json['currency'] as String,
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      isDefault: json['isDefault'] as bool,
    );

Map<String, dynamic> _$OfferingModelToJson(OfferingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'uuid': instance.uuid,
      'code': instance.code,
      'title': instance.title,
      'offeringName': instance.offeringName,
      'basePrice': instance.basePrice,
      'salePrice': instance.salePrice,
      'currency': instance.currency,
      'durationMinutes': instance.durationMinutes,
      'isDefault': instance.isDefault,
    };
