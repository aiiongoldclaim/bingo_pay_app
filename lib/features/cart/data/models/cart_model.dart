import 'package:flutter/material.dart';

import '../../../product_details/data/models/product_details_model.dart';

class CartItemModel {
  final String productUuid;
  final String brand;
  final String name;
  final String price;       // display string e.g. "\$18,990"
  final double priceValue;  // numeric for totals
  final String? imageUrl;
  final String? vendorEmail;
  final int iconCodePoint;
  final String iconFontFamily;
  final int quantity;

  const CartItemModel({
    required this.productUuid,
    required this.brand,
    required this.name,
    required this.price,
    required this.priceValue,
    this.imageUrl,
    this.vendorEmail,
    this.iconCodePoint = 0xe55b, // shopping_bag_outlined
    this.iconFontFamily = 'MaterialIcons',
    this.quantity = 1,
  });

  IconData get icon =>
      const IconData(0xe55b, fontFamily: 'MaterialIcons');

  CartItemModel copyWith({int? quantity}) => CartItemModel(
        productUuid: productUuid,
        brand: brand,
        name: name,
        price: price,
        priceValue: priceValue,
        imageUrl: imageUrl,
        vendorEmail: vendorEmail,
        iconCodePoint: iconCodePoint,
        iconFontFamily: iconFontFamily,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toJson() => {
        'productUuid': productUuid,
        'brand': brand,
        'name': name,
        'price': price,
        'priceValue': priceValue,
        'imageUrl': imageUrl,
        'vendorEmail': vendorEmail,
        'iconCodePoint': iconCodePoint,
        'iconFontFamily': iconFontFamily,
        'quantity': quantity,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        productUuid: json['productUuid'] as String,
        brand: json['brand'] as String,
        name: json['name'] as String,
        price: json['price'] as String,
        priceValue: (json['priceValue'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String?,
        vendorEmail: json['vendorEmail'] as String?,
        iconCodePoint: json['iconCodePoint'] as int? ?? 0xe55b,
        iconFontFamily:
            json['iconFontFamily'] as String? ?? 'MaterialIcons',
        quantity: json['quantity'] as int? ?? 1,
      );

  factory CartItemModel.fromProduct(ProductDetailModel product) {
    final raw = product.price.replaceAll(RegExp(r'[$,]'), '').trim();
    final value = double.tryParse(raw) ?? 0.0;
    return CartItemModel(
      productUuid: product.uuid ?? product.id,
      brand: product.brand,
      name: product.productName,
      price: product.price.isNotEmpty ? product.price : '\$0',
      priceValue: value,
      imageUrl: product.images.isNotEmpty ? product.images.first : null,
      vendorEmail: product.vendorEmail,
    );
  }
}
