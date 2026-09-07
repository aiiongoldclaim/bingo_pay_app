import 'package:bingo_pay/features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _storageKey = 'wishlist_items_v2_user-1';

void main() {
  test(
    'malformed JSON in the stored wishlist value is caught by loadForUser() '
    "— the app starts with an empty wishlist instead of crashing on launch",
    () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: '{not valid json at all]]]',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);

      await expectLater(
        cubit.loadForUser('user-1'),
        completes,
        reason: 'a JSON decode failure must not throw an uncaught '
            'exception during app launch',
      );

      expect(cubit.state.items, isEmpty,
          reason: 'corrupted storage must fall back to an empty wishlist, '
              'not a half-parsed or garbage list');
    },
  );

  test(
    'valid JSON that is the wrong shape (a Map instead of a List) is also '
    'caught, not just outright malformed syntax',
    () async {
      SharedPreferences.setMockInitialValues({
        _storageKey: '{"unexpected": "shape"}',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);

      await expectLater(cubit.loadForUser('user-1'), completes);
      expect(cubit.state.items, isEmpty);
    },
  );

  test(
    'a JSON array whose entries are missing required fields is caught too',
    () async {
      SharedPreferences.setMockInitialValues({
        // Each WishlistItem requires id/brand/name/price — this entry has
        // none of them.
        _storageKey: '[{"unexpected": "entry"}]',
      });
      final prefs = await SharedPreferences.getInstance();
      final cubit = WishlistCubit(prefs);
      addTearDown(cubit.close);

      await expectLater(cubit.loadForUser('user-1'), completes);
      expect(cubit.state.items, isEmpty);
    },
  );
}
