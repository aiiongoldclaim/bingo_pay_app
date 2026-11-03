import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:bingo_pay/features/scanner/presentation/screens/wallet_mpin_screen.dart';
import 'package:bingo_pay/features/tvs_wallet/presentation/screens/tvs_send_screen.dart';
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
    when(() => api.resolveRecipient(any())).thenAnswer(
      (_) async => {
        'recipient': {'name': 'As•• V••••', 'currency': 'INR'},
        'canSend': true,
        'available': '500.00',
        'pinAbove': '200.00',
      },
    );
    when(
      () => api.sendCoins(
        to: any(named: 'to'),
        amount: any(named: 'amount'),
        idempotencyKey: any(named: 'idempotencyKey'),
        note: any(named: 'note'),
        pin: any(named: 'pin'),
      ),
    ).thenAnswer(
      (_) async => {
        'amount': '50.00',
        'currency': 'INR',
        'to': {'name': 'As•• V••••'},
      },
    );
    when(
      () => api.pinStatus(),
    ).thenAnswer((_) async => {'isSet': true, 'length': 4});
  });

  tearDown(() => getIt.reset());

  Future<bool? Function()> open(WidgetTester tester, String to) async {
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
              AppRoutes.tvsSend,
              extra: to,
            ),
            child: const Text('open'),
          ),
        ),
        GoRoute(
          path: AppRoutes.tvsSend,
          builder: (_, state) => TvsSendScreen(to: state.extra as String?),
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

  Future<void> enterAmount(WidgetTester tester, String amount) async {
    // The second field: the first is "To".
    await tester.enterText(find.byType(TextField).at(1), amount);
    await tester.pumpAndSettle();
  }

  testWidgets('a scanned member is looked up, and a small amount just sends', (
    tester,
  ) async {
    final closed = await open(tester, 'tvs:u:abc');
    verify(() => api.resolveRecipient('tvs:u:abc')).called(1);
    expect(find.textContaining('You can send up to'), findsOneWidget);

    await enterAmount(tester, '50');
    await tester.tap(find.text('Send ₹50.00'));
    await tester.pumpAndSettle();

    verify(
      () => api.sendCoins(
        to: 'tvs:u:abc',
        amount: '50',
        idempotencyKey: any(named: 'idempotencyKey'),
        note: '',
        pin: null,
      ),
    ).called(1);
    expect(closed(), isTrue);
  });

  testWidgets('above the PIN limit the MPIN screen asks first', (
    tester,
  ) async {
    await open(tester, 'asha@example.com');
    await enterAmount(tester, '250');
    await tester.tap(find.text('Send ₹250.00'));
    await tester.pumpAndSettle();

    expect(find.text('Enter MPIN'), findsOneWidget);
    expect(find.textContaining('Send ₹250.00 to As•• V••••'), findsOneWidget);
    verifyNever(
      () => api.sendCoins(
        to: any(named: 'to'),
        amount: any(named: 'amount'),
        idempotencyKey: any(named: 'idempotencyKey'),
        note: any(named: 'note'),
        pin: any(named: 'pin'),
      ),
    );
  });
}
