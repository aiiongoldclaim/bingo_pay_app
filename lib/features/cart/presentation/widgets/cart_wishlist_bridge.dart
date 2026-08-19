import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../wishlist/data/models/wishlist_model.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartWishlistBridge {
  static void moveOne(BuildContext context, CartItemEntity item) {
    final wishlist = context.read<WishlistCubit>();

    if (wishlist.isWishlisted(item.product.uuid)) return;

    wishlist.toggle(
      WishlistItem(
        id: item.product.uuid,
        variantUuid: item.variant.uuid,
        brand: item.vendor.shopName,
        name: item.product.title,
        price: '\$${item.unitPrice.toStringAsFixed(2)}',
        imageUrl: item.product.thumbnail,
      ),
    );
  }
}
