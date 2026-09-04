import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../account/domain/usecase/get_account_usecase.dart';
import '../../../categories/data/datasources/category_remote_datasource.dart';
import '../../../categories/data/models/categories_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/all_products_repo.dart';
import 'dashboard_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final CategoryRemoteDataSource _categoryDataSource;
  final GetProfileUseCase _getProfile;
  final ProductRepository _productRepository;

  HomeCubit(
    this._categoryDataSource,
    this._getProfile,
    this._productRepository,
  ) : super(const HomeState());

  // Prevents an overlapping loadHome() call (e.g. rapid pull-to-refresh)
  // from having its stale response overwrite a newer one.
  String? _currentRequestId;

  Future<void> loadHome() async {
    final requestId = DateTime.now().microsecondsSinceEpoch.toString();
    _currentRequestId = requestId;

    emit(state.copyWith(status: HomeStatus.loading));

    List<CategoryModel> categories = [];
    String userName = '';
    double bigoldBalance = 0.0;
    var categoriesFailed = false;
    var profileFailed = false;
    var productsFailed = false;

    // Fetch categories
    try {
      final categoryResult = await _categoryDataSource.getCategories();
      categories = categoryResult.data
          .where((e) => e.parentId == null && e.isActive)
          .toList();
      debugPrint('Categories loaded: ${categories.length}');
    } catch (e) {
      debugPrint('Category error: $e');
      categoriesFailed = true;
    }

    // Fetch profile
    final profileResult = await _getProfile();
    profileResult.fold(
      (failure) {
        profileFailed = true;
        debugPrint('✗ Profile error: ${failure.message}');
      },
      (account) {
        userName = account.fullName;
        bigoldBalance = account.displayBigoldBalance;
        debugPrint(
          '✓ Profile loaded: raw=${account.bigoldBalance} display=${account.displayBigoldBalance}',
        );
      },
    );

    List<ProductModel> products = [];
    try {
      products = await _productRepository.getAllProducts(page: 1, limit: 20);
      debugPrint('✓ Loaded ${products.length} products for home');
    } catch (e) {
      debugPrint('✗ Failed to load home products: $e');
      products = [];
      productsFailed = true;
    }


    if (_currentRequestId != requestId) return; // superseded by a newer call

    if (categoriesFailed && profileFailed && productsFailed) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Failed to load your dashboard. Please try again.',
        ),
      );
      return;
    }


    final discounted = products.where((p) => p.discount > 0).toList()
      ..sort((a, b) => b.discount.compareTo(a.discount));
    final flashDeals = discounted.take(6).toList();
    final flashDealSet = flashDeals.toSet();
    final recommended = products.where((p) => !flashDealSet.contains(p)).toList();

    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        userName: userName,
        bigoldBalance: bigoldBalance,
        categories: categories,
        flashDeals: flashDeals,
        recommended: recommended,
      ),
    );
  }
}
