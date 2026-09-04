import 'package:bingo_pay/features/home/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads available stock from the first variant inventory', () {
    final product = ProductModel.fromJson({
      'uuid': 'product-1',
      'title': 'Example product',
      'variants': [
        {
          'uuid': 'variant-1',
          'salePrice': '20',
          'basePrice': '25',
          'inventory': {'availableStock': 3},
        },
      ],
    });

    expect(product.variantUuid, 'variant-1');
    expect(product.stock, 3);
  });

  test('keeps stock when restoring a flattened cached product', () {
    final product = ProductModel.fromJson({
      'uuid': 'product-1',
      'variantUuid': 'variant-1',
      'title': 'Example product',
      'stock': 0,
    });

    expect(product.variantUuid, 'variant-1');
    expect(product.stock, 0);
  });

  test('does not treat a missing inventory field as sold out', () {
    final product = ProductModel.fromJson({
      'uuid': 'product-1',
      'title': 'Example product',
      'variants': [
        {'uuid': 'variant-1', 'salePrice': '20'},
      ],
    });

    expect(product.stock, isNull);
  });
}
