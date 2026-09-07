import 'dart:async';

import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_entity.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:bingo_pay/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bingo_pay/features/wishlist/data/models/wishlist_model.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockAddCartItemUseCase extends Mock implements AddCartItemUseCase {}

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockUpdateCartItemQuantityUseCase extends Mock
    implements UpdateCartItemQuantityUseCase {}

class MockRemoveCartItemUseCase extends Mock implements RemoveCartItemUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

const _item = WishlistItem(
  id: 'prod-1',
  variantUuid: 'variant-1',
  brand: 'Bingo Jewels',
  name: 'Gold Necklace',
  price: '\$4,500',
);

void main() {
  test(
    'two rapid "Move to Bag" taps on the same item (no await between them) '
    "are guarded by the local _pendingIds set — exactly one addItem() and "
    'one wishlist remove() occur, not two',
    () async {
      final addItemUseCase = MockAddCartItemUseCase();
      final cartCubit = CartCubit(
        MockGetCartUseCase(),
        addItemUseCase,
        MockUpdateCartItemQuantityUseCase(),
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cartCubit.close);

      SharedPreferences.setMockInitialValues({});
      final wishlistCubit = WishlistCubit(await SharedPreferences.getInstance());
      addTearDown(wishlistCubit.close);
      await wishlistCubit.loadForUser('user-1');
      await wishlistCubit.toggle(_item, wasWishlisted: false);

      var addCallCount = 0;
      final gate = Completer<Either<Failure, CartEntity>>();
      when(() => addItemUseCase(variantUuid: 'variant-1', quantity: 1))
          .thenAnswer((_) {
        addCallCount++;
        return gate.future;
      });

      // Mirrors wishlist_screen.dart's _WishlistScreenState._pendingIds
      // guard exactly (lines 131-132, 138, 210): a synchronous
      // check-and-set BEFORE any await, so a second tap fired before the
      // first even reaches its first await point is blocked immediately —
      // unlike the pre-fix Add to Cart bug, this doesn't depend on a
      // widget rebuild to take effect.
      final pendingIds = <String>{};
      var removeCallCount = 0;

      Future<void> moveToBag(WishlistItem item) async {
        if (pendingIds.contains(item.id)) return;
        pendingIds.add(item.id);
        try {
          final result = await cartCubit.addItem(
            variantUuid: item.variantUuid!,
            quantity: 1,
          );
          if (!result.success) return;
          await wishlistCubit.remove(item.id);
          removeCallCount++;
        } finally {
          pendingIds.remove(item.id);
        }
      }

      // Two rapid taps, synchronously back-to-back.
      final tap1 = moveToBag(_item);
      final tap2 = moveToBag(_item);

      gate.complete(
        Right(
          CartEntity(
            totalItems: 1,
            totalAmount: 4500,
            items: [
              CartItemEntity(
                id: 1,
                quantity: 1,
                unitPrice: 4500,
                totalPrice: 4500,
                product: const CartProductEntity(
                  uuid: 'prod-1',
                  title: 'Gold Necklace',
                  slug: 'gold-necklace',
                ),
                variant: const CartVariantEntity(
                  uuid: 'variant-1',
                  sku: 'sku-1',
                  stock: 5,
                ),
                vendor: const CartVendorEntity(
                  uuid: 'v-1',
                  shopName: 'Bingo Jewels',
                ),
              ),
            ],
          ),
        ),
      );
      await Future.wait([tap1, tap2]);

      expect(addCallCount, 1,
          reason: 'exactly one addItem() call must fire — the second tap '
              'must be blocked synchronously by _pendingIds before it ever '
              'reaches cartCubit.addItem()');
      expect(removeCallCount, 1,
          reason: 'exactly one wishlist removal must occur, matching the '
              'single successful add');
      expect(wishlistCubit.isWishlisted('prod-1'), isFalse);
      expect(
        cartCubit.state.items.where((i) => i.variant.uuid == 'variant-1'),
        hasLength(1),
        reason: 'the cart must contain exactly one line item, not a '
            'duplicate from a second add() call',
      );
    },
  );
}
