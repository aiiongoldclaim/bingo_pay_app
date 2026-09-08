import 'package:bingo_pay/features/product_categories_details/data/models/product_categories_model.dart';
import 'package:bingo_pay/features/product_categories_details/data/services/product_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _product = ListingProductModel(
  id: 'p-1',
  uuid: 'p-1',
  brand: 'Bingo Jewels',
  name: 'Gold Necklace',
  price: 4500,
  icon: Icons.shopping_bag_outlined,
);

void main() {
  test(
    'F-08: a freshly-cached entry is not expired',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = ProductCacheService(prefs);

      await service.cacheProducts('cat-fresh', const [_product]);
      final cached = await service.getCachedProducts('cat-fresh');

      expect(cached, isNotNull);
      expect(cached!.isExpired, isFalse,
          reason: 'an entry cached moments ago must not be treated as '
              'stale');
    },
  );

  test(
    'F-08: an entry older than the 30-minute TTL is reported as expired — '
    'callers must not silently reuse stale price/stock/discount data',
    () async {
      final staleTimestamp = DateTime.now()
          .subtract(const Duration(minutes: 31))
          .millisecondsSinceEpoch;

      SharedPreferences.setMockInitialValues({
        'product_cache_cat-stale': [
          // Matches ListingProductModel.toJson()'s "_cached" shape.
          '{"_cached":true,"id":"p-1","uuid":"p-1","brand":"Bingo Jewels",'
              '"name":"Gold Necklace","price":4500.0,"originalPrice":null,'
              '"rating":null,"ratingCount":null,"badge":null,'
              '"imageUrl":null,"isFavourite":false}',
        ],
        'product_cache_cat-stale_timestamp': staleTimestamp,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = ProductCacheService(prefs);

      final cached = await service.getCachedProducts('cat-stale');

      expect(cached, isNotNull);
      expect(cached!.products, hasLength(1));
      expect(cached.isExpired, isTrue,
          reason: 'ProductCacheService.cacheTtl is 30 minutes — a 31-minute'
              '-old entry must be flagged expired, not reused indefinitely '
              'with only a cosmetic "cached Xh ago" label');
    },
  );

  test(
    'F-08: an entry just inside the TTL window is not expired (boundary '
    'check)',
    () async {
      final freshTimestamp = DateTime.now()
          .subtract(const Duration(minutes: 29))
          .millisecondsSinceEpoch;

      SharedPreferences.setMockInitialValues({
        'product_cache_cat-boundary': [
          '{"_cached":true,"id":"p-1","uuid":"p-1","brand":"Bingo Jewels",'
              '"name":"Gold Necklace","price":4500.0,"originalPrice":null,'
              '"rating":null,"ratingCount":null,"badge":null,'
              '"imageUrl":null,"isFavourite":false}',
        ],
        'product_cache_cat-boundary_timestamp': freshTimestamp,
      });
      final prefs = await SharedPreferences.getInstance();
      final service = ProductCacheService(prefs);

      final cached = await service.getCachedProducts('cat-boundary');

      expect(cached!.isExpired, isFalse);
    },
  );
}
