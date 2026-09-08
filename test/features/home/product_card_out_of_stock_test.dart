import 'package:bingo_pay/features/home/data/models/product_model.dart';
import 'package:bingo_pay/features/home/presentation/widgets/home_metrics.dart';
import 'package:bingo_pay/features/home/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ProductModel _product({int? stock}) => ProductModel(
      uuid: 'p-1',
      variantUuid: 'v-1',
      brand: 'Bingo Jewels',
      name: 'Gold Necklace',
      price: '\$4,500',
      oldPrice: '',
      rating: '4.6',
      discount: 0,
      // Distinct from the add-to-cart button's icon so find.byIcon() below
      // can't ambiguously match this placeholder too.
      icon: Icons.diamond_outlined,
      images: const [],
      stock: stock,
    );

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => child,
        ),
      ),
    );

void main() {
  testWidgets(
    'F-03: a sold-out product (stock == 0) on the Dashboard rail shows an '
    'Out of Stock badge and a disabled add-to-cart button, not a fully '
    'purchasable card',
    (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ProductCard(
              metrics: HomeMetrics.of(context),
              product: _product(stock: 0),
              isOutOfStock: true,
              onAddToCart: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Out of Stock'), findsOneWidget,
          reason: 'a sold-out product must show a client-side warning, not '
              'render as fully purchasable');

      await tester.tap(find.byIcon(Icons.remove_shopping_cart_outlined));
      await tester.pumpAndSettle();

      expect(tapped, isFalse,
          reason: 'the add-to-cart action must be disabled for an '
              'out-of-stock product');
    },
  );

  testWidgets(
    'an in-stock product renders normally with a working add-to-cart button',
    (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          Builder(
            builder: (context) => ProductCard(
              metrics: HomeMetrics.of(context),
              product: _product(stock: 5),
              isOutOfStock: false,
              onAddToCart: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Out of Stock'), findsNothing);

      await tester.tap(find.byIcon(Icons.shopping_bag_outlined));
      await tester.pumpAndSettle();

      expect(tapped, isTrue,
          reason: 'an in-stock product must still be addable to cart');
    },
  );
}
