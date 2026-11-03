import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/core/router/app_routes.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/scanner/presentation/screens/bigod_scan_pay_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class _MockBigod extends Mock implements BigodPaymentDataSource {}

// As /resolve-token sends it; `usd: null` is an older server (BIGOD only).
Map<String, dynamic> _intent(
  String status, {
  Map<String, dynamic>? usd = const {'total': '1.25', 'bigodPriceUsd': '0.5'},
  Map<String, dynamic>? local,
}) => {
  'type': 'PAYMENT_INTENT',
  'status': status,
  'amount': '2.50000000', // Prisma decimals arrive as strings
  'expiresAt': DateTime.now().add(const Duration(minutes: 5)).toIso8601String(),
  'usd': ?usd,
  'local': local,
  'items': [
    {'productTitle': 'Masala Chai', 'quantity': 2},
  ],
  'vendors': [
    {'shopName': 'Chai Point', 'amount': '2.5'},
  ],
};

void main() {
  late _MockBigod api;
  Map<String, dynamic>? receipt;

  setUp(() {
    api = _MockBigod();
    receipt = null;
    getIt.registerSingleton<BigodPaymentDataSource>(api);
  });

  tearDown(() => getIt.reset());

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const BigodScanPayScreen(token: 'tok'),
        ),
        GoRoute(
          path: AppRoutes.transferSuccess,
          builder: (_, state) {
            receipt = state.extra as Map<String, dynamic>;
            return const Text('receipt');
          },
        ),
      ],
    );
    await tester.pumpWidget(
      Sizer(builder: (_, _, _) => MaterialApp.router(routerConfig: router)),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the payment and pays its token', (tester) async {
    when(
      () => api.resolveToken('tok'),
    ).thenAnswer((_) async => _intent('PENDING'));
    when(() => api.payToken('tok')).thenAnswer(
      (_) async => {
        'status': 'PAID',
        'amount': 2.5,
        'reference': 'BIGOD-1',
        'order': {'uuid': 'o1', 'orderNumber': 'ORD-1'},
      },
    );
    await open(tester);

    expect(find.text('Chai Point'), findsOneWidget);
    expect(find.text('\$1.25'), findsOneWidget); // the order's own price
    expect(find.text('2.5 BIGOD'), findsOneWidget); // small, underneath
    expect(find.text('Masala Chai'), findsOneWidget);
    expect(find.text('Paying from your BIGOD wallet'), findsOneWidget);

    await tester.tap(find.text('Pay 2.5 BIGOD'));
    await tester.pumpAndSettle();

    verify(() => api.payToken('tok')).called(1);
    expect(receipt?['reference'], 'ORD-1');
    expect(receipt?['amount'], '\$1.25');
    expect(receipt?['caption'], 'Paid 2.5 BIGOD');
    expect(receipt?['method'], 'BIGOD');
  });

  testWidgets('an expired payment says so and cannot be paid', (tester) async {
    when(
      () => api.resolveToken('tok'),
    ).thenAnswer((_) async => _intent('EXPIRED'));
    await open(tester);

    expect(
      find.text('This QR has expired. Start again on the checkout page.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Pay 2.5 BIGOD'));
    await tester.pumpAndSettle();
    verifyNever(() => api.payToken(any()));
  });

  testWidgets('prices in the local currency when the server knows it', (
    tester,
  ) async {
    when(() => api.resolveToken('tok')).thenAnswer(
      (_) async => _intent(
        'PENDING',
        local: {'currency': 'INR', 'total': '103.75', 'perUsd': '83'},
      ),
    );
    await open(tester);

    expect(find.text('₹103.75'), findsOneWidget);
    expect(find.text('2.5 BIGOD'), findsOneWidget);
  });

  testWidgets('an older server without prices shows BIGOD alone', (
    tester,
  ) async {
    when(
      () => api.resolveToken('tok'),
    ).thenAnswer((_) async => _intent('PENDING', usd: null));
    await open(tester);

    expect(find.text('2.5 BIGOD'), findsOneWidget);
    expect(find.textContaining('\$'), findsNothing);
  });

  test('formatBigod drops trailing zeros only', () {
    expect(formatBigod('2.40963855'), '2.40963855');
    expect(formatBigod('300.00000000'), '300');
    expect(formatBigod(12.5), '12.5');
    expect(formatBigod(null), '—');
  });
}
