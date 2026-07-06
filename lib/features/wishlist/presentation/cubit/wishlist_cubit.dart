import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/wishlist_model.dart';
import 'wishlist_state.dart';

// There's no backend wishlist API, so saved products are persisted locally
// (by product uuid) and restored on app start.
@injectable
class WishlistCubit extends Cubit<WishlistState> {
  final SharedPreferences _prefs;
  static const _storageKey = 'wishlist_items_v1';

  WishlistCubit(this._prefs) : super(const WishlistState()) {
    _restore();
  }

  bool isWishlisted(String? id) =>
      id != null && state.items.any((e) => e.id == id);

  Future<void> toggle(WishlistItem item) async {
    final items = List<WishlistItem>.from(state.items);
    final existingIndex = items.indexWhere((e) => e.id == item.id);
    if (existingIndex >= 0) {
      items.removeAt(existingIndex);
    } else {
      items.insert(0, item);
    }
    emit(state.copyWith(items: items));
    await _persist(items);
  }

  Future<void> remove(String id) async {
    final items = List<WishlistItem>.from(state.items)
      ..removeWhere((e) => e.id == id);
    emit(state.copyWith(items: items));
    await _persist(items);
  }

  void _restore() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final decoded = jsonDecode(raw) as List;
      final items = decoded
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .toList();
      emit(state.copyWith(items: items));
    } catch (_) {
      // Corrupt/incompatible cache — start fresh rather than crash.
    }
  }

  Future<void> _persist(List<WishlistItem> items) =>
      _prefs.setString(_storageKey, jsonEncode(items.map(_toJson).toList()));

  Map<String, dynamic> _toJson(WishlistItem item) => {
    'id': item.id,
    'brand': item.brand,
    'name': item.name,
    'price': item.price,
    'originalPrice': item.originalPrice,
    'discountPercent': item.discountPercent,
    'imageUrl': item.imageUrl,
    'rating': item.rating,
    'reviewCount': item.reviewCount,
    'inStock': item.inStock,
    'badge': item.badge,
  };

  WishlistItem _fromJson(Map<String, dynamic> json) => WishlistItem(
    id: json['id'] as String,
    brand: json['brand'] as String? ?? '',
    name: json['name'] as String? ?? '',
    price: json['price'] as String? ?? '',
    originalPrice: json['originalPrice'] as String?,
    discountPercent: json['discountPercent'] as int?,
    imageUrl: json['imageUrl'] as String?,
    rating: json['rating'] as String? ?? '0.0',
    reviewCount: json['reviewCount'] as int? ?? 0,
    inStock: json['inStock'] as bool? ?? true,
    badge: json['badge'] as String?,
  );
}
