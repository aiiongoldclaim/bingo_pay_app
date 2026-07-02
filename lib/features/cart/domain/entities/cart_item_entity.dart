import 'package:equatable/equatable.dart';

class CartProductEntity extends Equatable {
  final String uuid;
  final String title;
  final String slug;
  final String? thumbnail;

  const CartProductEntity({
    required this.uuid,
    required this.title,
    required this.slug,
    this.thumbnail,
  });

  @override
  List<Object?> get props => [uuid, title, slug, thumbnail];
}

class CartVariantAttributeEntity extends Equatable {
  final String attribute;
  final String value;

  const CartVariantAttributeEntity({
    required this.attribute,
    required this.value,
  });

  @override
  List<Object?> get props => [attribute, value];
}

class CartVariantEntity extends Equatable {
  final String uuid;
  final String sku;
  final int stock;
  final List<CartVariantAttributeEntity> attributes;

  const CartVariantEntity({
    required this.uuid,
    required this.sku,
    required this.stock,
    this.attributes = const [],
  });

  @override
  List<Object?> get props => [uuid, sku, stock, attributes];
}

class CartVendorEntity extends Equatable {
  final String uuid;
  final String shopName;

  const CartVendorEntity({required this.uuid, required this.shopName});

  @override
  List<Object?> get props => [uuid, shopName];
}

class CartItemEntity extends Equatable {
  final int id;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final CartProductEntity product;
  final CartVariantEntity variant;
  final CartVendorEntity vendor;

  const CartItemEntity({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.product,
    required this.variant,
    required this.vendor,
  });

  @override
  List<Object?> get props => [
    id,
    quantity,
    unitPrice,
    totalPrice,
    product,
    variant,
    vendor,
  ];
}
