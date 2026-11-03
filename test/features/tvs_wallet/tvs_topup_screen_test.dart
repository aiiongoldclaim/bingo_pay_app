import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:bingo_pay/features/tvs_wallet/presentation/screens/tvs_topup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class _MockApi extends Mock implements TvsQrDataSource {}

void main() {
  late _MockApi api;
  final keys = <String>[];

  setUp(() {
    keys.clear();
    api = _MockApi();
    getIt.registerSingleton<TvsQrDataSource>(api);
    // The server replays the failed top-up for a reused key.
    when(
      () => api.startTopup(
        amount: any(named: 'amount'),
        idempotencyKey: any(named: 'idempotencyKey'),
        walletUuid: any(named: 'walletUuid'),
      ),
    ).thenAnswer((i) async {
      keys.add(i.namedArguments[#idempotencyKey] as String);
      return {
        'uuid': 't1',
        'status': 'FAILED',
        'failureCode': 'GATEWAY_ERROR',
        'failureMessage': 'Invalid API Key provided: sk_live_****',
      };
    });
  });

  tearDown(() => getIt.reset());

  testWidgets('a failed start is not replayed: the retry gets a new key', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => const MaterialApp(
          home: TvsTopupScreen(wallet: {'uuid': 'w1', 'currency': 'INR'}),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '1,000');
    await tester.pumpAndSettle();
    expect(find.text('1,000 INR'), findsOneWidget); // grouped preview

    await tester.tap(find.text('Pay ₹1,000.00 by card'));
    await tester.pumpAndSettle();
    expect(
      find.text('Couldn’t open the payment page. Please try again.'),
      findsOneWidget,
    );
    expect(find.textContaining('sk_live'), findsNothing);

    await tester.tap(find.text('Pay ₹1,000.00 by card'));
    await tester.pumpAndSettle();
    expect(keys, hasLength(2));
    expect(keys[0], isNot(keys[1]));
  });

  testWidgets('a currency without decimals takes whole amounts only', (
    tester,
  ) async {
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => const MaterialApp(
          home: TvsTopupScreen(wallet: {'uuid': 'w1', 'currency': 'VND'}),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '100.50');
    await tester.pumpAndSettle();
    expect(find.text('100 VND'), findsOneWidget);
  });

  testWidgets('the amount stops at 16 whole digits, as the server allows', (
    tester,
  ) async {
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => const MaterialApp(
          home: TvsTopupScreen(wallet: {'uuid': 'w1', 'currency': 'INR'}),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '12345678901234567');
    await tester.pumpAndSettle();
    expect(find.text('1,234,567,890,123,456 INR'), findsOneWidget);
  });
}
