import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../profile/domain/usecase/get_profile_usecase.dart';
import '../../../categories/data/datasources/category_remote_datasource.dart';
import '../../../categories/data/models/categories_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/all_products_repo.dart';
import '../models/vault_section.dart';
import 'dashboard_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  final CategoryRemoteDataSource _categoryDataSource;
  final GetProfileUseCase _getProfile;
  final ProductRepository _productRepository;

  HomeCubit(this._categoryDataSource, this._getProfile, this._productRepository)
    : super(const HomeState());

  String? _currentRequestId;
  int _requestCounter = 0;
  List<ProductModel> _allProducts = const [];

  int _sectionRequestCounter = 0;
  int? _currentSectionRequestId;

  Future<void> loadHome() async {
    final requestId = (++_requestCounter).toString();
    _currentRequestId = requestId;
    // A fresh full-dashboard load supersedes any in-flight section switch —
    // its own emit below already reflects the currently selected section.
    _currentSectionRequestId = null;

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

    if (isClosed || _currentRequestId != requestId) return;

    if (categoriesFailed && profileFailed && productsFailed) {
      emit(
        state.copyWith(
          status: HomeStatus.error,
          errorMessage: 'Failed to load your dashboard. Please try again.',
        ),
      );
      return;
    }

    _allProducts = products;

    final currentSection = state.selectedVaultSection;
    if (currentSection != VaultSection.theVaults) {
      // The tier's own products live behind a separate, membership-aware
      // API query (see selectVaultSection) — refetch it too so a
      // pull-to-refresh on Vaults Luxe / Ultra Luxe doesn't go stale.
      emit(
        state.copyWith(
          status: HomeStatus.loaded,
          userName: userName,
          bigoldBalance: bigoldBalance,
          categories: categories,
          vaultContentStatus: VaultContentStatus.loading,
        ),
      );
      await _loadSectionProducts(currentSection);
      return;
    }

    final split = _splitTheVaults();
    emit(
      state.copyWith(
        status: HomeStatus.loaded,
        userName: userName,
        bigoldBalance: bigoldBalance,
        categories: categories,
        flashDeals: split.flashDeals,
        recommended: split.recommended,
        vaultContentStatus: VaultContentStatus.loaded,
      ),
    );
  }

  /// Switches the top app bar's active brand section.
  ///
  /// TheVaults is the existing dashboard: it re-slices the already-fetched
  /// products instantly, no loading step. Vaults Luxe / Ultra Luxe are
  /// treated as their own dashboards — selecting one shows a skeleton and
  /// fetches that tier directly from the backend via
  /// `?listingLevel=LUXE|ULTRA_LUXE` (a membership-gated query the regular
  /// catalogue fetch never sends), rather than filtering the already-loaded
  /// public product list, which structurally never contains these products.
  Future<void> selectVaultSection(VaultSection section) async {
    if (state.selectedVaultSection == section &&
        state.vaultContentStatus == VaultContentStatus.loaded) {
      return;
    }

    if (section == VaultSection.theVaults) {
      // Abandons any Vaults Luxe / Ultra Luxe fetch still in flight.
      _currentSectionRequestId = null;
      final split = _splitTheVaults();
      emit(
        state.copyWith(
          selectedVaultSection: section,
          vaultContentStatus: VaultContentStatus.loaded,
          flashDeals: split.flashDeals,
          recommended: split.recommended,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        selectedVaultSection: section,
        vaultContentStatus: VaultContentStatus.loading,
      ),
    );

    await _loadSectionProducts(section);
  }

  /// Fetches Vaults Luxe / Ultra Luxe products straight from the backend
  /// (`?listingLevel=...`) and emits them once loaded. Guarded by a request
  /// id so an in-flight fetch abandoned by a newer section switch (or a
  /// fresh [loadHome]) can never clobber state after the fact.
  Future<void> _loadSectionProducts(VaultSection section) async {
    final requestId = ++_sectionRequestCounter;
    _currentSectionRequestId = requestId;

    List<ProductModel> tierProducts = [];
    try {
      tierProducts = await _productRepository.getAllProducts(
        page: 1,
        limit: 20,
        listingLevel: section == VaultSection.ultraLuxe
            ? 'ULTRA_LUXE'
            : 'LUXE',
      );
      debugPrint(
        '✓ Loaded ${tierProducts.length} products for $section',
      );
    } catch (e) {
      debugPrint('✗ Failed to load $section products: $e');
      tierProducts = [];
    }

    if (isClosed || _currentSectionRequestId != requestId) return;

    // Defensive re-check even though the query already asked the backend
    // for this exact tier — guards against a response that includes
    // something outside it.
    final tier = tierProducts
        .where(
          (p) => section == VaultSection.ultraLuxe
              ? p.isUltraLuxe
              : p.isVaultsLuxe,
        )
        .toList();
    final flashDeals = tier.take(6).toList();
    final flashDealSet = flashDeals.toSet();
    final recommended = tier
        .where((p) => !flashDealSet.contains(p))
        .toList();

    emit(
      state.copyWith(
        vaultContentStatus: VaultContentStatus.loaded,
        flashDeals: flashDeals,
        recommended: recommended,
      ),
    );
  }

  ({List<ProductModel> flashDeals, List<ProductModel> recommended})
  _splitTheVaults() {
    if (_allProducts.isEmpty) {
      return (flashDeals: const [], recommended: const []);
    }

    final discounted = _allProducts.where((p) => p.discount > 0).toList()
      ..sort((a, b) => b.discount.compareTo(a.discount));
    final flashDeals = discounted.take(6).toList();
    final flashDealSet = flashDeals.toSet();
    final recommended = _allProducts
        .where((p) => !flashDealSet.contains(p))
        .toList();
    return (flashDeals: flashDeals, recommended: recommended);
  }
}
