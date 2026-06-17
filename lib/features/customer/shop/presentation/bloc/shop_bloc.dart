import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/shop_fixture_data.dart';
import '../../domain/entities/cart_item.dart';
import 'shop_event.dart';
import 'shop_state.dart';

class ShopBloc extends Bloc<ShopEvent, ShopState> {
  ShopBloc() : super(ShopState.initial()) {
    on<ShopStarted>(_onStarted);
    on<ShopSearchChanged>(_onSearchChanged);
    on<ShopCategorySelected>(_onCategorySelected);
    on<ShopSortOptionSelected>(_onSortOptionSelected);
    on<ShopViewModeSelected>(_onViewModeSelected);
    on<ShopOnlyInStockChanged>(_onOnlyInStockChanged);
    on<ShopProductViewed>(_onProductViewed);
    on<ShopAddToCartRequested>(_onAddToCartRequested);
    on<ShopQuantityIncreased>(_onQuantityIncreased);
    on<ShopQuantityDecreased>(_onQuantityDecreased);
    on<ShopItemRemoved>(_onItemRemoved);
    on<ShopSaveForLaterToggled>(_onSaveForLaterToggled);
    on<ShopFiltersCleared>(_onFiltersCleared);
    on<ShopPromoCodeApplied>(_onPromoCodeApplied);
  }

  Future<void> _onStarted(ShopStarted event, Emitter<ShopState> emit) async {
    emit(
      state.copyWith(
        isLoading: false,
        categories: ShopFixtureData.categories,
        products: ShopFixtureData.products,
      ),
    );
  }

  void _onSearchChanged(
    ShopSearchChanged event,
    Emitter<ShopState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onCategorySelected(
    ShopCategorySelected event,
    Emitter<ShopState> emit,
  ) {
    emit(state.copyWith(selectedCategorySlug: event.categorySlug));
  }

  void _onSortOptionSelected(
    ShopSortOptionSelected event,
    Emitter<ShopState> emit,
  ) {
    emit(state.copyWith(sortOption: event.sortOption));
  }

  void _onViewModeSelected(
    ShopViewModeSelected event,
    Emitter<ShopState> emit,
  ) {
    emit(state.copyWith(viewMode: event.viewMode));
  }

  void _onOnlyInStockChanged(
    ShopOnlyInStockChanged event,
    Emitter<ShopState> emit,
  ) {
    emit(state.copyWith(showOnlyInStock: event.showOnlyInStock));
  }

  void _onProductViewed(
    ShopProductViewed event,
    Emitter<ShopState> emit,
  ) {
    final ids = <String>[event.productId];
    ids.addAll(state.recentlyViewedProductIds.where((id) => id != event.productId));
    emit(
      state.copyWith(
        recentlyViewedProductIds: ids.take(6).toList(),
      ),
    );
  }

  void _onAddToCartRequested(
    ShopAddToCartRequested event,
    Emitter<ShopState> emit,
  ) {
    final product = state.productById(event.productId);
    if (product == null) return;

    final items = List<CartItem>.from(state.cartItems);
    final index = items.indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      items[index] = items[index].copyWith(quantity: items[index].quantity + 1);
    } else {
      items.add(CartItem(product: product, quantity: 1));
    }

    emit(
      state.copyWith(
        cartItems: items,
        savedForLaterProductIds: state.savedForLaterProductIds
            .where((id) => id != event.productId)
            .toList(),
      ),
    );
  }

  void _onQuantityIncreased(
    ShopQuantityIncreased event,
    Emitter<ShopState> emit,
  ) {
    final items = _updateQuantity(event.productId, 1);
    emit(state.copyWith(cartItems: items));
  }

  void _onQuantityDecreased(
    ShopQuantityDecreased event,
    Emitter<ShopState> emit,
  ) {
    final items = _updateQuantity(event.productId, -1);
    emit(state.copyWith(cartItems: items));
  }

  void _onItemRemoved(
    ShopItemRemoved event,
    Emitter<ShopState> emit,
  ) {
    emit(
      state.copyWith(
        cartItems: state.cartItems
            .where((item) => item.product.id != event.productId)
            .toList(),
      ),
    );
  }

  void _onSaveForLaterToggled(
    ShopSaveForLaterToggled event,
    Emitter<ShopState> emit,
  ) {
    final saved = List<String>.from(state.savedForLaterProductIds);
    if (saved.contains(event.productId)) {
      saved.remove(event.productId);
    } else {
      saved.add(event.productId);
    }

    emit(
      state.copyWith(
        savedForLaterProductIds: saved,
        cartItems: state.cartItems
            .where((item) => item.product.id != event.productId)
            .toList(),
      ),
    );
  }

  void _onFiltersCleared(
    ShopFiltersCleared event,
    Emitter<ShopState> emit,
  ) {
    emit(
      state.copyWith(
        searchQuery: '',
        selectedCategorySlug: '',
        sortOption: ShopSortOption.featured,
        showOnlyInStock: false,
      ),
    );
  }

  void _onPromoCodeApplied(
    ShopPromoCodeApplied event,
    Emitter<ShopState> emit,
  ) {
    emit(state.copyWith(promoCode: event.promoCode.trim().toUpperCase()));
  }

  List<CartItem> _updateQuantity(String productId, int delta) {
    final items = List<CartItem>.from(state.cartItems);
    final index = items.indexWhere((item) => item.product.id == productId);
    if (index < 0) return items;

    final nextQuantity = items[index].quantity + delta;
    if (nextQuantity <= 0) {
      items.removeAt(index);
    } else {
      items[index] = items[index].copyWith(quantity: nextQuantity);
    }
    return items;
  }
}
