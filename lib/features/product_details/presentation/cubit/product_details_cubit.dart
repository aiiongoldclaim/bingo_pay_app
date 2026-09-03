import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../wishlist/data/repositories/wishlist_repository.dart';
import 'product_details_state.dart';

@injectable
class ProductDetailCubit extends Cubit<ProductDetailState> {
  final WishlistRepository _repository;

  ProductDetailCubit(this._repository) : super(const ProductDetailLoading());

  Future<void> loadProduct(String uuid) async {
    emit(const ProductDetailLoading());
    try {
      final product = await _repository.getProductDetail(uuid);
      emit(ProductDetailLoaded(product: product));
    } catch (e) {
      emit(ProductDetailError(e.toString()));
    }
  }

  void selectVariant(int index) {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    final updatedProduct = current.product.copyWith(selectedVariantIndex: index);
    emit(current.copyWith(
      product: updatedProduct,
      selectedVariantIndex: index,
      quantity: 1,
    ));
  }

  void selectColor(int index) {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    emit(current.copyWith(selectedColorIndex: index));
  }

  void incrementQuantity() {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    if (current.quantity >= current.product.availableStock) return;
    emit(current.copyWith(quantity: current.quantity + 1));
  }

  void decrementQuantity() {
    final current = state;
    if (current is! ProductDetailLoaded) return;
    if (current.quantity <= 1) return;
    emit(current.copyWith(quantity: current.quantity - 1));
  }

  void onAddToCart() {}

  void onBuyNow() {}

  void onSeeAllReviews() {}
}
