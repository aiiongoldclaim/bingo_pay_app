// Regression test for the concurrent-401 token-refresh race described in
// the "user logged out on app reopen" investigation.
//
// The backend rotates (single-use) refresh tokens on every /refresh call.
// AuthInterceptor.onRequest attaches the access token to every outgoing
// request, and app.dart fires several authenticated requests together
// right after login (cart + wishlist). If the access token happens to be
// expired at that moment — the normal case for a returning user reopening
// the app — those requests 401 at nearly the same time.
//
// RequestQueueManager exists so that only ONE of those concurrent 401s
// performs the actual refresh call, and the rest await its result instead
// of each independently calling /refresh with the same (soon to be
// invalidated) refresh token. This test proves that contract holds even
// under adversarial interleaving, using nothing but Dart's event loop —
// no device, network, or backend required.
import 'dart:async';

import 'package:bingo_pay/core/api/request_queue_manager.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // RequestQueueManager() is a process-wide singleton, so make sure each
  // test starts from a clean, non-refreshing state.
  setUp(() => RequestQueueManager().clear());

  group('RequestQueueManager.claimOrWait', () {
    test(
      'exactly one of many concurrent callers becomes the leader (claim is '
      'atomic even under interleaving)',
      () async {
        final manager = RequestQueueManager();
        const callerCount = 10;

        // Interleave the callers via microtasks so this isn't just "call
        // them in a plain for-loop" (which would trivially be sequential
        // and never exercise a race) — it mirrors how Dio's onError fires
        // once per failed request, with the event loop free to interleave
        // them, which is exactly how the cart and wishlist 401s raced in
        // the real bug.
        //
        // Note: claims are collected via scheduleMicrotask into a plain
        // list rather than through `Future.wait(List.generate(..., () async
        // => manager.claimOrWait()))` — an async closure that returns a
        // Future (the follower branch) gets auto-flattened/awaited by
        // Dart before the closure's own future completes, which would
        // deadlock here since nothing resolves the followers' futures
        // until completeRefresh() is called below.
        final claims = List<Future<RefreshOutcome>?>.filled(
          callerCount,
          null,
          growable: false,
        );
        for (var i = 0; i < callerCount; i++) {
          scheduleMicrotask(() => claims[i] = manager.claimOrWait());
        }
        // Microtasks are fully drained before this delayed (macrotask)
        // future's callback runs, so every claim above is guaranteed to
        // have been made by the time execution resumes here.
        await Future<void>.delayed(Duration.zero);

        final leaders = claims.where((c) => c == null).length;
        final followers = claims.where((c) => c != null).length;

        expect(
          leaders,
          1,
          reason:
              'Exactly one caller must be chosen to perform the refresh; '
              'more than one leader reproduces the original bug where two '
              'requests both called /refresh with the same single-use '
              'token and the loser force-logged-out the session the '
              'winner had just saved.',
        );
        expect(followers, callerCount - 1);

        // Followers must all resolve to the SAME outcome as the leader,
        // not attempt anything themselves.
        manager.completeRefresh('new-access-token');
        final results = await Future.wait(
          claims.whereType<Future<RefreshOutcome>>(),
        );
        for (final outcome in results) {
          expect(outcome.isSuccess, isTrue);
          expect(outcome.accessToken, 'new-access-token');
        }
      },
    );

    test(
      'a follower sees the leader\'s failure instead of failing '
      'independently',
      () async {
        final manager = RequestQueueManager();

        final leaderClaim = manager.claimOrWait();
        final followerClaim = manager.claimOrWait();

        expect(leaderClaim, isNull);
        expect(followerClaim, isNotNull);

        manager.failRefresh(Exception('refresh token rejected by backend'));

        final outcome = await followerClaim!;
        expect(outcome.isSuccess, isFalse);
      },
    );

    test('after a refresh completes, a new claim can start a fresh one', () {
      final manager = RequestQueueManager();

      expect(manager.claimOrWait(), isNull);
      manager.completeRefresh('token-a');
      expect(manager.isRefreshing, isFalse);

      expect(manager.claimOrWait(), isNull);
      manager.completeRefresh('token-b');
      expect(manager.isRefreshing, isFalse);
    });
  });
}
