import 'package:equatable/equatable.dart';

import '../../data/models/categories_model.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/category_entity.dart';

class CategoriesState extends Equatable {
  final bool isLoading;
  final List<CategoryEntity> categories;
  final List<BrandEntity> brands;
  final bool isBrandsLoading;
  final String? brandsError;
  final List<CuratedCollectionModel> collections;
  final String? error;

  const CategoriesState({
    this.isLoading = false,
    this.categories = const [],
    this.brands = const [],
    this.isBrandsLoading = false,
    this.brandsError,
    this.collections = const [],
    this.error,
  });

  CategoriesState copyWith({
    bool? isLoading,
    List<CategoryEntity>? categories,
    List<BrandEntity>? brands,
    bool? isBrandsLoading,
    String? brandsError,
    List<CuratedCollectionModel>? collections,
    String? error,
  }) {
    return CategoriesState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      isBrandsLoading: isBrandsLoading ?? this.isBrandsLoading,
      brandsError: brandsError ?? this.brandsError,
      collections: collections ?? this.collections,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    categories,
    brands,
    isBrandsLoading,
    brandsError,
    collections,
    error,
  ];
}

// import '../../domain/entities/category_entity.dart';
//
// class CategoriesState {
//   final bool loading;
//
//   final List<CategoryEntity> categories;
//
//   final String? error;
//
//   const CategoriesState({
//     this.loading = false,
//
//     this.categories = const [],
//
//     this.error,
//   });
//
//   CategoriesState copyWith({
//     bool? loading,
//
//     List<CategoryEntity>? categories,
//
//     String? error,
//   }) {
//     return CategoriesState(
//       loading: loading ?? this.loading,
//
//       categories: categories ?? this.categories,
//
//       error: error,
//     );
//   }
// }
