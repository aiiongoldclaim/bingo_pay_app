import '../../../address/domain/entities/address_entity.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../../data/models/stripe_intent_response.dart';
import '../cubit/payment_cubit.dart';


class ReviewPayArgs {
  final PaymentMethodCubit cubit;
  final bool isCart;

  const ReviewPayArgs({required this.cubit, required this.isCart});
}

class CardPaymentArgs {
  final PaymentMethodCubit cubit;
  final StripeIntentResponse intent;
  // A NOWPayments invoice rather than a Stripe checkout.
  final bool isCrypto;

  const CardPaymentArgs({
    required this.cubit,
    required this.intent,
    this.isCrypto = false,
  });
}

class AddEditAddressArgs {
  final AddressCubit cubit;
  final AddressEntity? existingAddress;

  const AddEditAddressArgs({required this.cubit, this.existingAddress});
}
