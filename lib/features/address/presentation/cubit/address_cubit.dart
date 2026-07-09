import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_respository.dart';
import 'address_state.dart';

@injectable
class AddressCubit extends Cubit<AddressState> {
  final AddressRepository repository;

  AddressCubit(this.repository) : super(AddressInitial());

  // The repository throws the raw exception from the API layer (DioException
  // wrapping a ServerException/AuthException/etc via ErrorInterceptor).
  // Unwrap it with the same ErrorHandler the rest of the app uses so the
  // real reason (e.g. "Address not found", "Unauthorized") reaches the UI
  // instead of always showing the same generic fallback string.
  String _describe(Object error, String fallback) {
    if (error is Exception) {
      final message = ErrorHandler.mapExceptionToFailure(error).message;
      if (message.isNotEmpty) return message;
    }
    debugPrint('AddressCubit error: $error');
    return fallback;
  }

  Future<void> loadUserAddresses() async {
    emit(AddressLoading());

    try {
      final addresses = await repository.fetchAllAddresses();
      emit(AddressListLoaded(addresses));
    } catch (e) {
      emit(AddressError(_describe(e, "Failed to load addresses")));
    }
  }

  Future<void> submitNewAddress(AddressEntity address) async {
    emit(AddressSubmitting());

    try {
      await repository.createNewAddress(address);
      await loadUserAddresses();
    } catch (e) {
      emit(AddressError(_describe(e, "Failed to add address")));
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
      emit(AddressError(_describe(e, "Failed to update address")));
    }
  }

  Future<void> removeAddress(String addressId) async {
    emit(AddressSubmitting());

    try {
      await repository.deleteAddressById(addressId);
      await loadUserAddresses();
    } catch (e) {
      emit(AddressError(_describe(e, "Failed to delete address")));
    }
  }
}
