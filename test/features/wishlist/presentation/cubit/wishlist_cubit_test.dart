import 'package:bingo_pay/features/wishlist/data/models/wishlist_model.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const item = WishlistItem(
    id: 'product-a',
    variantUuid: 'variant-a',
    brand: 'Brand',
    name: 'Product A',
    price: r'$10',
  );

  test('keeps wishlists isolated between authenticated users', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = WishlistCubit(prefs);
    addTearDown(cubit.close);

    await cubit.loadForUser('user-a');
    await cubit.toggle(item);

    await cubit.loadForUser('user-b');
    expect(cubit.state.items, isEmpty);

    await cubit.loadForUser('user-a');
    expect(cubit.state.items, [item]);
  });

  test('clears the in-memory wishlist on logout', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final cubit = WishlistCubit(prefs);
    addTearDown(cubit.close);

    await cubit.loadForUser('user-a');
    await cubit.toggle(item);
    cubit.clearForLogout();

    expect(cubit.state.items, isEmpty);
    await cubit.loadForUser('user-a');
    expect(cubit.state.items, [item]);
  });
}
