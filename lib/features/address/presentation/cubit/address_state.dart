import 'package:equatable/equatable.dart';
import '../../domain/entities/address_entity.dart';

abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

class AddressInitial extends AddressState {}

/// 🔄 Loading while fetching list
class AddressLoading extends AddressState {}

/// 📦 Address list loaded successfully
class AddressListLoaded extends AddressState {
  final List<AddressEntity> addresses;

  const AddressListLoaded(this.addresses);

  @override
  List<Object?> get props => [addresses];
}

/// ⏳ When add/update/delete is happening
class AddressSubmitting extends AddressState {}

/// ✅ Operation success (optional but useful)
class AddressOperationSuccess extends AddressState {
  final String message;

  const AddressOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// ❌ Error state
class AddressError extends AddressState {
  final String errorMessage;

  const AddressError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}