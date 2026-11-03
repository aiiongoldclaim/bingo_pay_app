import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:bingo_pay/features/scanner/presentation/screens/wallet_mpin_screen.dart';
import 'package:bingo_pay/features/tvs_wallet/presentation/widgets/tvs_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class _MockApi extends Mock implements TvsQrDataSource {}

void main() {
  late _MockApi api;

  setUp(() {
    api = _MockApi();
    getIt.registerSingleton<TvsQrDataSource>(api);
    when(
      () => api.setPin(any(), currentPin: any(named: 'currentPin')),
    ).thenAnswer((_) async {});
  });

  tearDown(() => getIt.reset());

  // Opens the screen over a host page; the returned getter is what it closed with.
  Future<bool? Function()> open(WidgetTester tester, MpinArgs? args) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    bool? result;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () async => result = await context.push<bool>(
              AppRoutes.walletMpin,
              extra: args,
            ),
            child: const Text('open'),
          ),
        ),
        GoRoute(
          path: AppRoutes.walletMpin,
          builder: (_, state) =>
              WalletMpinScreen(args: state.extra as MpinArgs?),
        ),
      ],
    );
    await tester.pumpWidget(
      Sizer(builder: (_, _, _) => MaterialApp.router(routerConfig: router)),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => result;
  }

  Future<void> type(WidgetTester tester, String digits) async {
    for (final d in digits.split('')) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
  }

  testWidgets('creating refuses a weak or unconfirmed MPIN, then saves it', (
    tester,
  ) async {
    final closed = await open(tester, const MpinArgs(mode: MpinMode.create));
    expect(find.text('Create your MPIN'), findsOneWidget);

    await type(tester, '1111');
    expect(find.textContaining('Too easy to guess'), findsOneWidget);

    await type(tester, '4829');
    expect(find.text('Confirm MPIN'), findsOneWidget);
    await type(tester, '4820');
    expect(find.text('MPINs didn’t match. Try again.'), findsOneWidget);
    expect(find.text('Create your MPIN'), findsOneWidget);

    await type(tester, '4829');
    await type(tester, '4829');
    verify(() => api.setPin('4829')).called(1);
    expect(closed(), isTrue);
  });

  testWidgets('a wrong MPIN keeps the screen open to try again', (
    tester,
  ) async {
    final tried = <String>[];
    final closed = await open(
      tester,
      MpinArgs(
        mode: MpinMode.verify,
        onPin: (pin) async {
          tried.add(pin);
          return tried.length == 1 ? 'Wrong PIN. 4 attempt(s) left.' : null;
        },
      ),
    );

    await type(tester, '1357');
    expect(find.text('Wrong PIN. 4 attempt(s) left.'), findsOneWidget);
    expect(closed(), isNull);

    await type(tester, '4829');
    expect(tried, ['1357', '4829']);
    expect(closed(), isTrue);
  });

  testWidgets('creating to pay saves the MPIN, then pays with it', (
    tester,
  ) async {
    final paidWith = <String>[];
    final closed = await open(
      tester,
      MpinArgs(
        mode: MpinMode.create,
        onPin: (pin) async {
          paidWith.add(pin);
          return null;
        },
      ),
    );

    await type(tester, '4829');
    await type(tester, '4829');
    verify(() => api.setPin('4829')).called(1);
    expect(paidWith, ['4829']);
    expect(closed(), isTrue);
  });

  testWidgets('resetting takes the emailed code, then a new MPIN', (
    tester,
  ) async {
    when(
      () => api.requestPinReset(),
    ).thenAnswer((_) async => {'sentTo': 'as•••@example.com'});
    when(() => api.confirmPinReset(any(), any())).thenAnswer((_) async {});
    final closed = await open(tester, const MpinArgs(mode: MpinMode.reset));
    expect(find.textContaining('as•••@example.com'), findsOneWidget);

    await type(tester, '123456');
    expect(find.text('Set a new MPIN'), findsOneWidget);
    await type(tester, '4829');
    await type(tester, '4829');
    verify(() => api.confirmPinReset('123456', '4829')).called(1);
    expect(closed(), isTrue);
  });

  testWidgets('resetting with no MPIN set offers to create one', (
    tester,
  ) async {
    when(() => api.requestPinReset()).thenThrow(
      const TvsQrException('PIN_NOT_SET', 'You have no wallet PIN yet.'),
    );
    await open(tester, const MpinArgs(mode: MpinMode.reset));
    expect(find.text('Create your MPIN'), findsOneWidget);
  });

  testWidgets('changing asks for the current MPIN first', (tester) async {
    when(
      () => api.pinStatus(),
    ).thenAnswer((_) async => {'isSet': true, 'length': 4});
    final closed = await open(tester, null);
    expect(find.text('Enter current MPIN'), findsOneWidget);

    await type(tester, '4829');
    await type(tester, '6173');
    await type(tester, '6173');
    verify(() => api.setPin('6173', currentPin: '4829')).called(1);
    expect(closed(), isTrue);
  });

  testWidgets('a new reset code can be sent only after 30 seconds', (
    tester,
  ) async {
    when(
      () => api.requestPinReset(),
    ).thenAnswer((_) async => {'sentTo': 'as•••@example.com'});
    await open(tester, const MpinArgs(mode: MpinMode.reset));
    expect(find.textContaining('Send a new code in'), findsOneWidget);

    await tester.pump(const Duration(seconds: 31));
    await tester.tap(find.text('Resend code'));
    await tester.pumpAndSettle();
    verify(() => api.requestPinReset()).called(2);
    expect(find.textContaining('Send a new code in'), findsOneWidget);
    await tester.pump(const Duration(seconds: 31)); // no timer left running
  });

  testWidgets('a locked MPIN says until when', (tester) async {
    final until = DateTime.now().add(const Duration(minutes: 15));
    when(() => api.pinStatus()).thenAnswer(
      (_) async => {
        'isSet': true,
        'length': 4,
        'lockedUntil': until.toUtc().toIso8601String(),
      },
    );
    await open(tester, null);
    expect(
      find.text(
        'Locked after wrong tries until ${tvsTime(until.toUtc().toIso8601String())}. '
        'Forgot MPIN? unlocks it now.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('paying with a locked MPIN says until when', (tester) async {
    final until = DateTime.now().add(const Duration(minutes: 15));
    when(() => api.pinStatus()).thenAnswer(
      (_) async => {'isSet': true, 'lockedUntil': until.toIso8601String()},
    );
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => TextButton(
            onPressed: () => runWithMpin(
              context,
              isSet: true,
              attempt: (_) => throw const TvsQrException(
                'PIN_LOCKED',
                'Too many wrong PINs. Locked for 15 minutes.',
              ),
            ),
            child: const Text('open'),
          ),
        ),
        GoRoute(
          path: AppRoutes.walletMpin,
          builder: (_, state) =>
              WalletMpinScreen(args: state.extra as MpinArgs?),
        ),
      ],
    );
    await tester.pumpWidget(
      Sizer(builder: (_, _, _) => MaterialApp.router(routerConfig: router)),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await type(tester, '4829');
    expect(
      find.textContaining('until ${tvsTime(until.toIso8601String())}'),
      findsOneWidget,
    );
  });
}
