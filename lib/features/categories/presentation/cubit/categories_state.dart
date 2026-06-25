import 'package:bingo_pay/features/categories/data/models/categories_model.dart';
import 'package:equatable/equatable.dart';

class CategoriesState extends Equatable {
  final List<CategoryModel> categories;
  final List<String> brands;
  final List<CuratedCollectionModel> collections;
  final bool isLoading;

  const CategoriesState({
    this.categories = const [],
    this.brands = const [],
    this.collections = const [],
    this.isLoading = false,
  });

  CategoriesState copyWith({
    List<CategoryModel>? categories,
    List<String>? brands,
    List<CuratedCollectionModel>? collections,
    bool? isLoading,
  }) {
    return CategoriesState(
      categories: categories ?? this.categories,
      brands: brands ?? this.brands,
      collections: collections ?? this.collections,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [categories, brands, collections, isLoading];
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
