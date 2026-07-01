import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../models/address_model.dart';

@injectable
class AddressRemoteDataSource {
  final ApiClient _client;

  AddressRemoteDataSource(this._client);

  final baseUrl = "http://13.159.7.199:5001/api/v1";

  Future<List<AddressModel>> getAllAddresses() async {
    final response = await _client.dio.get('$baseUrl/addresses');
    final data = response.data;
    final addressesJson = data is Map<String, dynamic> ? data['data'] : data;

    if (addressesJson is! List) {
      throw const FormatException('Invalid addresses response');
    }

    return addressesJson.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<AddressModel> getAddressDetails(String addressId) async {
    final response = await _client.dio.get('$baseUrl/addresses/$addressId');
    final data = response.data;
    final addressJson = data is Map<String, dynamic> && data['data'] != null
        ? data['data']
        : data;

    return AddressModel.fromJson(addressJson);
  }

  Future<void> createAddress(AddressModel model) async {
    await _client.dio.post('$baseUrl/addresses', data: model.toJson());
  }

  Future<void> updateAddress(String addressId, AddressModel model) async {
    await _client.dio.patch(
      '$baseUrl/addresses/$addressId',
      data: model.toJson(),
    );
  }

  Future<void> deleteAddress(String addressId) async {
    await _client.dio.delete('$baseUrl/addresses/$addressId');
  }
}
