// import 'dart:convert';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../data/models/wishlist_model.dart';
// import 'wishlist_state.dart';
//
//
// @injectable
// class WishlistCubit extends Cubit<WishlistState> {
//   final SharedPreferences _prefs;
//   static const _storageKeyPrefix = 'wishlist_items_v2_';
//   String? _userId;
//   int _sessionVersion = 0;
//
//   WishlistCubit(this._prefs) : super(const WishlistState());
//
//   Future<void> loadForUser(String userId) async {
//     final sessionVersion = ++_sessionVersion;
//     _userId = userId;
//     emit(const WishlistState());
//
//     final raw = _prefs.getString(_storageKeyFor(userId));
//     if (raw == null) return;
//
//     try {
//       final decoded = jsonDecode(raw) as List;
//       final items = decoded
//           .map((e) => _fromJson(e as Map<String, dynamic>))
//           .toList();
//       if (sessionVersion == _sessionVersion && _userId == userId) {
//         emit(state.copyWith(items: items));
//       }
//     } catch (_) {
//
//     }
//   }
//
//
//   void clearForLogout() {
//     ++_sessionVersion;
//     _userId = null;
//     emit(const WishlistState());
//   }
//
//   bool isWishlisted(String? id) =>
//       id != null && state.items.any((e) => e.id == id);
//
//   Future<void> toggle(WishlistItem item) async {
//     if (_userId == null) return;
//     final items = List<WishlistItem>.from(state.items);
//     final existingIndex = items.indexWhere((e) => e.id == item.id);
//     if (existingIndex >= 0) {
//       items.removeAt(existingIndex);
//     } else {
//       items.insert(0, item);
//     }
//     emit(state.copyWith(items: items));
//     await _persist(items);
//   }
//
//   Future<void> remove(String id) async {
//     if (_userId == null) return;
//     final items = List<WishlistItem>.from(state.items)
//       ..removeWhere((e) => e.id == id);
//     emit(state.copyWith(items: items));
//     await _persist(items);
//   }
//
//   String _storageKeyFor(String userId) => '$_storageKeyPrefix$userId';
//
//   Future<void> _persist(List<WishlistItem> items) => _prefs.setString(
//     _storageKeyFor(_userId!),
//     jsonEncode(items.map(_toJson).toList()),
//   );
//
//   Map<String, dynamic> _toJson(WishlistItem item) => {
//     'id': item.id,
//     'variantUuid': item.variantUuid,
//     'brand': item.brand,
//     'name': item.name,
//     'price': item.price,
//     'originalPrice': item.originalPrice,
//     'discountPercent': item.discountPercent,
//     'imageUrl': item.imageUrl,
//     'rating': item.rating,
//     'reviewCount': item.reviewCount,
//     'inStock': item.inStock,
//     'badge': item.badge,
//   };
//
//   WishlistItem _fromJson(Map<String, dynamic> json) => WishlistItem(
//     id: json['id'] as String,
//     variantUuid: json['variantUuid'] as String?,
//     brand: json['brand'] as String? ?? '',
//     name: json['name'] as String? ?? '',
//     price: json['price'] as String? ?? '',
//     originalPrice: json['originalPrice'] as String?,
//     discountPercent: json['discountPercent'] as int?,
//     imageUrl: json['imageUrl'] as String?,
//     rating: json['rating'] as String? ?? '0.0',
//     reviewCount: json['reviewCount'] as int? ?? 0,
//     inStock: json['inStock'] as bool? ?? true,
//     badge: json['badge'] as String?,
//   );
// }
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/wishlist_model.dart';
import 'wishlist_state.dart';

@injectable
class WishlistCubit extends Cubit<WishlistState> {
  final SharedPreferences _prefs;
  static const _storageKeyPrefix = 'wishlist_items_v2_';
  String? _userId;
  int _sessionVersion = 0;

  Future<void> _writeQueue = Future.value();

  List<WishlistItem>? _pendingWrite;

  WishlistCubit(this._prefs) : super(const WishlistState());

  Future<void> loadForUser(String userId) async {
    final sessionVersion = ++_sessionVersion;
    _userId = userId;
    _pendingWrite = null;
    emit(const WishlistState());

    final raw = _prefs.getString(_storageKeyFor(userId));
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw) as List;
      final items = decoded
          .map((e) => _fromJson(e as Map<String, dynamic>))
          .toList();
      if (sessionVersion == _sessionVersion && _userId == userId) {
        emit(state.copyWith(items: items));
      }
    } catch (_) {
    }
  }

  void clearForLogout() {
    ++_sessionVersion;
    _pendingWrite = null;
    _userId = null;
    emit(const WishlistState());
  }

  bool isWishlisted(String? id) =>
      id != null && state.items.any((e) => e.id == id);

  Future<void> toggle(WishlistItem item) async {
    if (_userId == null) return;
    final items = List<WishlistItem>.from(state.items);
    final existingIndex = items.indexWhere((e) => e.id == item.id);
    if (existingIndex >= 0) {
      items.removeAt(existingIndex);
    } else {
      items.insert(0, item);
    }

    // Emit before persisting so a rapid second tap reads the updated
    // state.items (set synchronously below) rather than the pre-toggle
    // snapshot — otherwise two fast toggles can both compute the same
    // flip and one of them is lost.
    emit(state.copyWith(items: items));
    await _persist(items);
  }

  Future<void> remove(String id) async {
    if (_userId == null) return;
    final items = List<WishlistItem>.from(state.items)
      ..removeWhere((e) => e.id == id);

    await _persist(items);

    if (_userId == null) return;
    emit(state.copyWith(items: items));
  }

  String _storageKeyFor(String userId) => '$_storageKeyPrefix$userId';

  Future<void> _persist(List<WishlistItem> items) {
    final userId = _userId;
    if (userId == null) return Future.value();

    _pendingWrite = List<WishlistItem>.unmodifiable(items);
    final sessionVersion = _sessionVersion;

    final write = _writeQueue.then((_) async {
      final snapshot = _pendingWrite;
      if (snapshot == null) return;
      // Logout or a user switch happened while this write was queued.
      if (sessionVersion != _sessionVersion || _userId != userId) return;
      _pendingWrite = null;

      await _prefs.setString(
        _storageKeyFor(userId),
        jsonEncode(snapshot.map(_toJson).toList()),
      );
    });


    _writeQueue = write.catchError((_) {});
    return write;
  }

  Map<String, dynamic> _toJson(WishlistItem item) => {
    'id': item.id,
    'variantUuid': item.variantUuid,
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
    variantUuid: json['variantUuid'] as String?,
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