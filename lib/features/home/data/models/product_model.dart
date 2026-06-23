import 'package:flutter/material.dart';

class ProductModel {
  final String brand;
  final String name;
  final String price;
  final String oldPrice;
  final String rating;
  final int discount;
  final IconData icon;

  ProductModel({
    required this.brand,
    required this.name,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.discount,
    required this.icon,
  });

  static List<ProductModel> flashDeals() => [
    ProductModel(
      brand: 'NOVA',
      name: 'Helios 5G Smartphone 256GB',
      price: '₹64,999',
      oldPrice: '₹72,999',
      rating: '4.6',
      discount: 11,
      icon: Icons.smartphone_outlined,
    ),

    ProductModel(
      brand: 'SONARA',
      name: 'Aurora Pro Wireless Headphones',
      price: '₹18,990',
      oldPrice: '₹24,990',
      rating: '4.8',
      discount: 24,
      icon: Icons.headphones_outlined,
    ),

    ProductModel(
      brand: 'OPTIX',
      name: 'Lumina Smart Camera',
      price: '₹8,990',
      oldPrice: '₹11,990',
      rating: '4.7',
      discount: 20,
      icon: Icons.camera_alt_outlined,
    ),

    ProductModel(
      brand: 'TYDE',
      name: 'Eclipse Smartwatch',
      price: '₹32,400',
      oldPrice: '₹389876',
      rating: '4.7',
      discount: 20,
      icon: Icons.camera_alt_outlined,
    ),
  ];

  static List<ProductModel> recommended() => [
    ProductModel(
      brand: 'TYDE',
      name: 'Eclipse Smartwatch',
      price: '₹32,400',
      oldPrice: '₹38,000',
      rating: '4.7',
      discount: 15,
      icon: Icons.watch,
    ),

    ProductModel(
      brand: 'MAISON',
      name: 'Arc Mini Crossbody Bag',
      price: '₹9,990',
      oldPrice: '₹12,990',
      rating: '4.6',
      discount: 23,
      icon: Icons.shopping_bag_outlined,
    ),

    ProductModel(
      brand: 'STRIDE',
      name: 'Velvet Runner Knit',
      price: '₹6,490',
      oldPrice: '₹8,990',
      rating: '4.5',
      discount: 28,
      icon: Icons.directions_run,
    ),

    ProductModel(
      brand: 'APPLE',
      name: 'AirPods Pro Gen 2',
      price: '₹22,990',
      oldPrice: '₹26,990',
      rating: '4.9',
      discount: 12,
      icon: Icons.earbuds,
    ),
  ];
}
