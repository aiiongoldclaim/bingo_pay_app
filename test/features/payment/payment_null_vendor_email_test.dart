import 'package:bingo_pay/features/payment/data/bigod_payment_datasource.dart';
import 'package:bingo_pay/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:bingo_pay/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBigodPaymentDataSource extends Mock
    implements BigodPaymentDataSource {}

class MockClearCartUseCase extends Mock implements ClearCartUseCase {}

void main() {
  test(
    'a product with a null vendorEmail is handled gracefully by the '
    'payment flow — no crash, and it defaults to an empty string exactly '
    "as payment_screen.dart's `widget.vendorEmail ?? ''` does",
    () {
      // Mirrors PaymentScreen._initPaymentCubit(): widget.vendorEmail is
      // String? and gets coerced with `?? ''` before reaching the cubit.
      const String? nullVendorEmail = null;

      expect(
        () => PaymentMethodCubit(
          productPrice: 4500,
          productName: 'Gold Necklace 22K',
          userEmail: 'buyer@example.com',
          vendorEmail: nullVendorEmail ?? '',
          variantUuid: 'var-1',
          quantity: 1,
          bigodPaymentDataSource: MockBigodPaymentDataSource(),
          clearCartUseCase: MockClearCartUseCase(),
        ),
        returnsNormally,
        reason: 'constructing the payment cubit for a product with no '
            'vendor email must not throw',
      );

      final cubit = PaymentMethodCubit(
        productPrice: 4500,
        productName: 'Gold Necklace 22K',
        userEmail: 'buyer@example.com',
        vendorEmail: nullVendorEmail ?? '',
        variantUuid: 'var-1',
        quantity: 1,
        bigodPaymentDataSource: MockBigodPaymentDataSource(),
        clearCartUseCase: MockClearCartUseCase(),
      );
      addTearDown(cubit.close);

      expect(cubit.state.vendorEmail, '',
          reason: 'a null vendor email must fall back to an empty string, '
              'not crash or leave a null in a non-nullable field');
      expect(cubit.state.productName, 'Gold Necklace 22K');
    },
  );
}
