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

  group('listingLevel / vault-tier flags', () {
    test('defaults to NORMAL — neither Vaults Luxe nor Ultra Luxe — when the '
        'API omits listingLevel', () {
      final product = ProductModel.fromJson({
        'uuid': 'product-1',
        'title': 'Example product',
      });

      expect(product.listingLevel, 'NORMAL');
      expect(product.isVaultsLuxe, isFalse);
      expect(product.isUltraLuxe, isFalse);
    });

    test('a "LUXE" listingLevel is Vaults Luxe but not Ultra Luxe', () {
      final product = ProductModel.fromJson({
        'uuid': 'product-1',
        'title': 'Example product',
        'listingLevel': 'LUXE',
      });

      expect(product.isVaultsLuxe, isTrue);
      expect(product.isUltraLuxe, isFalse);
    });

    test('an "ULTRA_LUXE" listingLevel is Ultra Luxe, not plain Vaults Luxe', () {
      final product = ProductModel.fromJson({
        'uuid': 'product-1',
        'title': 'Example product',
        'listingLevel': 'ULTRA_LUXE',
      });

      expect(product.isUltraLuxe, isTrue);
      expect(
        product.isVaultsLuxe,
        isFalse,
        reason: 'an Ultra Luxe product should not also count toward the '
            'plain Vaults Luxe tier',
      );
    });

    test('round-trips through the cache (toJson/fromJson) without losing '
        'listingLevel', () {
      final original = ProductModel.fromJson({
        'uuid': 'product-1',
        'title': 'Example product',
        'listingLevel': 'ULTRA_LUXE',
      });

      final restored = ProductModel.fromJson(original.toJson());

      expect(restored.listingLevel, 'ULTRA_LUXE');
      expect(restored.isUltraLuxe, isTrue);
    });
  });
}
