import 'package:equatable/equatable.dart';
import '../../data/models/product_details_model.dart';

abstract class ProductDetailState extends Equatable {
  const ProductDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial / while loading
class ProductDetailLoading extends ProductDetailState {
  const ProductDetailLoading();
}

/// Loaded successfully — carries all display data + interaction state
class ProductDetailLoaded extends ProductDetailState {
  final ProductDetailModel product;
  final bool isFavourite;
  final int selectedColorIndex;
  final int quantity;

  const ProductDetailLoaded({
    required this.product,
    this.isFavourite = false,
    this.selectedColorIndex = 0,
    this.quantity = 1,
  });

  ProductDetailLoaded copyWith({
    ProductDetailModel? product,
    bool? isFavourite,
    int? selectedColorIndex,
    int? quantity,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      isFavourite: isFavourite ?? this.isFavourite,
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [
    product,
    isFavourite,
    selectedColorIndex,
    quantity,
  ];
}

/// Error loading product
class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
