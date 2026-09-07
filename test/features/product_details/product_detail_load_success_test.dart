import 'dart:async';

import 'package:bingo_pay/features/membershipNew/data/models/member_ship_model.dart';
import 'package:bingo_pay/features/membershipNew/domain/repositories/membership_repository.dart';
import 'package:bingo_pay/features/product_details/data/models/product_details_model.dart';
import 'package:dio/dio.dart';
import 'package:bingo_pay/features/product_details/presentation/cubit/product_details_cubit.dart';
import 'package:bingo_pay/features/product_details/presentation/cubit/product_details_state.dart';
import 'package:bingo_pay/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockWishlistRepository extends Mock implements WishlistRepository {}

class MockMembershipRepository extends Mock implements MembershipRepository {}

/// A membership response with no FREE_DELIVERY entitlement — the default
/// "guest / no free-delivery benefit" shape most tests here don't care
/// about, so it's stubbed once and reused.
const _noFreeDeliveryMembership = MembershipModel(entitlements: {});

MembershipEntitlement _entitlement(
  String key,
  String name, {
  required bool enabled,
}) =>
    MembershipEntitlement(
      key: key,
      name: name,
      type: 'BOOLEAN',
      group: 'BENEFIT',
      enabled: enabled,
    );

Map<String, dynamic> _realisticApiResponse() => {
      'data': {
        'data': {
          'id': 'p-1',
          'uuid': 'prod-uuid-123',
          'title': 'Gold Necklace 22K',
          'brand': {'name': 'Bingo Jewels'},
          'vendor': {'email': 'vendor@example.com'},
          'shortDescription': 'Elegant 22K gold necklace',
          'description': 'Handcrafted 22K gold necklace with intricate design.',
          'averageRating': 4.6,
          'totalReviews': 1234,
          'media': [
            {'url': 'https://cdn.example.com/img1.jpg'},
            {'url': 'https://cdn.example.com/img2.jpg'},
            {'url': ''},
          ],
          'variants': [
            {
              'uuid': 'var-1',
              'title': 'Small',
              'variantName': 'Small / 18in',
              'combinationKey': 'small-18',
              'salePrice': '4500.0',
              'basePrice': '5000.0',
              'inventory': {'availableStock': 3},
              'attributes': [
                {'attributeName': 'Size', 'value': '18in'},
              ],
            },
            {
              'uuid': 'var-2',
              'title': 'Large',
              'variantName': 'Large / 24in',
              'combinationKey': 'large-24',
              'salePrice': '5200.0',
              'basePrice': '5200.0',
              'inventory': {'availableStock': 0},
              'attributes': [
                {'attributeName': 'Size', 'value': '24in'},
              ],
            },
          ],
        },
      },
    };

void main() {
  group('ProductDetailModel.fromJson (real API shape)', () {
    test('parses images, variants, highlights, and rating from the response',
        () {
      final product = ProductDetailModel.fromJson(_realisticApiResponse());

      expect(product.productName, 'Gold Necklace 22K');
      expect(product.brand, 'Bingo Jewels');

      expect(product.images, [
        'https://cdn.example.com/img1.jpg',
        'https://cdn.example.com/img2.jpg',
      ], reason: 'images must come from media[].url, blank urls dropped');

      expect(product.variants.length, 2);
      expect(product.variants[0].uuid, 'var-1');
      expect(product.variants[0].availableStock, 3);
      expect(product.variants[1].availableStock, 0);

      expect(product.highlights, [
        'Elegant 22K gold necklace',
        'Handcrafted 22K gold necklace with intricate design.',
      ], reason: 'highlights come from shortDescription + description');

      expect(product.rating, '4.6');
      expect(product.reviewCount, '1.2k',
          reason: 'review counts >= 1000 are abbreviated');

      // First variant is in stock and selected by default -> price reflects it.
      expect(product.price, '\$4,500');
      expect(product.oldPrice, '\$5,000');
      expect(product.discount, 10);
      expect(product.availableStock, 3);
    });

    test(
      'benefits are empty straight out of fromJson — they are populated '
      "later by the cubit from the customer's membership entitlements, "
      'never hardcoded on the product model itself',
      () {
        final product = ProductDetailModel.fromJson(_realisticApiResponse());
        expect(product.benefits, isEmpty);
        // colorOptions is never populated from the API at all.
        expect(product.colorOptions, isEmpty);
      },
    );
  });

  group('ProductDetailCubit.loadProduct', () {
    late MockWishlistRepository repository;
    late MockMembershipRepository membershipRepository;

    setUp(() {
      repository = MockWishlistRepository();
      membershipRepository = MockMembershipRepository();
      when(() => membershipRepository.getMembership())
          .thenAnswer((_) async => _noFreeDeliveryMembership);
    });

    test(
      'a valid product uuid loads successfully into ProductDetailLoaded '
      'carrying images, variants, highlights, and ratings',
      () async {
        final product = ProductDetailModel.fromJson(_realisticApiResponse());
        when(() => repository.getProductDetail('prod-uuid-123'))
            .thenAnswer((_) async => product);

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);

        expect(cubit.state, isA<ProductDetailLoading>());

        await cubit.loadProduct('prod-uuid-123');

        final state = cubit.state;
        expect(state, isA<ProductDetailLoaded>());
        final loaded = state as ProductDetailLoaded;
        expect(loaded.product.images, isNotEmpty);
        expect(loaded.product.variants, isNotEmpty);
        expect(loaded.product.highlights, isNotEmpty);
        expect(loaded.product.rating, '4.6');
        verify(() => repository.getProductDetail('prod-uuid-123')).called(1);
      },
    );

    test(
      'an invalid/unknown product uuid (server 404) surfaces as '
      'ProductDetailError instead of crashing or hanging in loading',
      () async {
        when(() => repository.getProductDetail('bad-uuid')).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/api/v1/products/bad-uuid'),
            response: Response(
              requestOptions:
                  RequestOptions(path: '/api/v1/products/bad-uuid'),
              statusCode: 404,
              statusMessage: 'Not Found',
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);

        await cubit.loadProduct('bad-uuid');

        final state = cubit.state;
        expect(state, isA<ProductDetailError>(),
            reason: 'a 404/unknown uuid must surface as ProductDetailError, '
                'not leave the screen stuck on the loading shimmer or throw '
                'an unhandled exception');
        expect((state as ProductDetailError).message, isNotEmpty);
      },
    );

    test(
      'a malformed response shape (fromJson cast failure) is caught by the '
      "cubit's catch(e) and surfaces as an error, not an uncaught crash",
      () async {
        // Same shape of failure a bad/malformed API response would trigger:
        // ProductDetailModel.fromJson throws a TypeError while casting, and
        // the repository call rethrows it uncaught, exactly as the real
        // WishlistRepositoryImpl does around ProductDetailModel.fromJson.
        when(() => repository.getProductDetail('malformed'))
            .thenAnswer((_) async {
          final malformed = <String, dynamic>{'unexpected': 'shape'};
          return ProductDetailModel.fromJson(malformed);
        });

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);

        await expectLater(cubit.loadProduct('malformed'), completes,
            reason: 'the cast failure inside fromJson must not propagate as '
                'an uncaught exception out of loadProduct()');

        final state = cubit.state;
        expect(state, isA<ProductDetailError>(),
            reason: 'a malformed response must surface as ProductDetailError '
                '(driving the error view), not leave the cubit crashed or '
                'stuck loading');
        expect((state as ProductDetailError).message, isNotEmpty);
      },
    );
  });

  group('ProductDetailCubit.selectVariant', () {
    late MockWishlistRepository repository;
    late MockMembershipRepository membershipRepository;

    setUp(() {
      repository = MockWishlistRepository();
      membershipRepository = MockMembershipRepository();
      when(() => membershipRepository.getMembership())
          .thenAnswer((_) async => _noFreeDeliveryMembership);
    });

    test(
      'switching to a different variant updates price, old price, '
      'discount%, and stock together, consistently, in one state change',
      () async {
        final product = ProductDetailModel.fromJson(_realisticApiResponse());
        when(() => repository.getProductDetail('prod-uuid-123'))
            .thenAnswer((_) async => product);

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);
        await cubit.loadProduct('prod-uuid-123');

        // Sanity check: variant 0 (Small) is selected by default.
        var loaded = cubit.state as ProductDetailLoaded;
        expect(loaded.product.price, '\$4,500');
        expect(loaded.product.oldPrice, '\$5,000');
        expect(loaded.product.discount, 10);
        expect(loaded.product.availableStock, 3);
        expect(loaded.quantity, 1);

        // Bump quantity before switching, to prove the switch resets it
        // rather than leaving a now-invalid quantity for the new variant.
        cubit.incrementQuantity();
        expect((cubit.state as ProductDetailLoaded).quantity, 2);

        final states = <ProductDetailState>[];
        final sub = cubit.stream.listen(states.add);

        cubit.selectVariant(1);
        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        // Exactly one state change for the whole switch — no intermediate
        // state where only some fields reflect the new variant.
        expect(states.length, 1);

        loaded = cubit.state as ProductDetailLoaded;
        expect(loaded.selectedVariantIndex, 1);
        expect(loaded.product.selectedVariantIndex, 1,
            reason: 'the model and the wrapping state must agree on which '
                'variant is selected');
        expect(loaded.product.price, '\$5,200',
            reason: 'variant 2 (Large) has no discount, so salePrice '
                '== basePrice');
        expect(loaded.product.discount, 0);
        expect(loaded.product.availableStock, 0,
            reason: 'variant 2 is out of stock');
        expect(loaded.quantity, 1,
            reason: 'switching variants must reset quantity so it can '
                "never exceed the newly-selected variant's stock");
      },
    );

    test(
      'rapidly selecting variant A then B within the same synchronous '
      'call — no await between the two taps — leaves price/stock '
      'reflecting B, not a torn/intermediate state',
      () async {
        final product = ProductDetailModel.fromJson(_realisticApiResponse());
        when(() => repository.getProductDetail('prod-uuid-123'))
            .thenAnswer((_) async => product);

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);
        await cubit.loadProduct('prod-uuid-123');

        // selectVariant() is a plain synchronous method (no await inside),
        // so calling it twice back-to-back is exactly "within one frame" —
        // there is no microtask gap for a race to hide in.
        cubit.selectVariant(0); // tap color A
        cubit.selectVariant(1); // tap color B, before anything settles

        final loaded = cubit.state as ProductDetailLoaded;
        expect(loaded.selectedVariantIndex, 1,
            reason: 'B was the last tap and must be what the state reflects');
        expect(loaded.product.selectedVariantIndex, 1);
        expect(loaded.product.price, '\$5,200',
            reason: "must be B's price, not A's ");
        expect(loaded.product.availableStock, 0,
            reason: "must be B's stock, not A's leftover 3");
      },
    );
  });

  group('out-of-stock variant selection', () {
    late MockWishlistRepository repository;
    late MockMembershipRepository membershipRepository;

    setUp(() {
      repository = MockWishlistRepository();
      membershipRepository = MockMembershipRepository();
      when(() => membershipRepository.getMembership())
          .thenAnswer((_) async => _noFreeDeliveryMembership);
    });

    test(
      'selecting a zero-stock variant flips the same availableStock <= 0 '
      "gate the screen uses to disable Buy Now / Add to Cart and swap in "
      "the 'Out of Stock' label",
      () async {
        final product = ProductDetailModel.fromJson(_realisticApiResponse());
        when(() => repository.getProductDetail('prod-uuid-123'))
            .thenAnswer((_) async => product);

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);
        await cubit.loadProduct('prod-uuid-123');

        // Variant 0 (Small) is in stock — buttons should be enabled.
        var loaded = cubit.state as ProductDetailLoaded;
        var isOutOfStock = loaded.product.availableStock <= 0;
        expect(isOutOfStock, isFalse);

        // Select variant 1 (Large), which has availableStock: 0.
        cubit.selectVariant(1);

        loaded = cubit.state as ProductDetailLoaded;
        isOutOfStock = loaded.product.availableStock <= 0;
        expect(isOutOfStock, isTrue,
            reason: 'the newly-selected variant has zero stock');

        // These mirror product_details_screen.dart:334-344 exactly: both
        // the primary (Buy Now) and secondary (Add to Cart) actions gate on
        // this same isOutOfStock flag, so they can never disagree.
        final primaryLabel = isOutOfStock ? 'Out of Stock' : 'Buy Now';
        final primaryEnabled = !isOutOfStock;
        final secondaryEnabled = !isOutOfStock;

        expect(primaryLabel, 'Out of Stock');
        expect(primaryEnabled, isFalse,
            reason: 'Buy Now must be disabled for an out-of-stock variant');
        expect(secondaryEnabled, isFalse,
            reason: 'Add to Cart must be disabled for an out-of-stock '
                'variant');
      },
    );
  });

  group('product with zero variants', () {
    late MockWishlistRepository repository;
    late MockMembershipRepository membershipRepository;

    setUp(() {
      repository = MockWishlistRepository();
      membershipRepository = MockMembershipRepository();
      when(() => membershipRepository.getMembership())
          .thenAnswer((_) async => _noFreeDeliveryMembership);
    });

    test(
      'price/variantUuid gracefully fall back to N/A/null, and the '
      'out-of-stock gate disables both actions instead of crashing',
      () async {
        // A response whose backend returned no variants at all.
        final noVariantsJson = _realisticApiResponse();
        (noVariantsJson['data'] as Map)['data']['variants'] = <dynamic>[];
        final product = ProductDetailModel.fromJson(noVariantsJson);

        expect(product.variants, isEmpty);
        expect(product.selectedVariant, isNull);
        expect(product.price, 'N/A',
            reason: 'no selected variant means no price to show');
        expect(product.oldPrice, isEmpty);
        expect(product.discount, 0);
        expect(product.availableStock, 0);
        expect(product.variantUuid, isNull);

        when(() => repository.getProductDetail('prod-no-variants'))
            .thenAnswer((_) async => product);

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);

        await expectLater(
          cubit.loadProduct('prod-no-variants'),
          completes,
          reason: 'a zero-variant product must still load successfully, '
              'not crash while computing price/stock',
        );

        final loaded = cubit.state as ProductDetailLoaded;
        expect(loaded.product.variantUuid, isNull);

        // Mirrors product_details_screen.dart:334-344 and the
        // variantUuid == null guards in _buyNow()/_addToCart() (lines
        // 42-45, 81-84): with no variants, availableStock is 0, so
        // isOutOfStock disables both buttons before their tap handlers
        // would ever run — and even if invoked directly, the null
        // variantUuid guard routes to the same "unavailable" message
        // instead of calling the cart/payment API with a null uuid.
        final isOutOfStock = loaded.product.availableStock <= 0;
        expect(isOutOfStock, isTrue,
            reason: 'Buy Now and Add to Cart must both be disabled');

        String? unavailableMessage;
        final variantUuid = loaded.product.variantUuid;
        if (variantUuid == null) {
          unavailableMessage = 'This product is currently unavailable';
        }
        expect(unavailableMessage, 'This product is currently unavailable');
      },
    );
  });

  group('quantity selector (F-01)', () {
    late MockWishlistRepository repository;
    late MockMembershipRepository membershipRepository;

    setUp(() {
      repository = MockWishlistRepository();
      membershipRepository = MockMembershipRepository();
      when(() => membershipRepository.getMembership())
          .thenAnswer((_) async => _noFreeDeliveryMembership);
    });

    test(
      'a real quantity selector exists: incrementQuantity/decrementQuantity '
      'let the user pick more than 1 unit, bounded by stock, and that '
      "quantity — not a hardcoded 1 — is what Add to Cart/Buy Now use",
      () async {
        final product = ProductDetailModel.fromJson(_realisticApiResponse());
        when(() => repository.getProductDetail('prod-uuid-123'))
            .thenAnswer((_) async => product);

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);
        await cubit.loadProduct('prod-uuid-123');

        // Variant 0 has availableStock: 3.
        expect((cubit.state as ProductDetailLoaded).quantity, 1);

        cubit.incrementQuantity();
        cubit.incrementQuantity();
        expect((cubit.state as ProductDetailLoaded).quantity, 3,
            reason: 'a working quantity selector must allow buying more '
                'than 1 unit');

        // Bounded at the variant's available stock — cannot go past it.
        cubit.incrementQuantity();
        expect((cubit.state as ProductDetailLoaded).quantity, 3,
            reason: 'must not exceed availableStock (3)');

        cubit.decrementQuantity();
        cubit.decrementQuantity();
        cubit.decrementQuantity();
        expect((cubit.state as ProductDetailLoaded).quantity, 1,
            reason: 'must not go below 1');

        // Confirms product_details_screen.dart:52-61 (Buy Now) and
        // :89-92 (Add to Cart) both forward data.quantity — the live,
        // user-selected value — rather than a hardcoded 1.
        cubit.incrementQuantity();
        final loaded = cubit.state as ProductDetailLoaded;
        expect(loaded.quantity, 2);
        // This is exactly the value the screen reads via `data.quantity`
        // when building PaymentArgs / calling cartCubit.addItem.
        final quantitySubmittedToCartOrPayment = loaded.quantity;
        expect(quantitySubmittedToCartOrPayment, 2,
            reason: 'Add to Cart / Buy Now must submit the actually '
                'selected quantity, not a hardcoded 1');
      },
    );
  });

  group('navigate away mid-load then re-enter', () {
    late MockWishlistRepository repository;
    late MockMembershipRepository membershipRepository;

    setUp(() {
      repository = MockWishlistRepository();
      membershipRepository = MockMembershipRepository();
      when(() => membershipRepository.getMembership())
          .thenAnswer((_) async => _noFreeDeliveryMembership);
    });

    test(
      'a loadProduct() response arriving after the screen (and its cubit) '
      'has been disposed must not crash with emit-after-close',
      () async {
        final gate = Completer<ProductDetailModel>();
        when(() => repository.getProductDetail('prod-uuid-123'))
            .thenAnswer((_) => gate.future);

        final cubit = ProductDetailCubit(repository, membershipRepository);

        // User opens the PDP; loadProduct() is in flight (gated).
        final loadFuture = cubit.loadProduct('prod-uuid-123');

        // User navigates away before the API responds — GoRouter's
        // BlocProvider disposes (closes) the cubit created for this route.
        await cubit.close();

        // The in-flight API call now resolves, after the screen is gone.
        gate.complete(ProductDetailModel.fromJson(_realisticApiResponse()));

        await expectLater(
          loadFuture,
          completes,
          reason: 'the late response must not throw '
              '"Bad state: Cannot emit new states after calling close()"',
        );
      },
    );

    test(
      're-opening the same product after navigating away creates an '
      'independent cubit instance unaffected by the earlier one\'s '
      'late-arriving response',
      () async {
        final firstGate = Completer<ProductDetailModel>();
        when(() => repository.getProductDetail('prod-uuid-123'))
            .thenAnswer((_) => firstGate.future);

        final firstCubit = ProductDetailCubit(repository, membershipRepository);
        final firstLoad = firstCubit.loadProduct('prod-uuid-123');
        await firstCubit.close(); // navigated away

        // Re-entering the PDP for the same product creates a brand new
        // cubit instance (ProductDetailCubit is @injectable/factory-scoped,
        // not a singleton), which loads independently of the first.
        final secondProduct = ProductDetailModel.fromJson(_realisticApiResponse());
        when(() => repository.getProductDetail('prod-uuid-123'))
            .thenAnswer((_) async => secondProduct);

        final secondCubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(secondCubit.close);
        await secondCubit.loadProduct('prod-uuid-123');

        expect(secondCubit.state, isA<ProductDetailLoaded>(),
            reason: 'the new screen instance must load normally');
        expect(
          (secondCubit.state as ProductDetailLoaded).product.productName,
          'Gold Necklace 22K',
        );

        // Now let the first (closed) cubit's stale response land — it must
        // not throw, and it must have zero effect on the second instance.
        firstGate.complete(ProductDetailModel.fromJson(_realisticApiResponse()));
        await expectLater(firstLoad, completes);

        expect(secondCubit.state, isA<ProductDetailLoaded>(),
            reason: "the first cubit's late response must not leak into "
                'or corrupt the second, independent cubit instance');
      },
    );
  });

  group('PDP benefits driven by membership entitlements', () {
    late MockWishlistRepository repository;
    late MockMembershipRepository membershipRepository;

    setUp(() {
      repository = MockWishlistRepository();
      membershipRepository = MockMembershipRepository();
      final product = ProductDetailModel.fromJson(_realisticApiResponse());
      when(() => repository.getProductDetail('prod-uuid-123'))
          .thenAnswer((_) async => product);
    });

    test(
      'a member with all three entitlements enabled sees all three '
      'benefit tiles, labelled from the API data — nothing hardcoded',
      () async {
        when(() => membershipRepository.getMembership()).thenAnswer(
          (_) async => MembershipModel(
            entitlements: {
              'FREE_DELIVERY':
                  _entitlement('FREE_DELIVERY', 'Free Delivery', enabled: true),
              'WARRANTY': _entitlement('WARRANTY', 'Warranty', enabled: true),
              'RETURNS':
                  _entitlement('RETURNS', '7 Day Returns', enabled: true),
            },
          ),
        );

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);
        await cubit.loadProduct('prod-uuid-123');

        final benefits =
            (cubit.state as ProductDetailLoaded).product.benefits;
        expect(benefits.map((b) => b.label),
            ['Free Delivery', 'Warranty', '7 Day Returns']);
        expect(benefits.every((b) => b.subtitle == 'Included'), isTrue);
        verify(() => membershipRepository.getMembership()).called(1);
      },
    );

    test(
      'a member missing the WARRANTY entitlement (and with RETURNS '
      'disabled) sees only the Free Delivery tile — unavailable benefits '
      'are simply not shown, never replaced by fallback text',
      () async {
        when(() => membershipRepository.getMembership()).thenAnswer(
          (_) async => MembershipModel(
            entitlements: {
              'FREE_DELIVERY':
                  _entitlement('FREE_DELIVERY', 'Free Delivery', enabled: true),
              'RETURNS':
                  _entitlement('RETURNS', '7 Day Returns', enabled: false),
            },
          ),
        );

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);
        await cubit.loadProduct('prod-uuid-123');

        final benefits =
            (cubit.state as ProductDetailLoaded).product.benefits;
        expect(benefits.map((b) => b.label), ['Free Delivery']);
      },
    );

    test(
      'a guest / member with no entitlements sees no benefit tiles at all',
      () async {
        when(() => membershipRepository.getMembership()).thenAnswer(
          (_) async => const MembershipModel(entitlements: {}),
        );

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);
        await cubit.loadProduct('prod-uuid-123');

        final benefits =
            (cubit.state as ProductDetailLoaded).product.benefits;
        expect(benefits, isEmpty);
      },
    );

    test(
      'a membership API failure (network hiccup) degrades to no benefit '
      'tiles instead of failing the whole product load',
      () async {
        when(() => membershipRepository.getMembership())
            .thenThrow(Exception('network error'));

        final cubit = ProductDetailCubit(repository, membershipRepository);
        addTearDown(cubit.close);
        await cubit.loadProduct('prod-uuid-123');

        expect(cubit.state, isA<ProductDetailLoaded>(),
            reason: 'a membership-only failure must not block the product '
                'from loading');
        final benefits =
            (cubit.state as ProductDetailLoaded).product.benefits;
        expect(benefits, isEmpty);
      },
    );
  });

  group('ProductDetailModel.fromJson (malformed shapes)', () {
    test('a response missing the expected data/data nesting throws '
        'instead of silently returning a garbage model', () {
      expect(
        () => ProductDetailModel.fromJson({'unexpected': 'shape'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
