import 'package:flutter/material.dart';

class ProductModel {
  final String brand;
  final String name;
  final String price;
  final String oldPrice;
  final String rating;
  final int discount;
  final IconData icon;
  final List<String> images;

  ProductModel({
    required this.brand,
    required this.name,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.discount,
    required this.icon,
    required this.images,
  });

  static List<ProductModel> flashDeals() => [
    ProductModel(
      brand: 'NOVA',
      name: 'Helios 5G Smartphone 256GB',
      price: '64,999',
      oldPrice: '72,999',
      rating: '4.6',
      discount: 11,
      icon: Icons.smartphone_outlined,
      images: [
        'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9',
        'https://images.unsplash.com/photo-1598327105666-5b89351aff97',
        'https://images.unsplash.com/photo-1580910051074-3eb694886505',
      ],
    ),

    ProductModel(
      brand: 'SONARA',
      name: 'Aurora Pro Wireless Headphones',
      price: '18,990',
      oldPrice: '24,990',
      rating: '4.8',
      discount: 24,
      icon: Icons.headphones_outlined,
      images: [
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e',
        'https://images.unsplash.com/photo-1484704849700-f032a568e944',
        'https://images.unsplash.com/photo-1546435770-a3e426bf472b',
      ],
    ),

    ProductModel(
      brand: 'OPTIX',
      name: 'Lumina Smart Camera',
      price: '8,990',
      oldPrice: '11,990',
      rating: '4.7',
      discount: 20,
      icon: Icons.camera_alt_outlined,
      images: [
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32',
        'https://images.unsplash.com/photo-1502920917128-1aa500764ce7',
        'https://images.unsplash.com/photo-1495707902641-75cac588d2e9',
      ],
    ),

    ProductModel(
      brand: 'TYDE',
      name: 'Eclipse Smartwatch',
      price: '32,400',
      oldPrice: '389876',
      rating: '4.7',
      discount: 20,
      icon: Icons.camera_alt_outlined,
      images: [
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
        'https://images.unsplash.com/photo-1434494878577-86c23bcb06b9',
        'https://images.unsplash.com/photo-1546868871-7041f2a55e12',
      ],
    ),
  ];

  static List<ProductModel> recommended() => [
    ProductModel(
      brand: 'TYDE',
      name: 'Eclipse Smartwatch',
      price: '32,400',
      oldPrice: '38,000',
      rating: '4.7',
      discount: 15,
      icon: Icons.watch,
      images: [
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
        'https://images.unsplash.com/photo-1546868871-7041f2a55e12',
      ],
    ),

    ProductModel(
      brand: 'MAISON',
      name: 'Arc Mini Crossbody Bag',
      price: '9,990',
      oldPrice: '12,990',
      rating: '4.6',
      discount: 23,
      icon: Icons.shopping_bag_outlined,
      images: [
        'https://images.unsplash.com/photo-1584917865442-de89df76afd3',
        'https://images.unsplash.com/photo-1591561954557-26941169b49e',
      ],
    ),

    ProductModel(
      brand: 'STRIDE',
      name: 'Velvet Runner Knit',
      price: '6,490',
      oldPrice: '8,990',
      rating: '4.5',
      discount: 28,
      icon: Icons.directions_run,
      images: [
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
        'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519',
      ],
    ),

    ProductModel(
      brand: 'APPLE',
      name: 'AirPods Pro Gen 2',
      price: '22,990',
      oldPrice: '26,990',
      rating: '4.9',
      discount: 12,
      icon: Icons.earbuds,
      images: [
        'https://images.unsplash.com/photo-1606220588913-b3aacb4d2f46',
        'https://images.unsplash.com/photo-1588423771073-b8903fbb85b5',
      ],
    ),
  ];
}
