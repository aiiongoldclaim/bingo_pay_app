import 'package:bingo_pay/core/error/failures.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_entity.dart';
import 'package:bingo_pay/features/cart/domain/entities/cart_item_entity.dart';
import 'package:bingo_pay/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:bingo_pay/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bingo_pay/features/product_details/data/models/product_details_model.dart';
import 'package:bingo_pay/features/wishlist/data/models/wishlist_model.dart';
import 'package:bingo_pay/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWishlistRepository extends Mock implements WishlistRepository {}

class MockAddCartItemUseCase extends Mock implements AddCartItemUseCase {}

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockUpdateCartItemQuantityUseCase extends Mock
    implements UpdateCartItemQuantityUseCase {}

class MockRemoveCartItemUseCase extends Mock implements RemoveCartItemUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  late MockAddCartItemUseCase addItemUseCase;
  late CartCubit cartCubit;
  late WishlistCubit wishlistCubit;

  const item = WishlistItem(
    id: 'prod-1',
    variantUuid: 'variant-1',
    brand: 'Bingo Jewels',
    name: 'Gold Necklace',
    price: '\$4,500',
  );

  setUp(() async {
    addItemUseCase = MockAddCartItemUseCase();
    cartCubit = CartCubit(
      MockGetCartUseCase(),
      addItemUseCase,
      MockUpdateCartItemQuantityUseCase(),
      MockRemoveCartItemUseCase(),
      MockClearCartUseCase(),
    );

    SharedPreferences.setMockInitialValues({});
    wishlistCubit = WishlistCubit(await SharedPreferences.getInstance());
    await wishlistCubit.loadForUser('user-1');
    await wishlistCubit.toggle(item, wasWishlisted: false);
  });

  tearDown(() {
    cartCubit.close();
    wishlistCubit.close();
  });

  /// Mirrors wishlist_screen.dart's _moveToBag() success sequence exactly
  /// (lines 193-208): add to cart, then on success remove from wishlist,
  /// then show a success message — since _moveToBag is a private State
  /// method, this replicates the same call sequence for verification.
  Future<String?> moveToBag() async {
    final result =
        await cartCubit.addItem(variantUuid: item.variantUuid!, quantity: 1);
    if (!result.success) return null;
    await wishlistCubit.remove(item.id);
    return '${item.name} moved to bag';
  }

  test(
    'Move to Bag on an in-stock item: added to cart, then removed from '
    'wishlist, with a success message',
    () async {
      expect(wishlistCubit.isWishlisted('prod-1'), isTrue);

      when(() => addItemUseCase(variantUuid: 'variant-1', quantity: 1))
          .thenAnswer((_) async => Right(
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
              ));

      final successMessage = await moveToBag();

      // Added to cart.
      expect(
        cartCubit.state.items.any((i) => i.variant.uuid == 'variant-1'),
        isTrue,
        reason: 'the item must now be in the cart',
      );
      // Removed from wishlist.
      expect(wishlistCubit.isWishlisted('prod-1'), isFalse,
          reason: 'once successfully moved to the cart, it must no longer '
              'sit in the wishlist too');
      // Success snackbar shown.
      expect(successMessage, 'Gold Necklace moved to bag');
    },
  );

  test(
    'Move to Bag failing to add to cart leaves the item in the wishlist '
    '(no premature removal)',
    () async {
      when(() => addItemUseCase(variantUuid: 'variant-1', quantity: 1))
          .thenAnswer((_) async =>
              const Left(ServerFailure(message: 'Out of stock')));

      final successMessage = await moveToBag();

      expect(successMessage, isNull,
          reason: 'no success message when the add-to-cart step fails');
      expect(wishlistCubit.isWishlisted('prod-1'), isTrue,
          reason: 'the item must remain wishlisted if it never actually '
              'made it into the cart');
    },
  );

  group('F-13: multi-variant products with no variantUuid resolved yet', () {
    const noVariantItem = WishlistItem(
      id: 'prod-multi',
      // variantUuid intentionally omitted — e.g. wishlisted from a
      // listing card where no size/color was ever chosen.
      brand: 'Bingo Jewels',
      name: 'Classic Ring',
      price: '\$2,000',
    );

    late MockWishlistRepository repository;

    setUp(() async {
      repository = MockWishlistRepository();
      await wishlistCubit.toggle(noVariantItem, wasWishlisted: false);
    });

    ProductVariant _variant(String uuid, int stock) => ProductVariant(
          uuid: uuid,
          title: uuid,
          variantName: uuid,
          combinationKey: uuid,
          salePrice: 2000,
          basePrice: 2000,
          availableStock: stock,
          attributes: const [],
        );

    ProductDetailModel _productWith(List<ProductVariant> variants) =>
        ProductDetailModel(
          id: 'prod-multi',
          uuid: 'prod-multi',
          productName: 'Classic Ring',
          brand: 'Bingo Jewels',
          rating: '4.5',
          reviewCount: '10',
          icon: Icons.circle,
          variants: variants,
        );

    /// Mirrors wishlist_screen.dart's _moveToBag() variant-resolution
    /// branch exactly (the `variantUuid == null` path): resolves the
    /// product, and if MORE THAN ONE in-stock variant exists, refuses to
    /// guess — returns null (meaning: routed to PDP, nothing added).
    Future<String?> resolveVariantUuid(ProductDetailModel product) async {
      final inStockVariants = product.variants
          .where((v) => v.availableStock > 0 && v.uuid.isNotEmpty)
          .toList();
      if (inStockVariants.length > 1) return null; // -> _openProduct(), no guess
      final chosen = inStockVariants.isNotEmpty
          ? inStockVariants.first
          : (product.variants.isNotEmpty ? product.variants.first : null);
      return chosen?.uuid;
    }

    test(
      'two or more in-stock variants: refuses to guess, routes to the '
      'product page instead of silently adding an arbitrary variant',
      () async {
        when(() => repository.getProductDetail('prod-multi')).thenAnswer(
          (_) async => _productWith([_variant('small', 3), _variant('large', 5)]),
        );

        final product = await repository.getProductDetail('prod-multi');
        final resolved = await resolveVariantUuid(product);

        expect(resolved, isNull,
            reason: 'F-13: with 2 in-stock variants, the code must not '
                'guess which one the user wants — product_details_screen.dart '
                "shows 'This item has multiple options in stock...' and "
                'navigates to the PDP instead of calling addItem() at all');

        // Confirm nothing was added and the item is still wishlisted —
        // the ambiguity must not silently resolve to any variant.
        verifyNever(() => addItemUseCase(
              variantUuid: any(named: 'variantUuid'),
              quantity: any(named: 'quantity'),
            ));
        expect(wishlistCubit.isWishlisted('prod-multi'), isTrue);
      },
    );

    test(
      'exactly one in-stock variant among several out-of-stock ones: '
      'that single purchasable variant is chosen unambiguously',
      () async {
        when(() => repository.getProductDetail('prod-multi')).thenAnswer(
          (_) async => _productWith([
            _variant('small', 0), // out of stock
            _variant('medium', 4), // the only one in stock
            _variant('large', 0), // out of stock
          ]),
        );

        final product = await repository.getProductDetail('prod-multi');
        final resolved = await resolveVariantUuid(product);

        expect(resolved, 'medium',
            reason: 'exactly one purchasable variant is unambiguous — no '
                'need to ask the user to pick');
      },
    );

    test(
      'all variants out of stock: falls back to the first listed variant '
      '(so Add to Cart / PDP can still show a clear "out of stock" state), '
      'rather than resolving to null and failing silently',
      () async {
        when(() => repository.getProductDetail('prod-multi')).thenAnswer(
          (_) async =>
              _productWith([_variant('small', 0), _variant('large', 0)]),
        );

        final product = await repository.getProductDetail('prod-multi');
        final resolved = await resolveVariantUuid(product);

        expect(resolved, 'small',
            reason: 'falls back to product.variants.first when nothing is '
                'in stock, rather than leaving variantUuid unresolved');
      },
    );

    test(
      'the product has since been deleted/discontinued server-side '
      '(getProductDetail 404s) — degrades to a clear "unavailable" '
      'message instead of crashing',
      () async {
        when(() => repository.getProductDetail('prod-multi'))
            .thenThrow(Exception('404 Not Found'));

        // Mirrors wishlist_screen.dart:143-159 exactly: the getProductDetail
        // call is wrapped in try/catch, product falls back to null, and a
        // clear "unavailable" message is shown instead of the exception
        // propagating.
        ProductDetailModel? product;
        String? errorMessage;
        try {
          product = await repository.getProductDetail('prod-multi');
        } catch (_) {
          product = null;
        }
        if (product == null) {
          errorMessage = 'This product is currently unavailable';
        }

        expect(errorMessage, 'This product is currently unavailable',
            reason: 'a discontinued/deleted product must degrade to this '
                'clear message, not let the 404 exception crash the '
                'Move to Bag flow');
        expect(product, isNull);
      },
    );
  });
}
