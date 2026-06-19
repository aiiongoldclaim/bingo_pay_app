import 'package:flutter/cupertino.dart';

class CartItemModel {
  final String brand;
  final String name;
  final String price;
  final IconData icon;
  final int quantity;

  const CartItemModel({
    required this.brand,
    required this.name,
    required this.price,
    required this.icon,
    this.quantity = 1,
  });
}
