import 'package:bingo_pay/features/home/data/models/product_model.dart';
import 'package:bingo_pay/features/product_details/data/models/product_details_model.dart';
import 'package:bingo_pay/features/wishlist/data/models/wishlist_model.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mirrors HomeScreen._toggleWishlist()'s WishlistItem construction exactly
/// (home_screen.dart:473-484), for the Dashboard add-to-wishlist entry point.
WishlistItem _dashboardToWishlistItem(ProductModel product) => WishlistItem(
      id: product.uuid!,
      brand: product.brand,
      name: product.name,
      price: product.price,
      originalPrice: product.oldPrice.isNotEmpty ? product.oldPrice : null,
      discountPercent: product.discount > 0 ? product.discount : null,
      imageUrl: product.images.isNotEmpty ? product.images.first : null,
      rating: product.rating,
    );

/// Mirrors _toWishlistItem() in product_details_screen.dart exactly, since
/// that helper is file-private and can't be imported directly.
WishlistItem _toWishlistItem(ProductDetailModel product, String uuid) =>
    WishlistItem(
      id: uuid,
      brand: product.brand,
      name: product.productName,
      price: product.price,
      originalPrice: product.oldPrice.isNotEmpty ? product.oldPrice : null,
      discountPercent: product.discount > 0 ? product.discount : null,
      imageUrl: product.images.isNotEmpty ? product.images.first : null,
      rating: product.rating,
    );

ProductDetailModel _product() => ProductDetailModel(
      id: 'p-1',
      uuid: 'prod-uuid-123',
      productName: 'Gold Necklace 22K',
      brand: 'Bingo Jewels',
      rating: '4.6',
      reviewCount: '1.2k',
      icon: Icons.shopping_bag_outlined,
      images: const ['https://cdn.example.com/img1.jpg'],
      variants: [
        ProductVariant(
          uuid: 'var-1',
          title: 'Small',
          variantName: 'Small',
          combinationKey: 'small',
          salePrice: 4500,
          basePrice: 5000,
          availableStock: 3,
          attributes: const [],
        ),
      ],
    );

void main() {
  late WishlistCubit wishlistCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    wishlistCubit = WishlistCubit(prefs);
    await wishlistCubit.loadForUser('user-1');
  });

  tearDown(() => wishlistCubit.close());

  test(
    'tapping the PDP heart toggles the current product and is reflected '
    'instantly via wishlist.isWishlisted(uuid)',
    () async {
      final product = _product();
      final uuid = product.uuid!;

      // Mirrors product_details_screen.dart's isWishlisted computation
      // exactly: wishlistCubit.isWishlisted(product.uuid).
      expect(wishlistCubit.isWishlisted(uuid), isFalse,
          reason: 'not wishlisted before the first tap');

      await wishlistCubit.toggle(_toWishlistItem(product, uuid), wasWishlisted: false);
      expect(wishlistCubit.isWishlisted(uuid), isTrue,
          reason: 'the heart must fill in immediately after tapping');

      // Tapping again removes it — a real toggle, not a one-way add.
      await wishlistCubit.toggle(_toWishlistItem(product, uuid), wasWishlisted: true);
      expect(wishlistCubit.isWishlisted(uuid), isFalse,
          reason: 'tapping the filled heart again must remove the product');
    },
  );

  test(
    'the wishlist item captures the correct product details for later '
    'display on the Wishlist screen',
    () async {
      final product = _product();
      final uuid = product.uuid!;

      await wishlistCubit.toggle(_toWishlistItem(product, uuid), wasWishlisted: false);

      final saved = wishlistCubit.state.items.firstWhere((i) => i.id == uuid);
      expect(saved.brand, 'Bingo Jewels');
      expect(saved.name, 'Gold Necklace 22K');
      expect(saved.price, '\$4,500');
      expect(saved.originalPrice, '\$5,000');
      expect(saved.discountPercent, 10);
      expect(saved.imageUrl, 'https://cdn.example.com/img1.jpg');
    },
  );

  test(
    'adding a product to the wishlist from the Dashboard: heart fills, '
    'the item shows up in what the Wishlist screen renders '
    '(WishlistCubit.state.items), and it survives a fresh cubit reload',
    () async {
      final dashboardProduct = ProductModel(
        uuid: 'dash-uuid-9',
        brand: 'Bingo Jewels',
        name: 'Silver Bracelet',
        price: '\$1,200',
        oldPrice: '\$1,500',
        rating: '4.2',
        discount: 20,
        icon: Icons.shopping_bag_outlined,
        images: const ['https://cdn.example.com/bracelet.jpg'],
      );

      expect(wishlistCubit.isWishlisted('dash-uuid-9'), isFalse);

      await wishlistCubit.toggle(
        _dashboardToWishlistItem(dashboardProduct),
        wasWishlisted: false,
      );

      // Heart fills.
      expect(wishlistCubit.isWishlisted('dash-uuid-9'), isTrue);

      // Item appears on the Wishlist screen (which renders
      // BlocBuilder<WishlistCubit, WishlistState> -> state.items).
      final onWishlistScreen =
          wishlistCubit.state.items.firstWhere((i) => i.id == 'dash-uuid-9');
      expect(onWishlistScreen.name, 'Silver Bracelet');
      expect(onWishlistScreen.price, '\$1,200');

      // Persisted: a fresh cubit instance (simulating a new app session)
      // reloads it from storage.
      final reloaded = WishlistCubit(await SharedPreferences.getInstance());
      addTearDown(reloaded.close);
      await reloaded.loadForUser('user-1');
      expect(reloaded.isWishlisted('dash-uuid-9'), isTrue);
    },
  );

  test(
    'un-tapping the heart (toggle() when already wishlisted, used by '
    'Home/PDP/Listing cards) removes the item — disappears everywhere '
    'that watches the shared WishlistCubit, and the removal persists',
    () async {
      final product = _product();
      final uuid = product.uuid!;
      await wishlistCubit.toggle(_toWishlistItem(product, uuid), wasWishlisted: false);
      expect(wishlistCubit.isWishlisted(uuid), isTrue);

      // Un-tap the (now filled) heart.
      await wishlistCubit.toggle(_toWishlistItem(product, uuid), wasWishlisted: true);

      expect(wishlistCubit.isWishlisted(uuid), isFalse,
          reason: 'removed from the shared cubit — any card, PDP heart, or '
              'the Wishlist screen itself watching this same cubit '
              'instance immediately reflects the removal');
      expect(wishlistCubit.state.items.any((i) => i.id == uuid), isFalse);

      // The removal itself must be persisted, not just the addition.
      final reloaded = WishlistCubit(await SharedPreferences.getInstance());
      addTearDown(reloaded.close);
      await reloaded.loadForUser('user-1');
      expect(reloaded.isWishlisted(uuid), isFalse,
          reason: 'a fresh session must not resurrect the removed item');
    },
  );

  test(
    'the Wishlist screen\'s own remove action (heart tap on WishlistCard, '
    'wired to WishlistCubit.remove(id)) also removes the item everywhere '
    'and persists the removal',
    () async {
      final product = _product();
      final uuid = product.uuid!;
      await wishlistCubit.toggle(_toWishlistItem(product, uuid), wasWishlisted: false);
      expect(wishlistCubit.isWishlisted(uuid), isTrue);

      // wishlist_screen.dart:368-370: onRemove: () =>
      // context.read<WishlistCubit>().remove(item.id)
      await wishlistCubit.remove(uuid);

      expect(wishlistCubit.isWishlisted(uuid), isFalse);
      expect(wishlistCubit.state.items, isEmpty);

      final reloaded = WishlistCubit(await SharedPreferences.getInstance());
      addTearDown(reloaded.close);
      await reloaded.loadForUser('user-1');
      expect(reloaded.isWishlisted(uuid), isFalse);
    },
  );

  test(
    'multiple wishlisted items all survive a simulated app restart — a '
    'fresh WishlistCubit calling loadForUser(userId) (as app.dart does '
    'automatically once auth resolves) restores every item intact',
    () async {
      final products = [
        _product(),
        ProductDetailModel(
          id: 'p-2',
          uuid: 'prod-uuid-456',
          productName: 'Diamond Ring',
          brand: 'Bingo Jewels',
          rating: '4.9',
          reviewCount: '500',
          icon: Icons.diamond_outlined,
          images: const ['https://cdn.example.com/ring.jpg'],
          variants: [
            ProductVariant(
              uuid: 'var-2',
              title: 'Standard',
              variantName: 'Standard',
              combinationKey: 'std',
              salePrice: 9999,
              basePrice: 9999,
              availableStock: 1,
              attributes: const [],
            ),
          ],
        ),
      ];

      for (final p in products) {
        await wishlistCubit.toggle(_toWishlistItem(p, p.uuid!), wasWishlisted: false);
      }
      expect(wishlistCubit.state.items.length, 2);

      // Kill and reopen: app.dart wires
      // `_wishlistCubit.loadForUser(state.user.id)` to fire once auth
      // resolves on every launch — simulate that with a brand new cubit
      // instance reading from the same (real, not mocked) SharedPreferences
      // store.
      final afterRestart = WishlistCubit(await SharedPreferences.getInstance());
      addTearDown(afterRestart.close);
      await afterRestart.loadForUser('user-1');

      expect(afterRestart.state.items.length, 2,
          reason: 'both wishlisted products must survive the restart');
      expect(afterRestart.isWishlisted('prod-uuid-123'), isTrue);
      expect(afterRestart.isWishlisted('prod-uuid-456'), isTrue);

      final restoredRing =
          afterRestart.state.items.firstWhere((i) => i.id == 'prod-uuid-456');
      expect(restoredRing.name, 'Diamond Ring');
      expect(restoredRing.price, '\$9,999');
    },
  );
}
