import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String uuid;
  final String name;
  final String slug;
  final String? description;
  final String? image;

  const CategoryEntity({
    required this.id,
    required this.uuid,
    required this.name,
    required this.slug,
    this.description,
    this.image,
  });

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

  @override
  List<Object?> get props => [id, uuid, name, slug, description, image];
}
