// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../home/data/models/product_model.dart';
// import 'wishlist_state.dart';
//
// class WishlistCubit extends Cubit<WishlistState> {
//   WishlistCubit() : super(const WishlistState());
//
//   bool isFavourite(String id) {
//     return state.products.any((e) => e.id == id);
//   }
//
//   void toggle(ProductModel product) {
//     final items = List<ProductModel>.from(state.products);
//
//     if (isFavourite(product.id)) {
//       items.removeWhere((e) => e.id == product.id);
//     } else {
//       items.add(product);
//     }
//
//     emit(state.copyWith(products: items));
//   }
// }
