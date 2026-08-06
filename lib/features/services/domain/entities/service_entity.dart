import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String uuid;
  final String title;
  final String slug;
  final String description;
  final int durationMinutes;
  final double averageRating;
  final int totalReviews;
  final String vendorName;
  final String categoryName;
  final String imageUrl;
  final double price;
  final String displayPrice;
  final String? locationLabel;
  final String? latitude;
  final String? longitude;
  final bool allowSameDayBooking;
  final bool allowPayAfterService;
  final List<OfferingEntity> offerings;

  const ServiceEntity({
    required this.id,
    required this.uuid,
    required this.title,
    required this.slug,
    required this.description,
    required this.durationMinutes,
    required this.averageRating,
    required this.totalReviews,
    required this.vendorName,
    required this.categoryName,
    required this.imageUrl,
    required this.price,
    required this.displayPrice,
    this.locationLabel,
    this.latitude,
    this.longitude,
    required this.allowSameDayBooking,
    required this.allowPayAfterService,
    this.offerings = const [],
  });

  @override
  List<Object?> get props => [
        id,
        uuid,
        title,
        slug,
        description,
        durationMinutes,
        averageRating,
        totalReviews,
        vendorName,
        categoryName,
        imageUrl,
        price,
        displayPrice,
        locationLabel,
        latitude,
        longitude,
        allowSameDayBooking,
        allowPayAfterService,
        offerings,
      ];
}

class OfferingEntity extends Equatable {
  final String id;
  final String uuid;
  final String code;
  final String title;
  final String offeringName;
  final String basePrice;
  final String? salePrice;
  final String currency;
  final int durationMinutes;
  final bool isDefault;

  const OfferingEntity({
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

  @override
  List<Object?> get props => [
        id,
        uuid,
        code,
        title,
        offeringName,
        basePrice,
        salePrice,
        currency,
        durationMinutes,
        isDefault,
      ];
}
