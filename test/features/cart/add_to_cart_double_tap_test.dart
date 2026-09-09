import 'dart:async';
import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/core/widgets/app_button.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:bingo_pay/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bingo_pay/features/cart/presentation/cubit/cart_state.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class MockAddCartItemUseCase extends Mock implements AddCartItemUseCase {}

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockUpdateCartItemQuantityUseCase extends Mock
    implements UpdateCartItemQuantityUseCase {}

class MockRemoveCartItemUseCase extends Mock implements RemoveCartItemUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

const _variantUuid = 'variant-abc';

/// A minimal stand-in for _ProductDetailScreenState, reproducing exactly
/// two things from product_details_screen.dart:
///   1. Before the fix: only `secondaryLoading: cartState.isAddingItem`
///      gated the button (via AppButton's isLoading -> onPressed: null).
///   2. After the fix: an explicit `_isAddingToCart` flag is checked and
///      set synchronously, before any await — mirroring the pre-existing
///      `_isBuyingNow` guard on Buy Now — so a second tap that lands
///      before the first tap's rebuild still gets blocked.
class _AddToCartHarness extends StatefulWidget {
  final CartCubit cartCubit;
  final bool useGuard;

  const _AddToCartHarness({required this.cartCubit, required this.useGuard});

  @override
  State<_AddToCartHarness> createState() => _AddToCartHarnessState();
}

class _AddToCartHarnessState extends State<_AddToCartHarness> {
  bool _isAddingToCart = false;

  Future<void> _addToCart() async {
    if (widget.useGuard && _isAddingToCart) return;
    if (widget.useGuard) setState(() => _isAddingToCart = true);
    await widget.cartCubit.addItem(variantUuid: _variantUuid, quantity: 1);
    if (widget.useGuard && mounted) setState(() => _isAddingToCart = false);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      bloc: widget.cartCubit,
      builder: (context, state) => AppButton(
        label: 'Add to Cart',
        isLoading: state.isAddingItem,
        onPressed: () => _addToCart(),
      ),
    );
  }
}

void main() {
  Future<(CartCubit, MockAddCartItemUseCase, Completer<Either<Failure, CartEntity>>, List<int>)>
      _setUp() async {
    final addItemUseCase = MockAddCartItemUseCase();
    final cartCubit = CartCubit(
      MockGetCartUseCase(),
      addItemUseCase,
      MockUpdateCartItemQuantityUseCase(),
      MockRemoveCartItemUseCase(),
      MockClearCartUseCase(),
    );
    final gate = Completer<Either<Failure, CartEntity>>();
    final calls = <int>[];
    when(() => addItemUseCase(variantUuid: _variantUuid, quantity: 1))
        .thenAnswer((_) {
      calls.add(1);
      return gate.future;
    });
    return (cartCubit, addItemUseCase, gate, calls);
  }

  testWidgets(
    'BEFORE the fix: relying only on cartState.isAddingItem to disable the '
    'button, two rapid taps (no pump in between) fire addItem() twice',
    (tester) async {
      final (cartCubit, _, gate, calls) = await _setUp();
      addTearDown(cartCubit.close);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            home: Scaffold(
              body: _AddToCartHarness(cartCubit: cartCubit, useGuard: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppButton));
      await tester.tap(find.byType(AppButton));

      gate.complete(
        const Right(CartEntity(totalItems: 1, totalAmount: 100, items: [])),
      );
      await tester.pumpAndSettle();

      expect(calls.length, 2,
          reason: 'demonstrates the pre-fix bug: the isAddingItem-driven '
              "disable isn't fast enough to stop a second tap landing "
              "before the first tap's rebuild");
    },
  );

  testWidgets(
    'AFTER the fix: the synchronous _isAddingToCart guard (mirroring '
    "_isBuyingNow) ensures two rapid taps still fire addItem() exactly once",
    (tester) async {
      final (cartCubit, _, gate, calls) = await _setUp();
      addTearDown(cartCubit.close);

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            home: Scaffold(
              body: _AddToCartHarness(cartCubit: cartCubit, useGuard: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AppButton));
      await tester.tap(find.byType(AppButton));

      gate.complete(
        const Right(CartEntity(totalItems: 1, totalAmount: 100, items: [])),
      );
      await tester.pumpAndSettle();

      expect(calls.length, 1,
          reason: 'exactly one addItem() call must fire per rapid '
              'double-tap once the synchronous guard is in place');
    },
  );
}
