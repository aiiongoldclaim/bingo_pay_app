import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/error/error_messages.dart';
import '../../data/models/vendor_product_model.dart';
import 'vendor_products_state.dart';

class VendorProductsCubit extends Cubit<VendorProductsState> {
  VendorProductsCubit() : super(VendorProductsInitial());

  Future<void> loadProducts() async {
    emit(VendorProductsLoading());
    try {
      final client = GetIt.I<ApiClient>();
      final response = await client.dio.get(
        '${AppConfig.apiBaseUrl}/api/v1/products/my-products',
      );
      final products = VendorProductModel.listFromResponse(
        response.data as Map<String, dynamic>,
      );
      emit(VendorProductsLoaded(
        all: products,
        filtered: products,
        activeFilter: 'All',
      ));
    } catch (e) {
      emit(VendorProductsError(friendlyErrorMessage(e)));
    }
  }

  void filterProducts(String filter) {
    final current = state;
    if (current is! VendorProductsLoaded) return;

    final filtered = switch (filter) {
      'Published' => current.all.where((p) => p.isPublished).toList(),
      'Unpublished' => current.all.where((p) => !p.isPublished).toList(),
      _ => current.all,
    };

    emit(VendorProductsLoaded(
      all: current.all,
      filtered: filtered,
      activeFilter: filter,
    ));
  }
}
