import 'package:equatable/equatable.dart';
import '../../../address/domain/entities/address_entity.dart';
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
  final int selectedColorIndex;
  final int selectedVariantIndex;
  final int quantity;
  final AddressEntity? deliveryAddress;

  const ProductDetailLoaded({
    required this.product,
    this.selectedColorIndex = 0,
    this.selectedVariantIndex = 0,
    this.quantity = 1,
    this.deliveryAddress,
  });

  ProductDetailLoaded copyWith({
    ProductDetailModel? product,
    int? selectedColorIndex,
    int? selectedVariantIndex,
    int? quantity,
  }) {
    return ProductDetailLoaded(
      product: product ?? this.product,
      selectedColorIndex: selectedColorIndex ?? this.selectedColorIndex,
      selectedVariantIndex: selectedVariantIndex ?? this.selectedVariantIndex,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [
    product,
    selectedColorIndex,
    selectedVariantIndex,
    quantity,
    deliveryAddress,
  ];
}

/// Error loading product
class ProductDetailError extends ProductDetailState {
  final String message;

  const ProductDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
