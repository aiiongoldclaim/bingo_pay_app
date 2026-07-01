import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> fetchAllAddresses();

  Future<AddressEntity> fetchAddressById(String addressId);

  Future<void> createNewAddress(AddressEntity address);

  Future<void> updateExistingAddress(String addressId, AddressEntity address);

  Future<void> deleteAddressById(String addressId);
}