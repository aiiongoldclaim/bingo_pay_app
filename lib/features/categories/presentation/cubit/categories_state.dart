import 'package:bingo_pay/features/categories/data/categories_model.dart';
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
