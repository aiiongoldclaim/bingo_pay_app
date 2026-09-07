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
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAddCartItemUseCase extends Mock implements AddCartItemUseCase {}

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockUpdateCartItemQuantityUseCase extends Mock
    implements UpdateCartItemQuantityUseCase {}

class MockRemoveCartItemUseCase extends Mock implements RemoveCartItemUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

const _variantUuid = 'variant-abc';

CartItemEntity _cartItem() => const CartItemEntity(
      id: 1,
      quantity: 1,
      unitPrice: 100,
      totalPrice: 100,
      product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
      variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
      vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
    );

void main() {
  late MockAddCartItemUseCase addItemUseCase;
  late CartCubit cartCubit;

  setUp(() {
    addItemUseCase = MockAddCartItemUseCase();
    cartCubit = CartCubit(
      MockGetCartUseCase(),
      addItemUseCase,
      MockUpdateCartItemQuantityUseCase(),
      MockRemoveCartItemUseCase(),
      MockClearCartUseCase(),
    );
  });

  tearDown(() => cartCubit.close());

  test(
    'adding an in-stock variant succeeds: CartActionResult.success is '
    'returned and the cart state now contains that variant',
    () async {
      final updatedCart = CartEntity(
        totalItems: 1,
        totalAmount: 100,
        items: [_cartItem()],
      );
      when(() => addItemUseCase(variantUuid: _variantUuid, quantity: 1))
          .thenAnswer((_) async => Right(updatedCart));

      // Before adding: this mirrors product_details_screen.dart:148-150's
      // isInCart check — the variant is not yet in the cart, so the
      // secondary button would read "Add to Cart".
      var isInCart =
          cartCubit.state.items.any((item) => item.variant.uuid == _variantUuid);
      expect(isInCart, isFalse);

      final result = await cartCubit.addItem(
        variantUuid: _variantUuid,
        quantity: 1,
      );

      expect(result.success, isTrue,
          reason: 'a successful add must report success so the screen '
              'shows the "GO TO CART" success snackbar, not an error one');
      expect(result.errorMessage, isNull);
      expect(cartCubit.state.isAddingItem, isFalse);

      // After adding: on the next render, the same isInCart check the
      // screen uses must now flip to true, since context.watch<CartCubit>()
      // rebuilds the BottomActionBar with the fresh cart state.
      isInCart =
          cartCubit.state.items.any((item) => item.variant.uuid == _variantUuid);
      expect(isInCart, isTrue,
          reason: 'the secondary button must flip from "Add to Cart" to '
              '"Go to Cart" once the item is actually in the cart');
    },
  );

  test(
    'a server error on Add to Cart surfaces the failure message and '
    'clears the loading flag',
    () async {
      when(() => addItemUseCase(variantUuid: _variantUuid, quantity: 1))
          .thenAnswer(
        (_) async => const Left(ServerFailure(message: 'Server error, please try again')),
      );

      // product_details_screen.dart's secondaryLoading is bound to
      // cartState.isAddingItem, driving the button's spinner.
      final addFuture = cartCubit.addItem(variantUuid: _variantUuid, quantity: 1);
      expect(cartCubit.state.isAddingItem, isTrue,
          reason: 'loading must be true while the request is in flight');

      final result = await addFuture;

      expect(result.success, isFalse);
      // product_details_screen.dart:95-99 reads result.errorMessage (NOT
      // cartCubit.state.error) to build the error snackbar — deliberately,
      // per the comment on CartActionResult in cart_state.dart: state.error
      // reflects whichever cart operation last settled app-wide, so a
      // concurrent add/remove elsewhere could overwrite it before this
      // call's own caller gets a chance to read it. Reading the per-call
      // result instead avoids that race.
      expect(result.errorMessage, 'Server error, please try again');

      expect(cartCubit.state.isAddingItem, isFalse,
          reason: 'loading must clear once the failure settles, so the '
              'button spinner stops');
    },
  );

  test(
    'loading a cart with items successfully populates items, quantities, '
    'and totals correctly',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final cubitWithItems = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        MockUpdateCartItemQuantityUseCase(),
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubitWithItems.close);

      const item1 = CartItemEntity(
        id: 1,
        quantity: 2,
        unitPrice: 1500,
        totalPrice: 3000,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: 'variant-1', sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      const item2 = CartItemEntity(
        id: 2,
        quantity: 1,
        unitPrice: 4500,
        totalPrice: 4500,
        product: CartProductEntity(uuid: 'p-2', title: 'Silver Chain', slug: 'silver-chain'),
        variant: CartVariantEntity(uuid: 'variant-2', sku: 'sku-2', stock: 2),
        vendor: CartVendorEntity(uuid: 'v-2', shopName: 'Bingo Jewels'),
      );
      final cart = const CartEntity(
        cartId: 99,
        totalItems: 3,
        totalAmount: 7500,
        items: [item1, item2],
      );
      when(() => getCartUseCase()).thenAnswer((_) async => Right(cart));

      await cubitWithItems.loadCart();

      final state = cubitWithItems.state;
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);

      // Mirrors cart_screen.dart's rendering data exactly: items list,
      // each item's own quantity, and the totals shown in
      // PriceDetailsCard/_CartTitleBlock when nothing is deselected.
      expect(state.items.length, 2, reason: 'both cart items must render');
      expect(state.items[0].quantity, 2);
      expect(state.items[1].quantity, 1);
      expect(state.totalItems, 3,
          reason: '"My Cart (3)" / "3 items in your bag" header text');

      final selectedTotal = state.items.fold<double>(
        0,
        (sum, e) => sum + e.totalPrice,
      );
      final selectedCount = state.items.fold<int>(
        0,
        (sum, e) => sum + e.quantity,
      );
      expect(selectedTotal, 7500, reason: 'PriceDetailsCard subtotal');
      expect(selectedCount, 3, reason: 'PriceDetailsCard item count');
      expect(state.totalAmount, 7500);
    },
  );

  test(
    'a server error while loading the cart surfaces via state.error and '
    'clears isLoading',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final cubitWithError = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        MockUpdateCartItemQuantityUseCase(),
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubitWithError.close);

      when(() => getCartUseCase()).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'Unable to load your cart')),
      );

      final loadFuture = cubitWithError.loadCart();
      // cart_screen.dart shows a spinner while state.isLoading is true.
      expect(cubitWithError.state.isLoading, isTrue);

      await loadFuture;

      final state = cubitWithError.state;
      // cart_screen.dart's BlocListener fires AppSnackbar.showError(
      // context, state.error!) whenever state.error changes — this is
      // exactly what it reads.
      expect(state.error, 'Unable to load your cart');
      expect(state.isLoading, isFalse,
          reason: 'loading must clear so the spinner stops even on failure');
    },
  );

  test(
    'adding an item (from PDP or a listing screen — both call the same '
    'CartCubit.addItem()) toggles isAddingItem false -> true -> false '
    'around the call, and the cart state reflects the new item',
    () async {
      final gate = Completer<Either<Failure, CartEntity>>();
      when(() => addItemUseCase(variantUuid: _variantUuid, quantity: 1))
          .thenAnswer((_) => gate.future);

      expect(cartCubit.state.isAddingItem, isFalse,
          reason: 'not adding anything before the call starts');

      final addFuture = cartCubit.addItem(variantUuid: _variantUuid, quantity: 1);

      expect(cartCubit.state.isAddingItem, isTrue,
          reason: 'flips true synchronously once addItem() starts, driving '
              "the button's loading spinner on both PDP and listing "
              'screens');

      gate.complete(
        Right(CartEntity(totalItems: 1, totalAmount: 100, items: [_cartItem()])),
      );
      final result = await addFuture;

      expect(cartCubit.state.isAddingItem, isFalse,
          reason: 'flips back false once the call settles');
      expect(result.success, isTrue);
      expect(
        cartCubit.state.items.any((i) => i.variant.uuid == _variantUuid),
        isTrue,
        reason: 'the cart state must reflect the newly added item',
      );
    },
  );

  test(
    'a rejected add (e.g. out of stock) surfaces the error without '
    'corrupting the cart items already loaded',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final cubitWithCart = CartCubit(
        getCartUseCase,
        addItemUseCase,
        MockUpdateCartItemQuantityUseCase(),
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubitWithCart.close);

      final existingCart = CartEntity(
        totalItems: 1,
        totalAmount: 100,
        items: [_cartItem()],
      );
      when(() => getCartUseCase()).thenAnswer((_) async => Right(existingCart));
      await cubitWithCart.loadCart();
      expect(cubitWithCart.state.items.length, 1);

      when(() => addItemUseCase(variantUuid: 'variant-out-of-stock', quantity: 1))
          .thenAnswer(
        (_) async => const Left(
          ValidationFailure(
            message: 'This item is out of stock',
            fieldErrors: {},
          ),
        ),
      );

      final result = await cubitWithCart.addItem(
        variantUuid: 'variant-out-of-stock',
        quantity: 1,
      );

      expect(result.success, isFalse);
      expect(result.errorMessage, 'This item is out of stock');

      final state = cubitWithCart.state;
      expect(state.error, 'This item is out of stock');
      expect(state.isAddingItem, isFalse);
      // The existing item loaded before the failed add must be untouched —
      // CartState.copyWith defaults `cart: cart ?? this.cart`, and the
      // failure branch in CartCubit.addItem() never passes a new cart.
      expect(state.items.length, 1,
          reason: 'the pre-existing cart item must not be lost');
      expect(state.items.first.variant.uuid, _variantUuid);
      expect(state.totalItems, 1);
      expect(state.totalAmount, 100);
    },
  );

  test(
    'tapping "+" recalculates totals and marks only that row busy via '
    'pendingItemIds — not a full-screen isLoading spinner',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final updateQtyUseCase = MockUpdateCartItemQuantityUseCase();
      final cubitForQty = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        updateQtyUseCase,
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubitForQty.close);

      const originalItem = CartItemEntity(
        id: 1,
        quantity: 1,
        unitPrice: 100,
        totalPrice: 100,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(
          CartEntity(totalItems: 1, totalAmount: 100, items: [originalItem]),
        ),
      );
      await cubitForQty.loadCart();

      final gate = Completer<Either<Failure, CartEntity>>();
      when(() => updateQtyUseCase(itemId: 1, quantity: 2))
          .thenAnswer((_) => gate.future);

      final increaseFuture = cubitForQty.increaseQuantity(originalItem);

      // While the request is in flight: only row 1 is marked pending, and
      // the full-screen spinner flag (isLoading) is untouched.
      expect(cubitForQty.state.pendingItemIds, {1},
          reason: "only this item's row should show a busy state");
      expect(cubitForQty.state.isLoading, isFalse,
          reason: 'increasing quantity must not trigger the full-screen '
              'spinner used for the initial cart load');

      const updatedItem = CartItemEntity(
        id: 1,
        quantity: 2,
        unitPrice: 100,
        totalPrice: 200,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      gate.complete(
        const Right(
          CartEntity(totalItems: 2, totalAmount: 200, items: [updatedItem]),
        ),
      );
      await increaseFuture;

      final state = cubitForQty.state;
      expect(state.pendingItemIds, isEmpty,
          reason: 'the busy state must clear once the update settles');
      expect(state.items.first.quantity, 2);
      expect(state.totalAmount, 200,
          reason: 'the total must recalculate from the server\'s response');
      expect(state.totalItems, 2);
    },
  );

  test(
    'tapping "-" when quantity > 1 decrements by exactly one, not to zero '
    'or via item removal',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final updateQtyUseCase = MockUpdateCartItemQuantityUseCase();
      final removeItemUseCase = MockRemoveCartItemUseCase();
      final cubitForQty = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        updateQtyUseCase,
        removeItemUseCase,
        MockClearCartUseCase(),
      );
      addTearDown(cubitForQty.close);

      const originalItem = CartItemEntity(
        id: 1,
        quantity: 3,
        unitPrice: 100,
        totalPrice: 300,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(
          CartEntity(totalItems: 3, totalAmount: 300, items: [originalItem]),
        ),
      );
      await cubitForQty.loadCart();

      const decrementedItem = CartItemEntity(
        id: 1,
        quantity: 2,
        unitPrice: 100,
        totalPrice: 200,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      when(() => updateQtyUseCase(itemId: 1, quantity: 2)).thenAnswer(
        (_) async => const Right(
          CartEntity(totalItems: 2, totalAmount: 200, items: [decrementedItem]),
        ),
      );

      await cubitForQty.decreaseQuantity(originalItem);

      // Exactly one call, to quantity 2 (3 - 1) — never removeItem for a
      // qty > 1 item, and never decremented by more than one step.
      verify(() => updateQtyUseCase(itemId: 1, quantity: 2)).called(1);
      verifyNever(() => removeItemUseCase(itemId: any(named: 'itemId')));

      expect(cubitForQty.state.items.first.quantity, 2);
    },
  );

  test(
    'decreasing a quantity-1 item removes it entirely (routes to '
    'removeItem), never sets quantity to 0',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final updateQtyUseCase = MockUpdateCartItemQuantityUseCase();
      final removeItemUseCase = MockRemoveCartItemUseCase();
      final cubitForQty = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        updateQtyUseCase,
        removeItemUseCase,
        MockClearCartUseCase(),
      );
      addTearDown(cubitForQty.close);

      const soloItem = CartItemEntity(
        id: 1,
        quantity: 1,
        unitPrice: 100,
        totalPrice: 100,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(
          CartEntity(totalItems: 1, totalAmount: 100, items: [soloItem]),
        ),
      );
      await cubitForQty.loadCart();

      when(() => removeItemUseCase(itemId: 1))
          .thenAnswer((_) async => const Right('Item removed'));
      // After removal, a fresh cart fetch (used by _refreshCartSilently)
      // comes back empty.
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(CartEntity(totalItems: 0, totalAmount: 0)),
      );

      await cubitForQty.decreaseQuantity(soloItem);

      verify(() => removeItemUseCase(itemId: 1)).called(1);
      verifyNever(
        () => updateQtyUseCase(
          itemId: any(named: 'itemId'),
          quantity: any(named: 'quantity'),
        ),
      );

      expect(cubitForQty.state.items, isEmpty,
          reason: 'the item must be gone entirely, not present with '
              'quantity 0');
    },
  );

  test(
    'two rapid "+" taps before the first tap\'s rebuild lands — both '
    'firing with the same stale item snapshot the widget was built with — '
    'must not send the same duplicate target quantity twice',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final updateQtyUseCase = MockUpdateCartItemQuantityUseCase();
      final cubitForQty = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        updateQtyUseCase,
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubitForQty.close);

      // The widget's CartItemTile is built once with this item (quantity
      // 1). Both rapid taps call cubit.increaseQuantity(item) with this
      // exact same object, because the tree hasn't rebuilt between taps —
      // mirroring cart_items_card.dart's onTap: isPending ? null :
      // onIncrease (onIncrease = cubit.increaseQuantity), where onIncrease
      // closes over the item passed into that build.
      const staleItem = CartItemEntity(
        id: 1,
        quantity: 1,
        unitPrice: 100,
        totalPrice: 100,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(
          CartEntity(totalItems: 1, totalAmount: 100, items: [staleItem]),
        ),
      );
      await cubitForQty.loadCart();

      final sentQuantities = <int>[];
      when(() => updateQtyUseCase(itemId: 1, quantity: any(named: 'quantity')))
          .thenAnswer((invocation) async {
        sentQuantities.add(invocation.namedArguments[#quantity] as int);
        final q = invocation.namedArguments[#quantity] as int;
        return Right(
          CartEntity(
            totalItems: q,
            totalAmount: 100.0 * q,
            items: [
              CartItemEntity(
                id: 1,
                quantity: q,
                unitPrice: 100,
                totalPrice: 100.0 * q,
                product: staleItem.product,
                variant: staleItem.variant,
                vendor: staleItem.vendor,
              ),
            ],
          ),
        );
      });

      // Two rapid taps, both against the same stale `staleItem` snapshot —
      // no await between them, exactly "before the first tap's rebuild".
      final firstTap = cubitForQty.increaseQuantity(staleItem);
      final secondTap = cubitForQty.increaseQuantity(staleItem);
      await Future.wait([firstTap, secondTap]);

      expect(sentQuantities, hasLength(2),
          reason: 'both taps must reach the API, not be silently dropped');
      expect(
        sentQuantities.toSet(),
        {2, 3},
        reason: 'two taps intending 1->2 and 2->3 must send two DIFFERENT '
            'target quantities (2 and 3) — if increaseQuantity() computes '
            'its target from the stale item snapshot the widget was built '
            'with (item.quantity + 1) rather than from live cubit state, '
            'both taps send the same duplicate target (2, 2), silently '
            'losing one of the two taps',
      );
      expect(cubitForQty.state.items.first.quantity, 3,
          reason: 'after two "+" taps starting from quantity 1, the final '
              'quantity must be 3, not 2');
    },
  );

  test(
    'tapping "-" then immediately "+" (before either resolves) leaves the '
    'quantity matching the LAST user action, even if the FIRST tap\'s '
    'network response is the one that lands last',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final updateQtyUseCase = MockUpdateCartItemQuantityUseCase();
      final cubitForQty = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        updateQtyUseCase,
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubitForQty.close);

      const item = CartItemEntity(
        id: 1,
        quantity: 3,
        unitPrice: 100,
        totalPrice: 300,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(
          CartEntity(totalItems: 3, totalAmount: 300, items: [item]),
        ),
      );
      await cubitForQty.loadCart();

      CartItemEntity itemWith(int q) => CartItemEntity(
            id: 1,
            quantity: q,
            unitPrice: 100,
            totalPrice: 100.0 * q,
            product: item.product,
            variant: item.variant,
            vendor: item.vendor,
          );

      // The FIRST tap ('-', target 2) resolves SLOWER than the SECOND tap
      // ('+', target 3) — deliberately reversed arrival order, to prove
      // the final state is decided by request order (the version guard),
      // not by whichever response happens to land last.
      final minusGate = Completer<Either<Failure, CartEntity>>();
      when(() => updateQtyUseCase(itemId: 1, quantity: 2))
          .thenAnswer((_) => minusGate.future);
      when(() => updateQtyUseCase(itemId: 1, quantity: 3)).thenAnswer(
        (_) async => Right(
          CartEntity(totalItems: 3, totalAmount: 300, items: [itemWith(3)]),
        ),
      );

      final minusTap = cubitForQty.decreaseQuantity(item); // target 2, slow
      final plusTap = cubitForQty.increaseQuantity(item);  // target 3, fast

      await plusTap; // the '+' tap's response lands first.
      expect(cubitForQty.state.items.first.quantity, 3,
          reason: "the last action ('+') has settled and must be reflected");

      // Now the STALE '-' tap's response finally arrives, with a
      // conflicting payload (quantity 2). It must be discarded, not
      // overwrite the already-correct state.
      minusGate.complete(
        Right(
          CartEntity(totalItems: 2, totalAmount: 200, items: [itemWith(2)]),
        ),
      );
      await minusTap;

      expect(cubitForQty.state.items.first.quantity, 3,
          reason: "the stale '-' response landing last must not revert the "
              "quantity — the LAST user action ('+') is what must stick, "
              'not whichever network response arrives last');
    },
  );

  test(
    'swipe-deleting an item while its own "-" quantity-update is still in '
    'flight leaves it removed — no ghost row, no stale quantity flashing '
    'back once the update\'s late response arrives',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final updateQtyUseCase = MockUpdateCartItemQuantityUseCase();
      final removeItemUseCase = MockRemoveCartItemUseCase();
      final cubitForQty = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        updateQtyUseCase,
        removeItemUseCase,
        MockClearCartUseCase(),
      );
      addTearDown(cubitForQty.close);

      const item = CartItemEntity(
        id: 1,
        quantity: 3,
        unitPrice: 100,
        totalPrice: 300,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(
          CartEntity(totalItems: 3, totalAmount: 300, items: [item]),
        ),
      );
      await cubitForQty.loadCart();

      // The "-" tap's own network response is gated open — it hasn't
      // resolved when the swipe-delete happens.
      final updateGate = Completer<Either<Failure, CartEntity>>();
      when(() => updateQtyUseCase(itemId: 1, quantity: 2))
          .thenAnswer((_) => updateGate.future);

      final decreaseFuture = cubitForQty.decreaseQuantity(item);

      // Immediately swipe-delete the same item — removeItem() resolves
      // quickly and _refreshCartSilently() re-fetches an empty cart.
      when(() => removeItemUseCase(itemId: 1))
          .thenAnswer((_) async => const Right('Item removed'));
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(CartEntity(totalItems: 0, totalAmount: 0)),
      );
      await cubitForQty.removeItem(1);

      expect(cubitForQty.state.items, isEmpty,
          reason: 'the item must be gone right after the swipe-delete '
              'settles');

      // Now the STALE "-" update's response finally lands, carrying a
      // cart payload where the item still exists at quantity 2 — this
      // must be discarded by the shared per-item version guard, not
      // resurrect a "ghost row".
      updateGate.complete(
        Right(
          CartEntity(
            totalItems: 2,
            totalAmount: 200,
            items: [
              CartItemEntity(
                id: 1,
                quantity: 2,
                unitPrice: 100,
                totalPrice: 200,
                product: item.product,
                variant: item.variant,
                vendor: item.vendor,
              ),
            ],
          ),
        ),
      );
      await decreaseFuture;

      expect(cubitForQty.state.items, isEmpty,
          reason: "the stale quantity-update response must not bring the "
              'deleted item back as a ghost row');
    },
  );

  test(
    'CartCubit.clearCart() removes all items and reloads to an empty cart',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final clearCartUseCase = MockClearCartUseCase();
      final cubitToClear = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        MockUpdateCartItemQuantityUseCase(),
        MockRemoveCartItemUseCase(),
        clearCartUseCase,
      );
      addTearDown(cubitToClear.close);

      when(() => getCartUseCase()).thenAnswer(
        (_) async => Right(
          CartEntity(totalItems: 2, totalAmount: 200, items: [_cartItem()]),
        ),
      );
      await cubitToClear.loadCart();
      expect(cubitToClear.state.items, isNotEmpty);

      when(() => clearCartUseCase()).thenAnswer((_) async => const Right('Cart cleared'));
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(CartEntity(totalItems: 0, totalAmount: 0)),
      );

      await cubitToClear.clearCart();

      expect(cubitToClear.state.items, isEmpty,
          reason: 'clearCart() must reload the cart to its empty state');
      expect(cubitToClear.state.totalItems, 0);
    },
  );

  test(
    'a server-side clearCart() failure surfaces the error and leaves the '
    'existing items in place — not optimistically cleared',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final clearCartUseCase = MockClearCartUseCase();
      final cubitToClear = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        MockUpdateCartItemQuantityUseCase(),
        MockRemoveCartItemUseCase(),
        clearCartUseCase,
      );
      addTearDown(cubitToClear.close);

      when(() => getCartUseCase()).thenAnswer(
        (_) async => Right(
          CartEntity(totalItems: 2, totalAmount: 200, items: [_cartItem()]),
        ),
      );
      await cubitToClear.loadCart();
      expect(cubitToClear.state.items, isNotEmpty);

      when(() => clearCartUseCase()).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'Unable to clear your cart')),
      );

      await cubitToClear.clearCart();

      final state = cubitToClear.state;
      expect(state.error, 'Unable to clear your cart');
      expect(state.items, isNotEmpty,
          reason: 'clearCart() never optimistically empties the cart '
              'before the call settles — it only reloads on success — so '
              'a failure must leave the pre-existing items untouched');
      expect(state.items.length, 1);
      expect(state.totalItems, 2);
    },
  );

  test(
    'FIXED: every screen\'s cart badge now reads cartState.totalItems, so '
    'the same live cart shows the SAME number everywhere — Home used to '
    'read cartState.uniqueItems (distinct products) while Categories/PDP '
    'read totalItems (total units), disagreeing whenever any item had '
    'quantity > 1',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final cubit = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        MockUpdateCartItemQuantityUseCase(),
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubit.close);

      // A single distinct product, but 3 units of it.
      const item = CartItemEntity(
        id: 1,
        quantity: 3,
        unitPrice: 100,
        totalPrice: 300,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: _variantUuid, sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(
          CartEntity(totalItems: 3, totalAmount: 300, items: [item]),
        ),
      );
      await cubit.loadCart();

      // home_screen.dart:151 -> HomeHeader(cartCount: cartState.totalItems)
      final homeScreenBadge = cubit.state.totalItems;
      // categories_screen.dart:159 -> CatHeader(cartCount: cartState.totalItems)
      final categoriesScreenBadge = cubit.state.totalItems;
      // product_details_screen.dart -> ProductTopBar(cartCount:
      // cartState.state.totalItems)
      final pdpBadge = cubit.state.totalItems;

      expect(homeScreenBadge, 3, reason: '3 total units — not 1 distinct '
          'product, now that Home also reads totalItems');
      expect(categoriesScreenBadge, 3);
      expect(pdpBadge, 3);

      expect(
        homeScreenBadge,
        equals(categoriesScreenBadge),
        reason: 'the same live cart must show the same badge number on '
            'every screen',
      );
      expect(homeScreenBadge, equals(pdpBadge));
    },
  );

  test(
    'loadCart() has no "already loaded, skip" gate — every call always '
    'goes to the server, so a fresh app process (a real restart cannot '
    'preserve in-memory state anyway) always re-fetches instead of ever '
    'being able to serve stale data',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final cubit = CartCubit(
        getCartUseCase,
        MockAddCartItemUseCase(),
        MockUpdateCartItemQuantityUseCase(),
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubit.close);

      var callCount = 0;
      when(() => getCartUseCase()).thenAnswer((_) async {
        callCount++;
        return Right(
          CartEntity(totalItems: callCount, totalAmount: 100.0 * callCount),
        );
      });

      // cart_screen.dart's initState() unconditionally calls loadCart()
      // every time the Cart screen mounts — simulate visiting it twice
      // (e.g. once per app session).
      await cubit.loadCart();
      expect(callCount, 1);
      expect(cubit.state.totalItems, 1);

      await cubit.loadCart();
      expect(callCount, 2,
          reason: 'a second visit must hit the server again, not reuse a '
              'cached result from the first call');
      expect(cubit.state.totalItems, 2);
    },
  );

  test(
    'F-09: an unrelated cart operation (a backgrounded Cart screen\'s '
    'quantity-change) failing in the gap must not bleed its error message '
    'into Product A\'s own addItem() outcome',
    () async {
      final getCartUseCase = MockGetCartUseCase();
      final updateQtyUseCase = MockUpdateCartItemQuantityUseCase();
      final cubit = CartCubit(
        getCartUseCase,
        addItemUseCase,
        updateQtyUseCase,
        MockRemoveCartItemUseCase(),
        MockClearCartUseCase(),
      );
      addTearDown(cubit.close);

      // Product A's add-to-cart (on its own PDP) is gated open.
      final addGate = Completer<Either<Failure, CartEntity>>();
      when(() => addItemUseCase(variantUuid: 'product-a-variant', quantity: 1))
          .thenAnswer((_) => addGate.future);

      // An unrelated item's quantity-change (on a backgrounded Cart
      // screen) is ALSO in flight, and will fail, setting the shared
      // CartState.error field.
      final qtyGate = Completer<Either<Failure, CartEntity>>();
      when(() => updateQtyUseCase(itemId: 99, quantity: 2))
          .thenAnswer((_) => qtyGate.future);

      final addFuture = cubit.addItem(variantUuid: 'product-a-variant', quantity: 1);
      const unrelatedItem = CartItemEntity(
        id: 99,
        quantity: 1,
        unitPrice: 50,
        totalPrice: 50,
        product: CartProductEntity(uuid: 'p-99', title: 'Silver Chain', slug: 'silver-chain'),
        variant: CartVariantEntity(uuid: 'unrelated-variant', sku: 'sku-99', stock: 1),
        vendor: CartVendorEntity(uuid: 'v-99', shopName: 'Bingo Jewels'),
      );
      final qtyFuture = cubit.increaseQuantity(unrelatedItem);

      // The unrelated quantity-change resolves FIRST, with a failure —
      // this sets the shared/global CartState.error field.
      qtyGate.complete(
        const Left(ServerFailure(message: 'Unrelated background error')),
      );
      await qtyFuture;
      expect(cubit.state.error, 'Unrelated background error',
          reason: 'sanity check: the shared error field now holds the '
              "unrelated operation's message");

      // NOW Product A's add-to-cart resolves successfully.
      addGate.complete(
        Right(
          CartEntity(
            totalItems: 1,
            totalAmount: 100,
            items: [
              CartItemEntity(
                id: 1,
                quantity: 1,
                unitPrice: 100,
                totalPrice: 100,
                product: const CartProductEntity(uuid: 'p-a', title: 'Gold Ring', slug: 'gold-ring'),
                variant: const CartVariantEntity(uuid: 'product-a-variant', sku: 'sku-a', stock: 5),
                vendor: const CartVendorEntity(uuid: 'v-a', shopName: 'Bingo Jewels'),
              ),
            ],
          ),
        ),
      );
      final result = await addFuture;

      // product_details_screen.dart reads `result.success` /
      // `result.errorMessage` — the value RETURNED from this specific
      // addItem() call — never `cartCubit.state.error`. Even though
      // state.error still holds the unrelated message, Product A's own
      // outcome must be correctly reported as a success.
      expect(result.success, isTrue,
          reason: "Product A's own addItem() call succeeded and must "
              "report success, regardless of what the shared state.error "
              "field currently holds from the unrelated operation");
      expect(result.errorMessage, isNull);
    },
  );

  test(
    '"Go to Cart" state is correct the instant a fresh PDP instance builds '
    'after re-entering — no re-entry/refresh needed to catch up',
    () async {
      when(() => addItemUseCase(variantUuid: _variantUuid, quantity: 1))
          .thenAnswer((_) async => Right(
                CartEntity(totalItems: 1, totalAmount: 100, items: [_cartItem()]),
              ));

      await cartCubit.addItem(variantUuid: _variantUuid, quantity: 1);

      // Simulate leaving the PDP and re-entering it: a brand new screen
      // instance's first build calls context.watch<CartCubit>(), which
      // (per flutter_bloc) synchronously reads the cubit's CURRENT state
      // on that very first build — it doesn't wait for a stream event.
      // So the freshly-built isInCart computation must already be correct.
      bool isInCartOnFreshBuild(String variantUuid) =>
          cartCubit.state.items.any((i) => i.variant.uuid == variantUuid);

      expect(isInCartOnFreshBuild(_variantUuid), isTrue,
          reason: 'product_details_screen.dart:148-150 recomputes '
              'isInCart from context.watch<CartCubit>().state on every '
              'build, including the very first one — a re-entered PDP '
              'must show "Go to Cart" immediately');
    },
  );

  test(
    'FIXED: addItem() now has a per-variantUuid version guard, so two '
    'concurrent adds of the SAME variant from two screens can no longer '
    'let an out-of-order, stale response overwrite the correct merged '
    'cart',
    () async {
      // The client sends two independent POST /cart/items requests for
      // the same variant — whether the SERVER merges them into one line
      // item (qty 2) or creates a duplicate line is a server-side
      // contract question outside client control. This test isolates a
      // purely client-side risk: even if the server DOES merge correctly,
      // the client can still show the wrong result if responses race.
      final listingCardGate = Completer<Either<Failure, CartEntity>>();
      final pdpGate = Completer<Either<Failure, CartEntity>>();
      var callNumber = 0;
      when(() => addItemUseCase(variantUuid: _variantUuid, quantity: 1))
          .thenAnswer((_) {
        callNumber++;
        // First call (listing card) is slower; second (PDP) is faster.
        return callNumber == 1 ? listingCardGate.future : pdpGate.future;
      });

      final listingCardAdd =
          cartCubit.addItem(variantUuid: _variantUuid, quantity: 1);
      final pdpAdd = cartCubit.addItem(variantUuid: _variantUuid, quantity: 1);

      // The PDP's request reaches the server second but the server
      // processes/responds to it FIRST, correctly returning the fully
      // merged cart (one line item, quantity 2).
      pdpGate.complete(
        Right(
          CartEntity(
            totalItems: 2,
            totalAmount: 200,
            items: [
              CartItemEntity(
                id: 1,
                quantity: 2,
                unitPrice: 100,
                totalPrice: 200,
                product: _cartItem().product,
                variant: _cartItem().variant,
                vendor: _cartItem().vendor,
              ),
            ],
          ),
        ),
      );
      await pdpAdd;
      expect(cartCubit.state.items.first.quantity, 2,
          reason: 'the correct, merged state after the faster response');

      // The listing card's response — computed by the server from an
      // earlier snapshot, BEFORE the PDP's write had committed — now
      // lands late, still showing only quantity 1.
      listingCardGate.complete(
        Right(
          CartEntity(
            totalItems: 1,
            totalAmount: 100,
            items: [_cartItem()], // quantity: 1
          ),
        ),
      );
      final staleResult = await listingCardAdd;

      // FIXED: addItem() now tracks a per-variantUuid version. The PDP's
      // call started SECOND, so it bumped the version past the listing
      // card's — when the listing card's stale response arrives late, it
      // recognizes itself as superseded and does not touch state.cart.
      expect(
        cartCubit.state.items.first.quantity,
        2,
        reason: 'the stale listing-card response must be discarded — the '
            "PDP's correct, merged quantity-2 state must stick",
      );

      // The listing card's OWN caller still gets an accurate result for
      // its specific request (the add itself did succeed server-side),
      // even though it wasn't allowed to overwrite the newer cart state.
      expect(staleResult.success, isTrue);
    },
  );

  test(
    'a newly-added item is placed at the TOP of the cart list, regardless '
    'of where the server\'s own response puts it',
    () async {
      // The cart already has two items; the server appends the new one at
      // the END of its response (a common, but not user-friendly, backend
      // ordering) rather than the front.
      const existing1 = CartItemEntity(
        id: 1,
        quantity: 1,
        unitPrice: 100,
        totalPrice: 100,
        product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
        variant: CartVariantEntity(uuid: 'variant-existing-1', sku: 'sku-1', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
      );
      const existing2 = CartItemEntity(
        id: 2,
        quantity: 1,
        unitPrice: 200,
        totalPrice: 200,
        product: CartProductEntity(uuid: 'p-2', title: 'Silver Chain', slug: 'silver-chain'),
        variant: CartVariantEntity(uuid: 'variant-existing-2', sku: 'sku-2', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-2', shopName: 'Bingo Jewels'),
      );
      const justAdded = CartItemEntity(
        id: 3,
        quantity: 1,
        unitPrice: 300,
        totalPrice: 300,
        product: CartProductEntity(uuid: 'p-3', title: 'Diamond Ring', slug: 'diamond-ring'),
        variant: CartVariantEntity(uuid: 'variant-new', sku: 'sku-3', stock: 5),
        vendor: CartVendorEntity(uuid: 'v-3', shopName: 'Bingo Jewels'),
      );

      when(() => addItemUseCase(variantUuid: 'variant-new', quantity: 1))
          .thenAnswer((_) async => const Right(
                CartEntity(
                  totalItems: 3,
                  totalAmount: 600,
                  // Server puts the new item LAST.
                  items: [existing1, existing2, justAdded],
                ),
              ));

      await cartCubit.addItem(variantUuid: 'variant-new', quantity: 1);

      expect(
        cartCubit.state.items.map((i) => i.variant.uuid).toList(),
        ['variant-new', 'variant-existing-1', 'variant-existing-2'],
        reason: 'the client must reorder the server\'s response so the '
            'just-added item shows first, not wherever the backend placed '
            'it — the existing items\' relative order is otherwise '
            'preserved',
      );
    },
  );
}
