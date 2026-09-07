import 'package:equatable/equatable.dart';
import '../../data/models/product_categories_model.dart';

enum SortOption { relevant, priceLow, priceHigh, rating }

enum ViewMode { grid, list }

abstract class ProductListingState extends Equatable {
  const ProductListingState();
  @override
  List<Object?> get props => [];
}

class ProductListingLoading extends ProductListingState {
  const ProductListingLoading();
}

class ProductListingLoaded extends ProductListingState {
  final String categoryName;
  final List<ListingProductModel> products;
  final List<ListingProductModel> filteredProducts;
  final SortOption selectedSort;
  final ViewMode viewMode;
  final String? selectedPriceFilter;
  final String? selectedRatingFilter;
  final bool isCachedData;
  final String? cachedTimeAgo;
  final bool isStaleData;

  final int currentPage;
  final bool hasMorePages;
  final bool isLoadingMore;

  const ProductListingLoaded({
    required this.categoryName,
    required this.products,
    required this.filteredProducts,
    this.selectedSort = SortOption.relevant,
    this.viewMode = ViewMode.grid,
    this.selectedPriceFilter,
    this.selectedRatingFilter,
    this.isCachedData = false,
    this.cachedTimeAgo,
    this.isStaleData = false,
    this.currentPage = 1,
    this.hasMorePages = false,
    this.isLoadingMore = false,
  });

  ProductListingLoaded copyWith({
    List<ListingProductModel>? products,
    List<ListingProductModel>? filteredProducts,
    SortOption? selectedSort,
    ViewMode? viewMode,
    String? selectedPriceFilter,
    String? selectedRatingFilter,
    bool clearPriceFilter = false,
    bool clearRatingFilter = false,
    bool? isCachedData,
    String? cachedTimeAgo,
    bool? isStaleData,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return ProductListingLoaded(
      categoryName: categoryName,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      selectedSort: selectedSort ?? this.selectedSort,
      viewMode: viewMode ?? this.viewMode,
      selectedPriceFilter: clearPriceFilter
          ? null
          : selectedPriceFilter ?? this.selectedPriceFilter,
      selectedRatingFilter: clearRatingFilter
          ? null
          : selectedRatingFilter ?? this.selectedRatingFilter,
      isCachedData: isCachedData ?? this.isCachedData,
      cachedTimeAgo: cachedTimeAgo ?? this.cachedTimeAgo,
      isStaleData: isStaleData ?? this.isStaleData,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    categoryName,
    filteredProducts,
    selectedSort,
    viewMode,
    selectedPriceFilter,
    selectedRatingFilter,
    isCachedData,
    cachedTimeAgo,
    isStaleData,
    currentPage,
    hasMorePages,
    isLoadingMore,
  ];
}

class ProductListingError extends ProductListingState {
  final String message;
  final bool isRateLimited;
  final int? retryAfterSeconds;

  const ProductListingError({
    required this.message,
    this.isRateLimited = false,
    this.retryAfterSeconds,
  });

  @override
  List<Object?> get props => [message, isRateLimited, retryAfterSeconds];
}
