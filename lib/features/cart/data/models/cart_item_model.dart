class CartProductModel {
  final String uuid;
  final String title;
  final String slug;
  final String? thumbnail;

  const CartProductModel({
    required this.uuid,
    required this.title,
    required this.slug,
    this.thumbnail,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) =>
      CartProductModel(
        uuid: json['uuid'] as String,
        title: json['title'] as String,
        slug: json['slug'] as String,
        thumbnail: json['thumbnail'] as String?,
      );
}

class CartVariantAttributeModel {
  final String attribute;
  final String value;

  const CartVariantAttributeModel({
    required this.attribute,
    required this.value,
  });

  factory CartVariantAttributeModel.fromJson(Map<String, dynamic> json) =>
      CartVariantAttributeModel(
        attribute: json['attribute'] as String,
        value: json['value'] as String,
      );
}

class CartVariantModel {
  final String uuid;
  final String sku;
  final int stock;
  final List<CartVariantAttributeModel> attributes;

  const CartVariantModel({
    required this.uuid,
    required this.sku,
    required this.stock,
    this.attributes = const [],
  });

  factory CartVariantModel.fromJson(Map<String, dynamic> json) {
    final rawAttributes = json['attributes'] as List<dynamic>? ?? const [];
    return CartVariantModel(
      uuid: json['uuid'] as String,
      sku: json['sku'] as String,
      stock: _asInt(json['stock']) ?? 0,
      attributes: rawAttributes
          .map(
            (e) => CartVariantAttributeModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}

class CartVendorModel {
  final String uuid;
  final String shopName;

  const CartVendorModel({required this.uuid, required this.shopName});

  factory CartVendorModel.fromJson(Map<String, dynamic> json) =>
      CartVendorModel(
        uuid: json['uuid'] as String,
        shopName: json['shopName'] as String,
      );
}

class CartItemModel {
  final int id;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final CartProductModel product;
  final CartVariantModel variant;
  final CartVendorModel vendor;

  const CartItemModel({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.product,
    required this.variant,
    required this.vendor,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: _asInt(json['id'])!,
    quantity: (json['quantity'] as num).toInt(),
    unitPrice: (json['unitPrice'] as num).toDouble(),
    totalPrice: (json['totalPrice'] as num).toDouble(),
    product: CartProductModel.fromJson(json['product'] as Map<String, dynamic>),
    variant: CartVariantModel.fromJson(json['variant'] as Map<String, dynamic>),
    vendor: CartVendorModel.fromJson(json['vendor'] as Map<String, dynamic>),
  );
}

// The API sometimes returns numeric ids as JSON numbers and sometimes as
// strings (e.g. "id": "1"), so ids are parsed defensively either way.
int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
