import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_bloc.dart';
import 'package:bingo_pay/features/customer/shop/presentation/bloc/shop_event.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes/fake_shop_remote_datasource.dart';

void main() {
  test('loads fixture catalog and filters products', () async {
    final bloc = ShopBloc(remoteDataSource: FakeShopRemoteDataSource());

    bloc.add(const ShopStarted());
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(bloc.state.isLoading, isFalse);
    expect(bloc.state.categories, hasLength(6));
    expect(bloc.state.products, hasLength(8));

    bloc.add(const ShopSearchChanged('headphones'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.filteredProducts, hasLength(1));
    expect(bloc.state.filteredProducts.single.id, 'p1001');

    bloc.add(const ShopCategorySelected('home'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.filteredProducts, isEmpty);

    await bloc.close();
  });

  test('supports cart and saved-for-later flows', () async {
    final bloc = ShopBloc(remoteDataSource: FakeShopRemoteDataSource());

    bloc.add(const ShopStarted());
    await Future<void>.delayed(const Duration(milliseconds: 150));

    bloc.add(const ShopAddToCartRequested('p1001'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.cartCount, 1);
    expect(bloc.state.cartItems.single.quantity, 1);

    bloc.add(const ShopQuantityIncreased('p1001'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.cartItems.single.quantity, 2);

    bloc.add(const ShopSaveForLaterToggled('p1001'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.cartItems, isEmpty);
    expect(bloc.state.savedForLaterProductIds, contains('p1001'));

    await bloc.close();
  });

  test('applies promo codes and summary totals', () async {
    final bloc = ShopBloc(remoteDataSource: FakeShopRemoteDataSource());

    bloc.add(const ShopStarted());
    await Future<void>.delayed(const Duration(milliseconds: 150));
    bloc.add(const ShopAddToCartRequested('p1004'));
    await Future<void>.delayed(Duration.zero);
    bloc.add(const ShopPromoCodeApplied('SAVE10'));
    await Future<void>.delayed(Duration.zero);

    expect(bloc.state.promoCode, 'SAVE10');
    expect(bloc.state.promoDiscount, greaterThan(0));
    expect(bloc.state.cartTotal, greaterThan(0));

    await bloc.close();
  });
}
