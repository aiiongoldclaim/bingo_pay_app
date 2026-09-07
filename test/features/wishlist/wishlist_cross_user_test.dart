import 'package:bingo_pay/features/wishlist/data/models/wishlist_model.dart';
import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test(
    'F-02: logging out User A and logging in as User B on the same device '
    '(same WishlistCubit instance, mirroring app.dart\'s single '
    'app-scoped _wishlistCubit) never shows or lets User B modify User '
    'A\'s wishlist',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      // A single shared cubit instance across the whole "session", exactly
      // as app.dart provisions one _wishlistCubit for the entire app.
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);

      // ── User A logs in and wishlists two products ──────────────────
      await cubit.loadForUser('user-A');
      await cubit.toggle(
        const WishlistItem(
          id: 'prod-1',
          brand: 'Bingo Jewels',
          name: 'Gold Necklace',
          price: '\$4,500',
        ),
        wasWishlisted: false,
      );
      await cubit.toggle(
        const WishlistItem(
          id: 'prod-2',
          brand: 'Bingo Jewels',
          name: 'Silver Chain',
          price: '\$1,200',
        ),
        wasWishlisted: false,
      );
      expect(cubit.state.items.length, 2);
      expect(cubit.isWishlisted('prod-1'), isTrue);

      // ── User A logs out — app.dart wires this to clearForLogout() ──
      cubit.clearForLogout();
      expect(cubit.state.items, isEmpty,
          reason: 'the in-memory state must be wiped immediately on '
              'logout, before any other user can log in');

      // ── User B logs in on the SAME device, SAME cubit instance ─────
      await cubit.loadForUser('user-B');

      expect(cubit.state.items, isEmpty,
          reason: "User B must not see User A's wishlisted products — "
              'storage is scoped per-user (wishlist_items_v2_<userId>), so '
              "loading User B's own (empty) key must not surface User A's "
              'items');
      expect(cubit.isWishlisted('prod-1'), isFalse,
          reason: "User A's product must not appear wishlisted for User B");

      // ── User B wishlists their own product ──────────────────────────
      await cubit.toggle(
        const WishlistItem(
          id: 'prod-3',
          brand: 'Bingo Jewels',
          name: 'Diamond Ring',
          price: '\$9,999',
        ),
        wasWishlisted: false,
      );
      expect(cubit.state.items.length, 1);
      expect(cubit.isWishlisted('prod-3'), isTrue);

      // ── User A's own stored data must be untouched by any of this ──
      final userAStillHasTheirs = WishlistCubit(prefs);
      addTearDown(userAStillHasTheirs.close);
      await userAStillHasTheirs.loadForUser('user-A');

      expect(userAStillHasTheirs.state.items.length, 2,
          reason: "User A's wishlist must be exactly as they left it — "
              "User B's session must not have overwritten or merged into "
              "User A's storage key");
      expect(userAStillHasTheirs.isWishlisted('prod-1'), isTrue);
      expect(userAStillHasTheirs.isWishlisted('prod-2'), isTrue);
      expect(userAStillHasTheirs.isWishlisted('prod-3'), isFalse,
          reason: "User B's product must not have leaked into User A's "
              'storage');
    },
  );

  test(
    'toggle()/remove() are no-ops while no user is scoped (the brief gap '
    'right after logout, before the next login resolves)',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);

      await cubit.loadForUser('user-A');
      await cubit.toggle(
        const WishlistItem(
          id: 'prod-1',
          brand: 'Bingo Jewels',
          name: 'Gold Necklace',
          price: '\$4,500',
        ),
        wasWishlisted: false,
      );
      cubit.clearForLogout();

      // No user scoped right now — a stray tap in this gap must not write
      // anywhere or crash.
      await cubit.toggle(
        const WishlistItem(
          id: 'prod-4',
          brand: 'Bingo Jewels',
          name: 'Stray Item',
          price: '\$1',
        ),
        wasWishlisted: false,
      );
      expect(cubit.state.items, isEmpty);

      await cubit.remove('prod-1');
      expect(cubit.state.items, isEmpty);
    },
  );
}
