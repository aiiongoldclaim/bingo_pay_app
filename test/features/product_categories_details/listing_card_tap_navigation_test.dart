import 'package:bingo_pay/features/product_categories_details/data/models/product_categories_model.dart';
import 'package:bingo_pay/features/product_categories_details/presentation/widgets/listing_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sizer/sizer.dart';

ListingProductModel _product(String uuid) => ListingProductModel(
      id: uuid,
      uuid: uuid,
      brand: 'Brand',
      name: 'Product $uuid',
      price: 100,
      icon: Icons.shopping_bag_outlined,
    );

void main() {
  testWidgets(
    'tapping a product card reports that card\'s own uuid, not the wrong '
    'index — each card in a list navigates to the correct product',
    (tester) async {
      final tappedUuids = <String>[];
      final products = [_product('uuid-a'), _product('uuid-b'), _product('uuid-c')];

      await tester.pumpWidget(
        Sizer(
          builder: (context, orientation, deviceType) => MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  for (final p in products)
                    SizedBox(
                      height: 200,
                      child: ListingProductCard(
                        key: Key(p.uuid!),
                        product: p,
                        onTap: () => tappedUuids.add(p.uuid!),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap the middle card first, then the first, to catch any bug where
      // taps are wired to the wrong (e.g. last-built) product.
      await tester.tap(find.byKey(const Key('uuid-b')));
      await tester.tap(find.byKey(const Key('uuid-a')));
      await tester.tap(find.byKey(const Key('uuid-c')));
      await tester.pumpAndSettle();

      expect(tappedUuids, ['uuid-b', 'uuid-a', 'uuid-c'],
          reason: 'each card must report exactly its own product uuid, in '
              'the order tapped');
    },
  );
}
