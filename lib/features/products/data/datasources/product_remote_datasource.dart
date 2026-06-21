import 'package:injectable/injectable.dart';

import '../../../../core/api/apps_script_client.dart';

abstract interface class ProductRemoteDataSource {
  Future<void> addProduct(Map<String, dynamic> payload);
  Future<List<Map<String, dynamic>>> getProducts();
}

@Injectable(as: ProductRemoteDataSource)
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final AppsScriptClient _client;

  ProductRemoteDataSourceImpl(this._client);

  @override
  Future<void> addProduct(Map<String, dynamic> payload) async {
    await _client.post('addProduct', payload);
  }

  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
    final data = await _client.get('getProducts');
    final list = data['data'];
    if (list is! List) return [];
    return list.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))).toList();
  }
}
