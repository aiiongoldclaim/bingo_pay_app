import 'dart:convert';

import 'package:bingo_pay/features/wishlist/data/models/wishlist_model.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'wishlist_items_v2_user-1';

void main() {
  test(
    'confirming "Clear All" removes every wishlisted item, and the '
    'emptied state is persisted to disk, not just cleared in memory',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);
      await cubit.loadForUser('user-1');

      const item1 = WishlistItem(
        id: 'prod-1',
        brand: 'Bingo Jewels',
        name: 'Gold Necklace',
        price: '\$4,500',
      );
      const item2 = WishlistItem(
        id: 'prod-2',
        brand: 'Bingo Jewels',
        name: 'Silver Chain',
        price: '\$1,200',
      );
      const item3 = WishlistItem(
        id: 'prod-3',
        brand: 'Bingo Jewels',
        name: 'Diamond Ring',
        price: '\$9,999',
      );
      await cubit.toggle(item1, wasWishlisted: false);
      await cubit.toggle(item2, wasWishlisted: false);
      await cubit.toggle(item3, wasWishlisted: false);
      expect(cubit.state.items.length, 3);

      // Mirrors wishlist_screen.dart's _confirmClearAll() exactly (lines
      // 217, 245-247): a snapshot of the current items, then a sequential
      // remove() per item.
      final itemsSnapshot = List<WishlistItem>.from(cubit.state.items);
      for (final item in itemsSnapshot) {
        await cubit.remove(item.id);
      }

      expect(cubit.state.items, isEmpty,
          reason: 'all items must be gone from in-memory state');
      expect(cubit.isWishlisted('prod-1'), isFalse);
      expect(cubit.isWishlisted('prod-2'), isFalse);
      expect(cubit.isWishlisted('prod-3'), isFalse);

      // The emptied state must be what's on disk too — not stuck holding
      // an earlier, non-empty snapshot.
      final persistedRaw = prefs.getString(_storageKey);
      final persistedItems =
          persistedRaw == null ? <dynamic>[] : jsonDecode(persistedRaw) as List;
      expect(persistedItems, isEmpty,
          reason: 'clearing all items must persist an empty list to disk, '
              'not leave a stale non-empty value behind');

      // A fresh session (app restart) must also see an empty wishlist.
      final afterRestart = WishlistCubit(prefs);
      addTearDown(afterRestart.close);
      await afterRestart.loadForUser('user-1');
      expect(afterRestart.state.items, isEmpty);
    },
  );
}
