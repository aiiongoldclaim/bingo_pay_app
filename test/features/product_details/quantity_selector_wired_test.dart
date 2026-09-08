import 'package:bingo_pay/features/cart/domain/usecases/add_cart_item_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:bingo_pay/features/cart/domain/usecases/update_cart_item_quantity_usecase.dart';
import 'package:bingo_pay/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:bingo_pay/features/membershipNew/data/models/member_ship_model.dart';
import 'package:bingo_pay/features/membershipNew/domain/repositories/membership_repository.dart';
import 'package:bingo_pay/features/product_details/data/models/product_details_model.dart';
import 'package:bingo_pay/features/product_details/presentation/cubit/product_details_cubit.dart';
import 'package:bingo_pay/features/product_details/presentation/cubit/product_details_state.dart';
import 'package:bingo_pay/features/product_details/presentation/screens/product_details_screen.dart';
import 'package:bingo_pay/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class MockWishlistRepository extends Mock implements WishlistRepository {}

class MockMembershipRepository extends Mock implements MembershipRepository {}

class MockGetCartUseCase extends Mock implements GetCartUseCase {}

class MockAddCartItemUseCase extends Mock implements AddCartItemUseCase {}

class MockUpdateCartItemQuantityUseCase extends Mock
    implements UpdateCartItemQuantityUseCase {}

class MockRemoveCartItemUseCase extends Mock implements RemoveCartItemUseCase {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

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
          availableStock: 5,
          attributes: const [],
        ),
      ],
    );

Widget _wrap({
  required ProductDetailCubit productDetailCubit,
  required CartCubit cartCubit,
  required WishlistCubit wishlistCubit,
}) =>
    Sizer(
      builder: (context, orientation, deviceType) => MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductDetailCubit>.value(value: productDetailCubit),
            BlocProvider<CartCubit>.value(value: cartCubit),
            BlocProvider<WishlistCubit>.value(value: wishlistCubit),
          ],
          child: const ProductDetailScreen(),
        ),
      ),
    );

void main() {
  late MockWishlistRepository wishlistRepository;
  late MockMembershipRepository membershipRepository;
  late ProductDetailCubit productDetailCubit;
  late CartCubit cartCubit;
  late WishlistCubit wishlistCubit;

  setUp(() async {
    wishlistRepository = MockWishlistRepository();
    membershipRepository = MockMembershipRepository();
    when(() => wishlistRepository.getProductDetail('prod-uuid-123'))
        .thenAnswer((_) async => _product());
    when(() => membershipRepository.getMembership())
        .thenAnswer((_) async => const MembershipModel(entitlements: {}));

    productDetailCubit =
        ProductDetailCubit(wishlistRepository, membershipRepository);

    cartCubit = CartCubit(
      MockGetCartUseCase(),
      MockAddCartItemUseCase(),
      MockUpdateCartItemQuantityUseCase(),
      MockRemoveCartItemUseCase(),
      MockClearCartUseCase(),
    );

    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    wishlistCubit = WishlistCubit(prefs);
    await wishlistCubit.loadForUser('user-1');
  });

  tearDown(() {
    productDetailCubit.close();
    cartCubit.close();
    wishlistCubit.close();
  });

  testWidgets(
    'F-01: the PDP quantity stepper actually renders on screen and lets the '
    'user pick more than 1 unit — not orphaned/unwired dead code',
    (tester) async {
      // A realistic phone viewport — the default test surface is wider
      // than it is tall, which flips ProductMetrics.isLandscape and
      // unrelatedly overflows layout that isn't what this test is about.
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await productDetailCubit.loadProduct('prod-uuid-123');

      await tester.pumpWidget(
        _wrap(
          productDetailCubit: productDetailCubit,
          cartCubit: cartCubit,
          wishlistCubit: wishlistCubit,
        ),
      );
      await tester.pumpAndSettle();

      // The stepper must actually be in the rendered tree.
      expect(
        find.byKey(const Key('product_quantity_increment')),
        findsOneWidget,
        reason: 'F-01: ProductQuantitySelector must be instantiated on the '
            'PDP, not just defined and orphaned',
      );
      expect(find.text('1'), findsOneWidget,
          reason: 'starts at quantity 1');

      // Tapping + must actually change the displayed/selected quantity.
      // The stepper sits inside a scrollable column, so scroll it into
      // view first — otherwise the tap's target offset can land outside
      // the viewport entirely.
      await tester.ensureVisible(
        find.byKey(const Key('product_quantity_increment')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('product_quantity_increment')));
      await tester.pumpAndSettle();

      expect(find.text('2'), findsOneWidget,
          reason: 'a real, wired stepper must let the user go past 1');
      expect(productDetailCubit.state, isA<ProductDetailLoaded>());
      expect(
        (productDetailCubit.state as ProductDetailLoaded).quantity,
        2,
        reason: 'the tap must reach ProductDetailCubit.incrementQuantity(), '
            'the exact value Buy Now/Add to Cart submit',
      );
    },
  );
}
