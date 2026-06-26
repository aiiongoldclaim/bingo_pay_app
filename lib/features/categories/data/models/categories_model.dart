import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String uuid;
  final String name;
  final String slug;
  final String? description;
  final String? image;
  final String? parentId;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    this.description,
    this.image,
    this.parentId,
    this.isActive = true,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as String,
        uuid: json['uuid'] as String,
        name: json['name'] as String,
        slug: json['slug'] as String,
        description: json['description'] as String?,
        image: json['image'] as String?,
        parentId: json['parentId'] as String?,
        isActive: json['isActive'] as bool? ?? true,
      );

  IconData get icon {
    switch (slug) {
      case 'electronics':
        return Icons.devices_outlined;
      case 'fashion':
        return Icons.shopping_bag_outlined;
      case 'audio':
        return Icons.headphones_outlined;
      case 'home-kitchen':
        return Icons.home_outlined;
      case 'beauty-personal-care':
        return Icons.favorite_border;
      case 'books':
        return Icons.menu_book_outlined;
      case 'toys-games':
        return Icons.sports_esports_outlined;
      case 'groceries':
        return Icons.local_grocery_store_outlined;
      case 'sports-fitness':
        return Icons.fitness_center_outlined;
      case 'fan':
        return Icons.wind_power_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Color get color {
    switch (slug) {
      case 'electronics':
        return const Color(0xFFEFF2FF);
      case 'fashion':
        return const Color(0xFFF8F0D8);
      case 'audio':
        return const Color(0xFFE7F4EC);
      case 'home-kitchen':
        return const Color(0xFFF6EBDD);
      case 'beauty-personal-care':
        return const Color(0xFFF8E6F0);
      case 'books':
        return const Color(0xFFF0EBFF);
      case 'toys-games':
        return const Color(0xFFE8F5E9);
      case 'groceries':
        return const Color(0xFFFFF3E0);
      case 'sports-fitness':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFF5F5F5);
    }
  }
}

class CuratedCollectionModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;

  CuratedCollectionModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
  });
}
