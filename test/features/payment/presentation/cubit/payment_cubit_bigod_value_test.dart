import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:bingo_pay/features/membershipNew/data/models/membership_balance_model.dart';
import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockBigod extends Mock implements BigodPaymentDataSource {}

class _MockClearCart extends Mock implements ClearCartUseCase {}

void main() {
  late _MockBigod bigod;
  late PaymentMethodCubit cubit;

  setUp(() {
    bigod = _MockBigod();
    cubit = PaymentMethodCubit(
      bigodPaymentDataSource: bigod,
      clearCartUseCase: _MockClearCart(),
    );
  });

  tearDown(() => cubit.close());

  test('loadWalletBalance adds the BIGOD balance value line', () async {
    when(() => bigod.balance()).thenAnswer(
      (_) async => const BigodBalance(
        bigodBalance: 5000,
        tokenBalance: 0,
        kycStatus: 'APPROVED',
        usdValue: 410.5,
        localCurrency: 'INR',
        localValue: 34122.11,
      ),
    );

    await cubit.loadWalletBalance('a@b.c');

    expect(cubit.state.bigodValueLine, '≈ \$410.50 · ≈ ₹34,122.11');
  });

  test('a failed balance call shows nothing extra', () async {
    when(() => bigod.balance()).thenThrow(Exception('offline'));

    await cubit.loadWalletBalance('a@b.c');

    expect(cubit.state.bigodValueLine, isNull);
  });
}
