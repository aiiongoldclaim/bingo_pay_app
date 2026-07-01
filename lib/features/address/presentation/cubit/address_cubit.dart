import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_respository.dart';
import 'address_state.dart';

@injectable
class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;

  AddressCubit(this.repository) : super(AddressInitial());

  Future<void> loadUserAddresses() async {
    emit(AddressLoading());

    try {
      final addresses = await repository.fetchAllAddresses();
      emit(AddressListLoaded(addresses));
    } catch (e) {
      emit(AddressError("Failed to load addresses"));
    }
  }

  Future<void> submitNewAddress(AddressEntity address) async {
    emit(AddressSubmitting());

    try {
      await repository.createNewAddress(address);
      await loadUserAddresses();
    } catch (e) {
      emit(AddressError("Failed to add address"));
    }
  }

  Future<void> updateAddressDetails(
    String addressId,
    AddressEntity address,
  ) async {
    emit(AddressSubmitting());

    try {
      await repository.updateExistingAddress(addressId, address);
      await loadUserAddresses();
    } catch (e) {
      emit(AddressError("Failed to update address"));
    }
  }

  Future<void> removeAddress(String addressId) async {
    emit(AddressSubmitting());

    try {
      await repository.deleteAddressById(addressId);
      await loadUserAddresses();
    } catch (e) {
      emit(AddressError("Failed to delete address"));
    }
  }
}
