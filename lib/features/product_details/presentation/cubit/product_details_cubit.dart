import 'package:bingo_pay/features/product_details/presentation/cubit/product_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/product_details_model.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailLoading());

  Future<void> loadProduct(ProductDetailModel product) async {
    try {
      emit(const ProductDetailLoading());
      // Simulate network delay — remove when using real repository
      await Future.delayed(const Duration(milliseconds: 300));
      emit(ProductDetailLoaded(product: product));
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }

  void toggleFavourite() {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    emit(current.copyWith(isFavourite: !current.isFavourite));
  }

  void selectColor(int index) {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    emit(current.copyWith(selectedColorIndex: index));
  }

  void onAddToCart() {
    // TODO: dispatch to cart repository / show snackbar
  }

  void onBuyNow() {
    // TODO: navigate to checkout
    
  }

  void onSeeAllReviews() {
    // TODO: navigate to reviews screen
  }
}
