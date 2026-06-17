import 'package:equatable/equatable.dart';
import 'shop_state.dart';

sealed class ShopEvent extends Equatable {
  const ShopEvent();
}

class ShopStarted extends ShopEvent {
  const ShopStarted();

  @override
  List<Object> get props => [];
}

class ShopSearchChanged extends ShopEvent {
  final String query;

  const ShopSearchChanged(this.query);

  @override
  List<Object> get props => [query];
}

class ShopCategorySelected extends ShopEvent {
  final String categorySlug;

  const ShopCategorySelected(this.categorySlug);

  @override
  List<Object> get props => [categorySlug];
}

class ShopSortOptionSelected extends ShopEvent {
  final ShopSortOption sortOption;

  const ShopSortOptionSelected(this.sortOption);

  @override
  List<Object> get props => [sortOption];
}

class ShopViewModeSelected extends ShopEvent {
  final ShopViewMode viewMode;

  const ShopViewModeSelected(this.viewMode);

  @override
  List<Object> get props => [viewMode];
}

class ShopOnlyInStockChanged extends ShopEvent {
  final bool showOnlyInStock;

  const ShopOnlyInStockChanged(this.showOnlyInStock);

  @override
  List<Object> get props => [showOnlyInStock];
}

class ShopProductViewed extends ShopEvent {
  final String productId;

  const ShopProductViewed(this.productId);

  @override
  List<Object> get props => [productId];
}

class ShopAddToCartRequested extends ShopEvent {
  final String productId;

  const ShopAddToCartRequested(this.productId);

  @override
  List<Object> get props => [productId];
}

class ShopQuantityIncreased extends ShopEvent {
  final String productId;

  const ShopQuantityIncreased(this.productId);

  @override
  List<Object> get props => [productId];
}

class ShopQuantityDecreased extends ShopEvent {
  final String productId;

  const ShopQuantityDecreased(this.productId);

  @override
  List<Object> get props => [productId];
}

class ShopItemRemoved extends ShopEvent {
  final String productId;

  const ShopItemRemoved(this.productId);

  @override
  List<Object> get props => [productId];
}

class ShopSaveForLaterToggled extends ShopEvent {
  final String productId;

  const ShopSaveForLaterToggled(this.productId);

  @override
  List<Object> get props => [productId];
}

class ShopFiltersCleared extends ShopEvent {
  const ShopFiltersCleared();

  @override
  List<Object> get props => [];
}

class ShopPromoCodeApplied extends ShopEvent {
  final String promoCode;

  const ShopPromoCodeApplied(this.promoCode);

  @override
  List<Object> get props => [promoCode];
}
