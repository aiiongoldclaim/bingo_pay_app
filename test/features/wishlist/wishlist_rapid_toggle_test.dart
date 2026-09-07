import 'dart:convert';

import 'package:bingo_pay/features/wishlist/data/models/wishlist_model.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'wishlist_items_v2_user-1';

const _item = WishlistItem(
  id: 'prod-1',
  brand: 'Bingo Jewels',
  name: 'Gold Necklace',
  price: '\$4,500',
);

void main() {
  test(
    'rapid add/remove/add heart taps (no await between them, each with the '
    'correct intent) leave both the in-memory state and the persisted disk '
    'value matching the LAST tap',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);
      await cubit.loadForUser('user-1');

      // Three rapid taps fired back-to-back, none awaited individually —
      // toggle() emits synchronously before persisting specifically so a
      // rapid next tap reads the just-updated state.items rather than a
      // stale snapshot. Each call passes the intent the tapping screen
      // actually observed (add, then remove, then add again).
      final tap1 = cubit.toggle(_item, wasWishlisted: false); // add
      final tap2 = cubit.toggle(_item, wasWishlisted: true); // remove
      final tap3 = cubit.toggle(_item, wasWishlisted: false); // add

      await Future.wait([tap1, tap2, tap3]);

      expect(cubit.isWishlisted('prod-1'), isTrue,
          reason: 'add -> remove -> add nets to wishlisted; the in-memory '
              'state must match the LAST tap, not get lost mid-sequence');

      // Read back what actually landed on "disk" (the mock
      // SharedPreferences store) — this must match the same final state,
      // not some intermediate (removed) value from an earlier, superseded
      // write in the coalescing queue.
      final persistedRaw = prefs.getString(_storageKey);
      expect(persistedRaw, isNotNull,
          reason: 'at least the final state must have been written');
      final persistedItems = jsonDecode(persistedRaw!) as List;
      expect(persistedItems, hasLength(1),
          reason: 'the persisted value on disk must reflect the final '
              '(wishlisted) state — not a stale write from the '
              'intermediate "removed" tap that got superseded before it '
              'could flush');
      expect((persistedItems.first as Map)['id'], 'prod-1');
    },
  );

  test(
    'FIXED: tapping the heart on Dashboard, then quickly on the Listing '
    'card for the SAME not-yet-wishlisted product, stays added instead of '
    'flipping back OFF',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      // One shared WishlistCubit instance app-wide (BlocProvider.value in
      // app.dart), exactly like both the Dashboard and Listing screens
      // would be reading/writing through.
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);
      await cubit.loadForUser('user-1');

      expect(cubit.isWishlisted('prod-1'), isFalse,
          reason: 'precondition: not yet wishlisted');

      // User taps the heart on the Dashboard card. At the instant of this
      // tap, the Listing card (showing the same product elsewhere) still
      // renders an unfilled heart too, since it hasn't rebuilt yet — both
      // screens observed and pass wasWishlisted: false.
      await cubit.toggle(_item, wasWishlisted: false);
      expect(cubit.isWishlisted('prod-1'), isTrue,
          reason: 'Dashboard tap added it');

      // User, seeing the (not-yet-updated) unfilled heart on the Listing
      // card, taps it too, with the same observed intent: "add".
      await cubit.toggle(_item, wasWishlisted: false);

      expect(
        cubit.isWishlisted('prod-1'),
        isTrue,
        reason: 'FIXED: toggle() now honors the caller\'s observed intent '
            '(wasWishlisted) rather than blindly flipping whatever the '
            'shared state currently holds — a second "add" tap for an '
            'item already added by the first is a no-op, not a removal.',
      );

      // And the persisted disk state agrees.
      final persistedRaw = prefs.getString(_storageKey);
      final persistedItems = jsonDecode(persistedRaw!) as List;
      expect(persistedItems, hasLength(1));
    },
  );

  test(
    'a superseded (stale) persist write never overwrites a later one — '
    'the write queue coalesces to whichever toggle happened last, even '
    'with genuinely alternating intents',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);
      await cubit.loadForUser('user-1');

      // Four rapid, genuinely-alternating taps: add, remove, add, remove —
      // nets to NOT wishlisted.
      final futures = [
        cubit.toggle(_item, wasWishlisted: false), // add
        cubit.toggle(_item, wasWishlisted: true), // remove
        cubit.toggle(_item, wasWishlisted: false), // add
        cubit.toggle(_item, wasWishlisted: true), // remove
      ];
      await Future.wait(futures);

      expect(cubit.isWishlisted('prod-1'), isFalse);

      final persistedRaw = prefs.getString(_storageKey);
      final persistedItems =
          persistedRaw == null ? [] : jsonDecode(persistedRaw) as List;
      expect(persistedItems, isEmpty,
          reason: 'the disk value must match the final (not-wishlisted) '
              'state — no earlier "add" write must have landed after the '
              'final "remove"');
    },
  );
}
