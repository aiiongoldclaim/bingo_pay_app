import 'package:bingo_pay/features/product_categories_details/presentation/product_categories_cubit/product_categories_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_categories_model.dart';

class ProductListingCubit extends Cubit<ProductListingState> {
  ProductListingCubit() : super(const ProductListingLoading());

  // ── Mock data — replace with repository call ─────────────────────────────
  static List<ListingProductModel> _mockProducts(String category) => [
    ListingProductModel(
      id: '1',
      brand: 'NOVA',
      name: 'Helios 5G Smartphone 256GB',
      price: 64999,
      originalPrice: 72999,
      rating: 4.6,
      ratingCount: 4900,
      badge: '-11%',
      icon: Icons.smartphone_outlined,
    ),
    ListingProductModel(
      id: '2',
      brand: 'SONARA',
      name: 'Aurora Pro Wireless Headphones',
      price: 18990,
      originalPrice: 24990,
      rating: 4.8,
      ratingCount: 2100,
      badge: 'BESTSELLER',
      icon: Icons.gps_fixed_outlined,
      isFavourite: true,
    ),
    ListingProductModel(
      id: '3',
      brand: 'TYDE',
      name: 'Eclipse Smartwatch Series 7',
      price: 32400,
      originalPrice: 38000,
      rating: 4.7,
      ratingCount: 1300,
      badge: 'NEW',
      icon: Icons.watch_outlined,
    ),
    ListingProductModel(
      id: '4',
      brand: 'OPTIK',
      name: 'Lumen Mirrorless Camera Kit',
      price: 87500,
      originalPrice: 99000,
      rating: 4.9,
      ratingCount: 600,
      badge: 'PRO',
      icon: Icons.camera_alt_outlined,
    ),
    ListingProductModel(
      id: '5',
      brand: 'NOVA',
      name: 'Helios Tab X Pro',
      price: 45999,
      originalPrice: 54999,
      rating: 4.5,
      ratingCount: 980,
      icon: Icons.tablet_outlined,
    ),
    ListingProductModel(
      id: '6',
      brand: 'SONARA',
      name: 'BassBoom Speaker 360',
      price: 8990,
      originalPrice: 11990,
      rating: 4.3,
      ratingCount: 3200,
      badge: '-25%',
      icon: Icons.speaker_outlined,
    ),
  ];

  // ── Load ─────────────────────────────────────────────────────────────────

  Future<void> loadCategory(String categoryName) async {
    try {
      emit(const ProductListingLoading());
      await Future.delayed(const Duration(milliseconds: 400));
      final products = _mockProducts(categoryName);
      emit(
        ProductListingLoaded(
          categoryName: categoryName,
          products: products,
          filteredProducts: products,
        ),
      );
    } catch (e) {
      emit(ProductListingError(e.toString()));
    }
  }

  // ── Toggle view mode ─────────────────────────────────────────────────────

  void toggleViewMode() {
    final s = state;
    if (s is! ProductListingLoaded) return;
    emit(
      s.copyWith(
        viewMode: s.viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid,
      ),
    );
  }

  // ── Sort ─────────────────────────────────────────────────────────────────

  void applySort(SortOption sort) {
    final s = state;
    if (s is! ProductListingLoaded) return;
    final sorted = List<ListingProductModel>.from(s.filteredProducts);
    switch (sort) {
      case SortOption.priceLow:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHigh:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        sorted.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
        break;
      case SortOption.relevant:
        break;
    }
    emit(s.copyWith(filteredProducts: sorted, selectedSort: sort));
  }

  // ── Price filter ─────────────────────────────────────────────────────────

  void applyPriceFilter(String label) {
    final s = state;
    if (s is! ProductListingLoaded) return;

    // Toggle off if already selected
    if (s.selectedPriceFilter == label) {
      emit(
        s.copyWith(
          filteredProducts: _applyRatingFilter(
            s.products,
            s.selectedRatingFilter,
          ),
          clearPriceFilter: true,
        ),
      );
      return;
    }

    List<ListingProductModel> filtered = s.products;
    switch (label) {
      case 'Under ₹20k':
        filtered = s.products.where((p) => p.price < 20000).toList();
        break;
      case '₹20k–₹50k':
        filtered = s.products
            .where((p) => p.price >= 20000 && p.price <= 50000)
            .toList();
        break;
      case 'Above ₹50k':
        filtered = s.products.where((p) => p.price > 50000).toList();
        break;
    }
    filtered = _applyRatingFilter(filtered, s.selectedRatingFilter);
    emit(s.copyWith(filteredProducts: filtered, selectedPriceFilter: label));
  }

  // ── Rating filter ─────────────────────────────────────────────────────────

  void applyRatingFilter(String label) {
    final s = state;
    if (s is! ProductListingLoaded) return;

    if (s.selectedRatingFilter == label) {
      emit(
        s.copyWith(
          filteredProducts: _applyPriceFilter(
            s.products,
            s.selectedPriceFilter,
          ),
          clearRatingFilter: true,
        ),
      );
      return;
    }

    List<ListingProductModel> filtered = _applyPriceFilter(
      s.products,
      s.selectedPriceFilter,
    );
    if (label == '4★ & up') {
      filtered = filtered.where((p) => (p.rating ?? 0) >= 4.0).toList();
    }
    emit(s.copyWith(filteredProducts: filtered, selectedRatingFilter: label));
  }

  // ── Favourite toggle ─────────────────────────────────────────────────────

  void toggleFavourite(String productId) {
    final s = state;
    if (s is! ProductListingLoaded) return;
    final updated = s.filteredProducts.map((p) {
      return p.id == productId ? p.copyWith(isFavourite: !p.isFavourite) : p;
    }).toList();
    emit(s.copyWith(filteredProducts: updated));
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  List<ListingProductModel> _applyPriceFilter(
    List<ListingProductModel> list,
    String? label,
  ) {
    if (label == null) return list;
    switch (label) {
      case 'Under ₹20k':
        return list.where((p) => p.price < 20000).toList();
      case '₹20k–₹50k':
        return list.where((p) => p.price >= 20000 && p.price <= 50000).toList();
      case 'Above ₹50k':
        return list.where((p) => p.price > 50000).toList();
    }
    return list;
  }

  List<ListingProductModel> _applyRatingFilter(
    List<ListingProductModel> list,
    String? label,
  ) {
    if (label == null) return list;
    if (label == '4★ & up') {
      return list.where((p) => (p.rating ?? 0) >= 4.0).toList();
    }
    return list;
  }
}
