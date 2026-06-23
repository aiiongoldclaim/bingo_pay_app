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
  final String? selectedPriceFilter; // "Under ₹20k", "₹20k–₹50k" etc.
  final String? selectedRatingFilter; // "4★ & up"

  const ProductListingLoaded({
    required this.categoryName,
    required this.products,
    required this.filteredProducts,
    this.selectedSort = SortOption.relevant,
    this.viewMode = ViewMode.grid,
    this.selectedPriceFilter,
    this.selectedRatingFilter,
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
  ];
}

class ProductListingError extends ProductListingState {
  final String message;
  const ProductListingError(this.message);
  @override
  List<Object?> get props => [message];
}
