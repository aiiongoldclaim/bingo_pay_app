import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/models/categories_model.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import 'categories_state.dart';

@injectable
class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategoriesUseCase _getCategories;
  final GetBrandsUseCase _getBrands;

  CategoriesCubit(this._getCategories, this._getBrands)
      : super(const CategoriesState());

  // Prevents a stale loadData() response from emitting after the screen
  // navigates away or a newer load starts.
  String? _currentRequestId;

  static final List<CuratedCollectionModel> _curatedCollections = [
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
  ];

  // Future<void> loadData() async {
  //   emit(state.copyWith(isLoading: true, isBrandsLoading: true));
  //
  //   final categoriesResult = await _getCategories();
  //   final brandsResult = await _getBrands();
  //
  //   categoriesResult.fold(
  //     (failure) {
  //       emit(state.copyWith(isLoading: false, error: failure.message));
  //     },
  //     (categories) {
  //       brandsResult.fold(
  //         (failure) {
  //           emit(
  //             state.copyWith(
  //               isLoading: false,
  //               categories: categories,
  //               isBrandsLoading: false,
  //               brandsError: failure.message,
  //               collections: [
  //                 CuratedCollectionModel(
  //                   title: 'BINGOLD Luxe',
  //                   subtitle: 'Fine jewelry & watches',
  //                   icon: Icons.diamond_outlined,
  //                   iconBg: const Color(0xFFF4EFD9),
  //                 ),
  //                 CuratedCollectionModel(
  //                   title: 'Tech Essentials',
  //                   subtitle: 'Top-rated electronics',
  //                   icon: Icons.bolt,
  //                   iconBg: const Color(0xFFE8EEFF),
  //                 ),
  //                 CuratedCollectionModel(
  //                   title: 'Home Refresh',
  //                   subtitle: 'Furniture & decor',
  //                   icon: Icons.home_outlined,
  //                   iconBg: const Color(0xFFF5EBDD),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //         (brands) {
  //           emit(
  //             state.copyWith(
  //               isLoading: false,
  //               categories: categories,
  //               brands: brands,
  //               isBrandsLoading: false,
  //               collections: [
  //                 CuratedCollectionModel(
  //                   title: 'BINGOLD Luxe',
  //                   subtitle: 'Fine jewelry & watches',
  //                   icon: Icons.diamond_outlined,
  //                   iconBg: const Color(0xFFF4EFD9),
  //                 ),
  //                 CuratedCollectionModel(
  //                   title: 'Tech Essentials',
  //                   subtitle: 'Top-rated electronics',
  //                   icon: Icons.bolt,
  //                   iconBg: const Color(0xFFE8EEFF),
  //                 ),
  //                 CuratedCollectionModel(
  //                   title: 'Home Refresh',
  //                   subtitle: 'Furniture & decor',
  //                   icon: Icons.home_outlined,
  //                   iconBg: const Color(0xFFF5EBDD),
  //                 ),
  //               ],
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  Future<void> loadData() async {
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    _currentRequestId = requestId;

    emit(state.copyWith(isLoading: true, isBrandsLoading: true));

    final categoriesFuture = _getCategories();
    final brandsFuture = _getBrands();

    final categoriesResult = await categoriesFuture;
    final brandsResult = await brandsFuture;

    if (_currentRequestId != requestId) return; // superseded by a newer call

    var categories = state.categories;
    String? categoriesError;
    categoriesResult.fold(
      (failure) => categoriesError = failure.message,
      (result) => categories = result,
    );

    var brands = state.brands;
    String? brandsErrorMsg;
    brandsResult.fold(
      (failure) => brandsErrorMsg = failure.message,
      (result) => brands = result,
    );

    // Built as a single emit (rather than chained copyWith calls) so a
    // categories-fetch error can't be silently wiped by the brands fold
    // that runs afterward.
    emit(
      state.copyWith(
        isLoading: false,
        isBrandsLoading: false,
        collections: _curatedCollections,
        categories: categories,
        brands: brands,
        error: categoriesError,
        brandsError: brandsErrorMsg,
      ),
    );
  }
}
