import 'package:json_annotation/json_annotation.dart';
import '../../../../core/utils/currency_formatter.dart';

part 'service_model.g.dart';

@JsonSerializable()
class ServiceModel {
  final String id;
  final String uuid;
  final String vendorId;
  final String title;
  final String slug;
  final String description;
  @JsonKey(name: 'durationMinutes')
  final int durationMinutes;
  @JsonKey(name: 'averageRating')
  final double averageRating;
  @JsonKey(name: 'totalReviews')
  final int totalReviews;
  final VendorModel vendor;
  final ServiceCategoryModel category;
  final List<MediaModel> media;
  final List<OfferingModel> offerings;
  final String? locationLabel;
  final String? latitude;
  final String? longitude;
  @JsonKey(name: 'allowSameDayBooking')
  final bool allowSameDayBooking;
  @JsonKey(name: 'allowPayAfterService')
  final bool allowPayAfterService;

  ServiceModel({
    required this.id,
    required this.uuid,
    required this.vendorId,
    required this.title,
    required this.slug,
    required this.description,
    required this.durationMinutes,
    required this.averageRating,
    required this.totalReviews,
    required this.vendor,
    required this.category,
    required this.media,
    required this.offerings,
    this.locationLabel,
    this.latitude,
    this.longitude,
    required this.allowSameDayBooking,
    required this.allowPayAfterService,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);

  String get imageUrl => media.isNotEmpty ? media.first.url : '';

  // double get price => offerings.isNotEmpty
  //     ? double.parse(offerings.first.salePrice.toString())
  //     : 0.0;

  double get price => offerings.isNotEmpty
    ? double.tryParse(
          offerings.first.salePrice ?? offerings.first.basePrice,
        ) ??
        0.0
    : 0.0;

  String get displayPrice => offerings.isNotEmpty
      ? CurrencyFormatter.formatPrice(
          offerings.first.salePrice ?? offerings.first.basePrice,
          offerings.first.currency,
        )
      : 'N/A';
}

@JsonSerializable()
class VendorModel {
  final String uuid;
  @JsonKey(name: 'shopName')
  final String shopName;
  final String email;

  VendorModel({
    required this.uuid,
    required this.shopName,
    required this.email,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) =>
      _$VendorModelFromJson(json);

  Map<String, dynamic> toJson() => _$VendorModelToJson(this);
}

@JsonSerializable()
class ServiceCategoryModel {
  final String uuid;
  final String name;
  final String slug;

  ServiceCategoryModel({
    required this.uuid,
    required this.name,
    required this.slug,
  });

  factory ServiceCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceCategoryModelToJson(this);
}

@JsonSerializable()
class MediaModel {
  final String id;
  final String url;
  @JsonKey(name: 'altText')
  final String altText;
  @JsonKey(name: 'isPrimary')
  final bool isPrimary;

  MediaModel({
    required this.id,
    required this.url,
    required this.altText,
    required this.isPrimary,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json) =>
      _$MediaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MediaModelToJson(this);
}

@JsonSerializable()
class OfferingModel {
  final String id;
  final String uuid;
  final String code;
  final String title;
  @JsonKey(name: 'offeringName')
  final String offeringName;
  @JsonKey(name: 'basePrice')
  final String basePrice;
  @JsonKey(name: 'salePrice')
  final String? salePrice;
  final String currency;
  @JsonKey(name: 'durationMinutes')
  final int durationMinutes;
  @JsonKey(name: 'isDefault')
  final bool isDefault;

  OfferingModel({
    required this.id,
    required this.uuid,
    required this.code,
    required this.title,
    required this.offeringName,
    required this.basePrice,
    required this.salePrice,
    required this.currency,
    required this.durationMinutes,
    required this.isDefault,
  });

  factory OfferingModel.fromJson(Map<String, dynamic> json) =>
      _$OfferingModelFromJson(json);

  Map<String, dynamic> toJson() => _$OfferingModelToJson(this);
}
