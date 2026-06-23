import 'package:flutter/material.dart';
import 'product_details_model.dart';

class ProductMockData {
  static List<ProductDetailModel> flashDeals() {
    return [
      ProductDetailModel(
        id: '1',
        productName: 'iPhone 15',
        brand: 'Apple',
        price: '64,999',
        oldPrice: '72,999',
        discount: 11,
        rating: '4.6',
        reviewCount: '2,143',
        icon: Icons.phone_iphone,
        deliveryInfo: const DeliveryInfo(
          deliveryLabel: 'Free Delivery',
          deliverySubtitle: 'By Tomorrow',
          returnLabel: '7 Days Return',
          returnSubtitle: 'Easy Returns',
          warrantyLabel: '1 Year Warranty',
          warrantySubtitle: 'Apple Warranty',
        ),
      ),
    ];
  }

  static List<ProductDetailModel> recommended() {
    return [
      ProductDetailModel(
        id: '2',
        productName: 'Sony Headphones',
        brand: 'Sony',
        price: '9,999',
        oldPrice: '12,999',
        discount: 23,
        rating: '4.7',
        reviewCount: '1,245',
        icon: Icons.headphones,

        colorOptions: const [
          ProductColorOption(color: Color(0xFF1B3A6E), name: 'Midnight Blue'),
          ProductColorOption(color: Color(0xFF0B1736), name: 'Black'),
          ProductColorOption(color: Color(0xFFC9A84C), name: 'Gold'),
          ProductColorOption(color: Color(0xFFE5E7EB), name: 'Silver'),
        ],

        highlights: const [
          'Active noise cancellation up to 42 dB',
          '40-hour battery with fast charge',
          'Spatial audio with head tracking',
          'Premium memory-foam ear cushions',
        ],

        ratingBreakdown: const [
          RatingBreakdown(stars: 5, percentage: 0.85),
          RatingBreakdown(stars: 4, percentage: 0.12),
          RatingBreakdown(stars: 3, percentage: 0.02),
          RatingBreakdown(stars: 2, percentage: 0.005),
          RatingBreakdown(stars: 1, percentage: 0.005),
        ],

        deliveryInfo: const DeliveryInfo(
          deliveryLabel: 'Free delivery by Sat, 14 Jun',
          deliverySubtitle: 'Order within 4h 20m',
          returnLabel: '7-day easy returns',
          returnSubtitle: 'No questions asked',
          warrantyLabel: '2-year brand warranty',
          warrantySubtitle: 'BINGOLD verified seller',
        ),
      ),
    ];
  }
}
