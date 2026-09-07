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
import 'package:bingo_pay/features/cart/presentation/screens/cart_screen.dart';
import 'package:bingo_pay/features/cart/presentation/widgets/cart_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class MockAddCartItemUseCase extends Mock implements AddCartItemUseCase {}

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockUpdateCartItemQuantityUseCase extends Mock
    implements UpdateCartItemQuantityUseCase {}

class MockRemoveCartItemUseCase extends Mock implements RemoveCartItemUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

CartItemEntity _item() => const CartItemEntity(
      id: 1,
      quantity: 1,
      unitPrice: 100,
      totalPrice: 100,
      product: CartProductEntity(uuid: 'p-1', title: 'Gold Ring', slug: 'gold-ring'),
      variant: CartVariantEntity(uuid: 'variant-1', sku: 'sku-1', stock: 5),
      vendor: CartVendorEntity(uuid: 'v-1', shopName: 'Bingo Jewels'),
    );

Widget _wrap(CartCubit cubit) => Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        home: BlocProvider<CartCubit>.value(
          value: cubit,
          child: const CartPage(),
        ),
      ),
    );

void main() {
  late MockGetCartUseCase getCartUseCase;
  late MockClearCartUseCase clearCartUseCase;
  late CartCubit cubit;

  setUp(() {
    getCartUseCase = MockGetCartUseCase();
    clearCartUseCase = MockClearCartUseCase();
    cubit = CartCubit(
      getCartUseCase,
      MockAddCartItemUseCase(),
      MockUpdateCartItemQuantityUseCase(),
      MockRemoveCartItemUseCase(),
      clearCartUseCase,
    );
  });

  tearDown(() => cubit.close());

  testWidgets(
    'the cart shimmer renders (not a bare spinner) while loadCart() is in '
    'flight',
    (tester) async {
      final gate = Completer<Either<Failure, CartEntity>>();
      when(() => getCartUseCase()).thenAnswer((_) => gate.future);

      await tester.pumpWidget(_wrap(cubit));
      // Don't settle — the load is still in flight.
      await tester.pump();

      expect(find.byType(CartShimmer), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing,
          reason: 'the shimmer replaces the old bare spinner');

      gate.complete(Right(CartEntity(totalItems: 1, totalAmount: 100, items: [_item()])));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'tapping the Clear Cart icon, then confirming, calls clearCart() and '
    'the cart ends up empty',
    (tester) async {
      when(() => getCartUseCase()).thenAnswer(
        (_) async => Right(CartEntity(totalItems: 1, totalAmount: 100, items: [_item()])),
      );

      await tester.pumpWidget(_wrap(cubit));
      await tester.pumpAndSettle();

      // The delete/clear icon only shows when items are present.
      final clearIcon = find.byIcon(Icons.delete_sweep_outlined);
      expect(clearIcon, findsOneWidget);

      when(() => clearCartUseCase()).thenAnswer((_) async => const Right('Cart cleared'));
      when(() => getCartUseCase()).thenAnswer(
        (_) async => const Right(CartEntity(totalItems: 0, totalAmount: 0)),
      );

      await tester.tap(clearIcon);
      await tester.pumpAndSettle();

      // Confirmation dialog.
      expect(find.text('Clear cart?'), findsOneWidget);
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      verify(() => clearCartUseCase()).called(1);
      expect(cubit.state.items, isEmpty);
    },
  );

  testWidgets(
    'tapping Cancel in the confirmation dialog does not clear the cart',
    (tester) async {
      when(() => getCartUseCase()).thenAnswer(
        (_) async => Right(CartEntity(totalItems: 1, totalAmount: 100, items: [_item()])),
      );

      await tester.pumpWidget(_wrap(cubit));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => clearCartUseCase());
      expect(cubit.state.items, isNotEmpty);
    },
  );

  testWidgets(
    'a server-side clearCart() failure shows an error snackbar and leaves '
    'the existing items in place — not optimistically cleared',
    (tester) async {
      when(() => getCartUseCase()).thenAnswer(
        (_) async => Right(CartEntity(totalItems: 1, totalAmount: 100, items: [_item()])),
      );

      await tester.pumpWidget(_wrap(cubit));
      await tester.pumpAndSettle();

      when(() => clearCartUseCase()).thenAnswer(
        (_) async =>
            const Left(ServerFailure(message: 'Unable to clear your cart')),
      );

      await tester.tap(find.byIcon(Icons.delete_sweep_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      verify(() => clearCartUseCase()).called(1);

      // cart_screen.dart's _confirmClearCart() shows
      // cubit.state.error via AppSnackbar.showError on failure.
      expect(find.text('Unable to clear your cart'), findsOneWidget,
          reason: 'the failure must be surfaced to the user, not silent');

      // The item must still be there — clearCart() never optimistically
      // empties the cart before the call settles.
      expect(cubit.state.items, isNotEmpty);
      expect(find.text('Gold Ring'), findsOneWidget,
          reason: 'the existing cart item must still render on screen');
    },
  );
}
