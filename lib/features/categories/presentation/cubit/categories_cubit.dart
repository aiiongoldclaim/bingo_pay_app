import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/config/app_config.dart';
import '../../data/models/categories_model.dart';
import '../../data/models/categories_response_model.dart';
import 'categories_state.dart';

class CategoriesCubit extends Cubit<CategoriesState> {
  CategoriesCubit() : super(const CategoriesState());

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final client = GetIt.I<ApiClient>();
      final url =
          '${AppConfig.categoriesApiBaseUrl}${ApiEndpoints.categories}';
      final response = await client.dio.get(url);
      final result = CategoryResponseModel.fromJson(
          response.data as Map<String, dynamic>);
      final filtered = result.data
          .where((c) => c.parentId == null && c.isActive)
          .toList();
      emit(state.copyWith(
        isLoading: false,
        categories: filtered,
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
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }
}
