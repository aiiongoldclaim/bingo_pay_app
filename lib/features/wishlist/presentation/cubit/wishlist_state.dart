import 'package:equatable/equatable.dart';

import '../../../home/data/models/product_model.dart';

class WishlistState extends Equatable {
  final List<ProductModel> products;

  const WishlistState({this.products = const []});

  WishlistState copyWith({List<ProductModel>? products}) {
    return WishlistState(products: products ?? this.products);
  }

  @override
  List<Object?> get props => [products];
}
