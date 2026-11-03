import 'package:bingo_pay/core/di/injection.dart';
import 'package:bingo_pay/features/profile/domain/enities/profile_entity.dart';
import 'package:bingo_pay/features/profile/presentation/widgets/profile_header.dart';
import 'package:bingo_pay/features/scanner/data/tvs_qr_datasource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sizer/sizer.dart';

class _MockApi extends Mock implements TvsQrDataSource {}

const _profile = ProfileEntity(
  id: '1',
  uuid: 'u',
  fullName: 'Asha Verma',
  email: 'asha@example.com',
  phone: '',
  kycStatus: KycStatus.approved,
  emailVerified: true,
  phoneVerified: true,
  bigoldBalance: 1250.5,
);

void main() {
  late _MockApi api;

  setUp(() {
    api = _MockApi();
    getIt.registerSingleton<TvsQrDataSource>(api);
  });

  tearDown(() => getIt.reset());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      Sizer(
        builder: (_, _, _) => MaterialApp(
          home: Scaffold(
            body: ProfileHeader(
              profile: _profile,
              onEdit: () {},
              onWalletTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows TVS coins (own + bonus) and what they are worth', (
    tester,
  ) async {
    when(() => api.walletSummary()).thenAnswer(
      (_) async => {
        'activationRequired': true,
        'wallets': [
          {'currency': 'INR', 'available': '1250.05', 'bonus': '49.95'},
        ],
      },
    );
    await pump(tester);

    expect(find.text('TVS Wallet'), findsOneWidget);
    expect(find.textContaining('1300.00'), findsNWidgets(2));
    expect(find.text('Worth 1300.00 INR'), findsOneWidget);
    expect(find.text('Activate'), findsOneWidget);
  });

  testWidgets('an active wallet has no Activate button', (tester) async {
    when(() => api.walletSummary()).thenAnswer(
      (_) async => {
        'activationRequired': false,
        'wallets': [
          {'currency': 'SGD', 'available': '20.00', 'bonus': '0.00'},
        ],
      },
    );
    await pump(tester);

    expect(find.text('Worth 20.00 SGD'), findsOneWidget);
    expect(find.text('Activate'), findsNothing);
  });

  testWidgets('hides the TVS row when the wallet cannot be loaded', (
    tester,
  ) async {
    when(
      () => api.walletSummary(),
    ).thenAnswer((_) => Future.error(Exception('offline')));
    await pump(tester);

    expect(find.text('BiGod Wallet'), findsOneWidget);
    expect(find.text('TVS Wallet'), findsNothing);
  });
}
