import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/address_model.dart';

@injectable
class AddressRemoteDataSource {
  final ApiClient _client;

  AddressRemoteDataSource(this._client);

  Future<List<AddressModel>> getAllAddresses() async {
    final response = await _client.dio.get(ApiEndpoints.addresses);
    final responseData = response.data;

    if (responseData is! Map<String, dynamic>) {
      throw const FormatException('Invalid addresses response');
    }

    final dataWrapper = responseData['data'];
    if (dataWrapper is! Map<String, dynamic>) {
      throw const FormatException('Invalid data wrapper in addresses response');
    }

    final addressesJson = dataWrapper['data'];
    if (addressesJson is! List) {
      throw const FormatException('Invalid addresses list in response');
    }

    return addressesJson.map((e) => AddressModel.fromJson(e)).toList();
  }

  Future<AddressModel> getAddressDetails(String addressId) async {
    final response = await _client.dio.get(ApiEndpoints.addressDetail(addressId));
    final data = response.data;
    final addressJson = data is Map<String, dynamic> && data['data'] != null
        ? data['data']
        : data;

    return AddressModel.fromJson(addressJson);
  }

  Future<void> createAddress(AddressModel model) async {
    await _client.dio.post(
      ApiEndpoints.addresses,
      data: model.toJson(),
    );
  }

  Future<void> updateAddress(String addressId, AddressModel model) async {
    await _client.dio.patch(
      ApiEndpoints.addressDetail(addressId),
      data: model.toJson(),
    );
  }

  Future<void> deleteAddress(String addressId) async {
    await _client.dio.delete(ApiEndpoints.addressDetail(addressId));
  }
}
