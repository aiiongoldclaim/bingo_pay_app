import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_model.dart';

class CartService {
  static const _key = 'bingo_cart_items';

  Future<List<CartItemModel>> getItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<CartItemModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<List<CartItemModel>> addItem(CartItemModel item) async {
    final items = await getItems();
    final idx = items.indexWhere((e) => e.productUuid == item.productUuid);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(item);
    }
    await _save(items);
    return items;
  }

  Future<List<CartItemModel>> increaseQuantity(String productUuid) async {
    final items = await getItems();
    final idx = items.indexWhere((e) => e.productUuid == productUuid);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
      await _save(items);
    }
    return items;
  }

  Future<List<CartItemModel>> decreaseQuantity(String productUuid) async {
    final items = await getItems();
    final idx = items.indexWhere((e) => e.productUuid == productUuid);
    if (idx >= 0) {
      if (items[idx].quantity <= 1) {
        items.removeAt(idx);
      } else {
        items[idx] = items[idx].copyWith(quantity: items[idx].quantity - 1);
      }
      await _save(items);
    }
    return items;
  }

  Future<List<CartItemModel>> removeItem(String productUuid) async {
    final items = await getItems();
    items.removeWhere((e) => e.productUuid == productUuid);
    await _save(items);
    return items;
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
