import '../../../address/domain/entities/address_entity.dart';
import '../../../address/presentation/cubit/address_cubit.dart';
import '../cubit/payment_cubit.dart';


class ReviewPayArgs {
  final PaymentMethodCubit cubit;
  final bool isCart;

  const ReviewPayArgs({required this.cubit, required this.isCart});
}

class AddEditAddressArgs {
  final AddressCubit cubit;
  final AddressEntity? existingAddress;

  const AddEditAddressArgs({required this.cubit, this.existingAddress});
}
