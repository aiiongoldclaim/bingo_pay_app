import 'dart:async';

import 'package:bingo_pay/core/error/exceptions.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/core/router/route_guard.dart';
import 'package:bingo_pay/core/storage/preferences_service.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:bingo_pay/features/tvs_wallet/data/pending_invite.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockApi extends Mock implements TvsQrDataSource {}

void main() {
  group('parse', () {
    Invite? parse(String url) => PendingInvite.parse(Uri.parse(url));

    test('the server’s link: /join?ref=CODE is a LINK', () {
      expect(parse('https://thevaults.org/join?ref=k7px2m9q'), (
        code: 'K7PX2M9Q',
        channel: 'LINK',
      ));
    });

    test('&ch=QR marks a QR; ?code= is accepted too', () {
      expect(parse('/join?code=ABC&ch=QR'), (code: 'ABC', channel: 'QR'));
      expect(parse('https://thevaults.org/join/?ref=ABC'), isNotNull);
    });

    test('anything else is not an invite', () {
      expect(parse('https://thevaults.org/join'), isNull);
      expect(parse('https://thevaults.org/pay?token=abc&ref=X'), isNull);
      expect(parse('tvs:u:123'), isNull);
    });
  });

  group('add', () {
    late _MockApi api;
    late PreferencesService prefs;
    late PendingInvite invite;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = PreferencesService(await SharedPreferences.getInstance());
      api = _MockApi();
      invite = PendingInvite(prefs: prefs, api: api);
      await invite.save((code: 'ABC', channel: 'LINK'));
    });

    test('adds the saved code with its channel, then forgets it', () async {
      when(
        () => api.applyReferralCode('ABC', channel: 'LINK'),
      ).thenAnswer((_) async => {});

      expect(await invite.add(), isNull);
      expect(prefs.getPendingInvite(), isNull);
    });

    test('a refusal is reported and the code dropped', () async {
      when(() => api.applyReferralCode('ABC', channel: 'LINK')).thenThrow(
        const TvsQrException(
          'CODE_OWN',
          'You can’t join through your own code.',
        ),
      );

      expect(await invite.add(), 'You can’t join through your own code.');
      expect(prefs.getPendingInvite(), isNull);
    });

    test('offline keeps the code for the next sign-in', () async {
      when(() => api.applyReferralCode('ABC', channel: 'LINK')).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          error: const NetworkException(),
        ),
      );

      expect(await invite.add(), isNotNull);
      expect(prefs.getPendingInvite(), ['ABC', 'LINK']);
    });

    test('sign-in and the landing page asking together add it once', () async {
      final reply = Completer<Map<String, dynamic>>();
      when(
        () => api.applyReferralCode('ABC', channel: 'LINK'),
      ).thenAnswer((_) => reply.future);

      final first = invite.add();
      final second = PendingInvite(prefs: prefs, api: api).add();
      reply.complete({});

      expect(await first, isNull);
      expect(await second, isNull);
      verify(() => api.applyReferralCode('ABC', channel: 'LINK')).called(1);
    });
  });

  test('the invite landing is never redirected away', () {
    for (final auth in const [
      RouteAuthState.loading(),
      RouteAuthState.unauthenticated(hasSeenOnboarding: false),
      RouteAuthState.authenticated(),
    ]) {
      expect(
        RouteGuard.redirect(location: AppRoutes.join, authState: auth),
        isNull,
      );
    }
  });
}
