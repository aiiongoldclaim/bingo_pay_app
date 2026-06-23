import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/categories_model.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(const CategoriesState());

  void loadData() {
    emit(state.copyWith(isLoading: true));

    emit(
      state.copyWith(
        isLoading: false,
        categories: [
          CategoryModel(
            title: 'Electronics',
            items: '1,240 items',
            icon: Icons.devices,
            color: const Color(0xFFEFF2FF),
          ),
          CategoryModel(
            title: 'Fashion',
            items: '3,180 items',
            icon: Icons.shopping_bag_outlined,
            color: const Color(0xFFF8F0D8),
          ),
          CategoryModel(
            title: 'Audio',
            items: '540 items',
            icon: Icons.headphones,
            color: const Color(0xFFE7F4EC),
          ),
          CategoryModel(
            title: 'Home & Living',
            items: '2,010 items',
            icon: Icons.home_outlined,
            color: const Color(0xFFF6EBDD),
          ),
          CategoryModel(
            title: 'Beauty',
            items: '890 items',
            icon: Icons.favorite_border,
            color: const Color(0xFFF8E6F0),
          ),
          CategoryModel(
            title: 'Jewelry',
            items: '320 items',
            icon: Icons.diamond_outlined,
            color: const Color(0xFFF0EBFF),
          ),
          CategoryModel(
            title: 'Watches',
            items: '410 items',
            icon: Icons.watch_outlined,
            color: const Color(0xFFEFF2FF),
          ),
          CategoryModel(
            title: 'Cameras',
            items: '260 items',
            icon: Icons.camera_alt_outlined,
            color: const Color(0xFFEFF2FF),
          ),
        ],
        brands: const ['SONARA', 'NOVA', 'TYDE', 'OPTIK', 'STRIDE', 'MAISON'],
        collections: [
          CuratedCollectionModel(
            title: 'BINGOLD Luxe',
            subtitle: 'Fine jewelry & watches',
            icon: Icons.diamond_outlined,
            iconBg: const Color(0xFFF4EFD9),
          ),
          CuratedCollectionModel(
            title: 'Tech Essentials',
            subtitle: 'Top-rated electronics',
            icon: Icons.bolt,
            iconBg: const Color(0xFFE8EEFF),
          ),
          CuratedCollectionModel(
            title: 'Home Refresh',
            subtitle: 'Furniture & decor',
            icon: Icons.home_outlined,
            iconBg: const Color(0xFFF5EBDD),
          ),
        ],
      ),
    );
  }
}
