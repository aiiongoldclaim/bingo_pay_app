import 'package:equatable/equatable.dart';

import '../../data/models/wishlist_model.dart';

class WishlistState extends Equatable {
  final List<WishlistItem> items;

  const WishlistState({this.items = const []});

  WishlistState copyWith({List<WishlistItem>? items}) {
    return WishlistState(items: items ?? this.items);
  }

  @override
  List<Object?> get props => [items];
}
