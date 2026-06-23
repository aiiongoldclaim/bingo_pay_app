import 'package:flutter/material.dart';

class ProductDetailModel {
  final String id;
  final String productName;
  final String brand;
  final String price; // pre-formatted: "₹64,999"
  final String oldPrice; // pre-formatted: "₹72,999"
  final int discount; // integer percent: 11
  final String rating; // "4.6"
  final String reviewCount; // "2,143"
  final IconData icon; // placeholder until real imageUrl
  final List<String> images;
  final int coinsEarned;
  final List<String> highlights;
  final List<ProductColorOption> colorOptions;
  final List<RatingBreakdown> ratingBreakdown;
  final DeliveryInfo deliveryInfo;

  const ProductDetailModel({
    required this.id,
    required this.productName,
    required this.brand,
    required this.price,
    required this.oldPrice,
    required this.discount,
    required this.rating,
    required this.reviewCount,
    required this.icon,
    this.images = const [],
    this.coinsEarned = 0,
    this.highlights = const [],
    this.colorOptions = const [],
    this.ratingBreakdown = const [],
    required this.deliveryInfo,
  });
}

class ProductColorOption {
  final Color color;
  final String name;

  const ProductColorOption({required this.color, required this.name});
}

class RatingBreakdown {
  final int stars;
  final double percentage;

  const RatingBreakdown({required this.stars, required this.percentage});
}

class DeliveryInfo {
  final String deliveryLabel;
  final String deliverySubtitle;
  final String returnLabel;
  final String returnSubtitle;
  final String warrantyLabel;
  final String warrantySubtitle;

  const DeliveryInfo({
    required this.deliveryLabel,
    required this.deliverySubtitle,
    required this.returnLabel,
    required this.returnSubtitle,
    required this.warrantyLabel,
    required this.warrantySubtitle,
  });
}
