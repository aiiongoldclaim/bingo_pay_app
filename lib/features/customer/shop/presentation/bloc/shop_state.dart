import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/shop_category.dart';
import '../../domain/entities/shop_product.dart';

enum ShopViewMode { grid, list }

enum ShopSortOption {
  featured,
  priceLowToHigh,
  priceHighToLow,
  topRated,
  newest,
}

extension ShopSortOptionLabel on ShopSortOption {
  String get label => switch (this) {
        ShopSortOption.featured => 'Featured',
        ShopSortOption.priceLowToHigh => 'Price: Low to High',
        ShopSortOption.priceHighToLow => 'Price: High to Low',
        ShopSortOption.topRated => 'Top rated',
        ShopSortOption.newest => 'Newest',
      };
}

class ShopState extends Equatable {
  static const Object _unset = Object();

  final bool isLoading;
  final String? errorMessage;
  final List<ShopCategory> categories;
  final List<ShopProduct> products;
  final List<CartItem> cartItems;
  final List<String> recentlyViewedProductIds;
  final List<String> savedForLaterProductIds;
  final String searchQuery;
  final String selectedCategorySlug;
  final ShopSortOption sortOption;
  final ShopViewMode viewMode;
  final bool showOnlyInStock;
  final String promoCode;

  const ShopState({
    required this.isLoading,
    required this.errorMessage,
    required this.categories,
    required this.products,
    required this.cartItems,
    required this.recentlyViewedProductIds,
    required this.savedForLaterProductIds,
    required this.searchQuery,
    required this.selectedCategorySlug,
    required this.sortOption,
    required this.viewMode,
    required this.showOnlyInStock,
    required this.promoCode,
  });

  factory ShopState.initial() {
    return const ShopState(
      isLoading: true,
      errorMessage: null,
      categories: [],
      products: [],
      cartItems: [],
      recentlyViewedProductIds: [],
      savedForLaterProductIds: [],
      searchQuery: '',
      selectedCategorySlug: '',
      sortOption: ShopSortOption.featured,
      viewMode: ShopViewMode.grid,
      showOnlyInStock: false,
      promoCode: '',
    );
  }

  ShopState copyWith({
    Object? isLoading = _unset,
    Object? errorMessage = _unset,
    Object? categories = _unset,
    Object? products = _unset,
    Object? cartItems = _unset,
    Object? recentlyViewedProductIds = _unset,
    Object? savedForLaterProductIds = _unset,
    Object? searchQuery = _unset,
    Object? selectedCategorySlug = _unset,
    Object? sortOption = _unset,
    Object? viewMode = _unset,
    Object? showOnlyInStock = _unset,
    Object? promoCode = _unset,
  }) {
    return ShopState(
      isLoading: identical(isLoading, _unset)
          ? this.isLoading
          : isLoading as bool,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      categories: identical(categories, _unset)
          ? this.categories
          : categories as List<ShopCategory>,
      products: identical(products, _unset)
          ? this.products
          : products as List<ShopProduct>,
      cartItems:
          identical(cartItems, _unset) ? this.cartItems : cartItems as List<CartItem>,
      recentlyViewedProductIds: identical(recentlyViewedProductIds, _unset)
          ? this.recentlyViewedProductIds
          : recentlyViewedProductIds as List<String>,
      savedForLaterProductIds: identical(savedForLaterProductIds, _unset)
          ? this.savedForLaterProductIds
          : savedForLaterProductIds as List<String>,
      searchQuery: identical(searchQuery, _unset)
          ? this.searchQuery
          : searchQuery as String,
      selectedCategorySlug: identical(selectedCategorySlug, _unset)
          ? this.selectedCategorySlug
          : selectedCategorySlug as String,
      sortOption: identical(sortOption, _unset)
          ? this.sortOption
          : sortOption as ShopSortOption,
      viewMode:
          identical(viewMode, _unset) ? this.viewMode : viewMode as ShopViewMode,
      showOnlyInStock: identical(showOnlyInStock, _unset)
          ? this.showOnlyInStock
          : showOnlyInStock as bool,
      promoCode:
          identical(promoCode, _unset) ? this.promoCode : promoCode as String,
    );
  }

  ShopCategory? get selectedCategory {
    if (selectedCategorySlug.isEmpty) return null;
    for (final category in categories) {
      if (category.slug == selectedCategorySlug) return category;
    }
    return null;
  }

  ShopProduct? productById(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  CartItem? cartItemByProductId(String productId) {
    for (final item in cartItems) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  List<ShopProduct> get filteredProducts {
    Iterable<ShopProduct> results = products;

    if (selectedCategorySlug.isNotEmpty) {
      results = results.where((product) => product.categorySlug == selectedCategorySlug);
    }

    if (searchQuery.trim().isNotEmpty) {
      final query = searchQuery.toLowerCase();
      results = results.where(
        (product) =>
            product.name.toLowerCase().contains(query) ||
            product.brand.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query) ||
            product.badges.any((badge) => badge.toLowerCase().contains(query)),
      );
    }

    if (showOnlyInStock) {
      results = results.where((product) => product.inStock);
    }

    final list = results.toList();
    switch (sortOption) {
      case ShopSortOption.featured:
        list.sort((a, b) {
          if (a.isFeatured != b.isFeatured) return a.isFeatured ? -1 : 1;
          if (a.isTrending != b.isTrending) return a.isTrending ? -1 : 1;
          return b.rating.compareTo(a.rating);
        });
        break;
      case ShopSortOption.priceLowToHigh:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ShopSortOption.priceHighToLow:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ShopSortOption.topRated:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ShopSortOption.newest:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return list;
  }

  List<ShopProduct> get featuredProducts =>
      products.where((product) => product.isFeatured).toList();

  List<ShopProduct> get trendingProducts =>
      products.where((product) => product.isTrending).toList();

  List<ShopProduct> get recentlyViewedProducts {
    return recentlyViewedProductIds
        .map(productById)
        .whereType<ShopProduct>()
        .toList();
  }

  List<ShopProduct> get savedForLaterProducts {
    return savedForLaterProductIds
        .map(productById)
        .whereType<ShopProduct>()
        .toList();
  }

  int get cartCount =>
      cartItems.fold<int>(0, (total, item) => total + item.quantity);

  double get cartSubtotal =>
      cartItems.fold<double>(0, (total, item) => total + item.lineTotal);

  double get promoDiscount {
    if (promoCode.toUpperCase() == 'SAVE10') {
      return cartSubtotal * 0.10;
    }
    return 0;
  }

  double get shippingFee {
    if (promoCode.toUpperCase() == 'FREESHIP') {
      return 0;
    }
    return cartSubtotal >= 12000 ? 0 : 699;
  }

  double get taxAmount {
    final taxable = cartSubtotal - promoDiscount;
    return taxable * 0.08;
  }

  double get cartTotal =>
      (cartSubtotal - promoDiscount + shippingFee + taxAmount);

  @override
  List<Object?> get props => [
        isLoading,
        errorMessage,
        categories,
        products,
        cartItems,
        recentlyViewedProductIds,
        savedForLaterProductIds,
        searchQuery,
        selectedCategorySlug,
        sortOption,
        viewMode,
        showOnlyInStock,
        promoCode,
      ];
}
