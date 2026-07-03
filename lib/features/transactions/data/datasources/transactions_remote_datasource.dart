import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> getTransactions();
}

@Injectable(as: TransactionsRemoteDataSource)
class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final ApiClient _client;

  const TransactionsRemoteDataSourceImpl(this._client);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final response = await _client.dio.get(ApiEndpoints.transactions);
    final envelope = response.data as Map<String, dynamic>;
    // The response is double-wrapped: {success, data: {message, data: [...]}}.
    final outer = envelope['data'];
    final list = outer is Map<String, dynamic> ? outer['data'] : outer;
    if (list is! List) return const [];
    return list
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
