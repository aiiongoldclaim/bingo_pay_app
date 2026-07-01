import 'package:bingo_pay/features/address/data/datasources/address_remote_datasources.dart';
import 'package:bingo_pay/features/address/domain/repositories/address_respository.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/address_entity.dart';
import '../models/address_model.dart';
@Injectable(as: AddressRepository)
class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AddressEntity>> fetchAllAddresses() async {
    final result = await remoteDataSource.getAllAddresses();
    return result.map((e) => e.toEntity()).toList();
  }

  @override
  Future<AddressEntity> fetchAddressById(String addressId) async {
    final result = await remoteDataSource.getAddressDetails(addressId);
    return result.toEntity();
  }

  @override
  Future<void> createNewAddress(AddressEntity address) async {
    await remoteDataSource.createAddress(
      AddressModel.fromEntity(address),
    );
  }

  @override
  Future<void> updateExistingAddress(
      String addressId, AddressEntity address) async {
    await remoteDataSource.updateAddress(
      addressId,
      AddressModel.fromEntity(address),
    );
  }

  @override
  Future<void> deleteAddressById(String addressId) async {
    await remoteDataSource.deleteAddress(addressId);
  }
}