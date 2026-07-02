import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../data/models/product_details_model.dart';
import 'product_details_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit() : super(const ProductDetailLoading());

  Future<void> loadProduct(String uuid) async {
    emit(const ProductDetailLoading());
    try {
      final client = GetIt.I<ApiClient>();
      final url = '${AppConfig.categoriesApiBaseUrl}/api/v1/products/$uuid';
      final response = await client.dio.get(url);
      final product = ProductDetailModel.fromJson(
        response.data as Map<String, dynamic>,
      );
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

  void incrementQuantity() {
    final current = state;
    if (current is! ProductDetailLoaded) return;
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
