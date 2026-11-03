import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/helpers/image_upload.dart';
import '../models/refund_request_model.dart';

@injectable
class RefundRequestsRemoteDataSource {
  final ApiClient _client;

  RefundRequestsRemoteDataSource(this._client);

  // Every reply is wrapped as { data: <payload> }.
  Map<String, dynamic> _data(Response response) =>
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  Future<RefundEligibility> eligibility(String orderUuid) async =>
      RefundEligibility.fromJson(
        _data(await _client.dio.get(ApiEndpoints.refundEligibility(orderUuid))),
      );

  /// Returns the server's confirmation, e.g. "2 refund requests sent — one per seller."
  Future<String> create(
    String orderUuid, {
    required Map<String, int> items,
    required String reasonCode,
    String? description,
    List<String> evidence = const [],
  }) async {
    final response = await _client.dio.post(
      ApiEndpoints.refundOrder(orderUuid),
      data: {
        'items': [
          for (final e in items.entries)
            {'orderItemId': e.key, 'quantity': e.value},
        ],
        'reasonCode': reasonCode,
        if (description != null && description.isNotEmpty)
          'description': description,
        if (evidence.isNotEmpty) 'evidence': evidence,
      },
    );
    return _data(response)['message'] as String? ?? 'Refund request sent.';
  }

  // shortcut: first 100 requests only (API max page), add paging if customers outgrow it.
  Future<List<RefundRequestModel>> mine() async {
    final body = _data(
      await _client.dio.get(
        ApiEndpoints.refundRequests,
        queryParameters: {'limit': 100},
      ),
    );
    return (body['items'] as List? ?? const [])
        .map((e) => RefundRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RefundRequestModel> detail(String uuid) async =>
      RefundRequestModel.fromJson(
        _data(await _client.dio.get(ApiEndpoints.refundRequest(uuid))),
      );

  Future<RefundRequestModel> cancel(String uuid) async =>
      RefundRequestModel.fromJson(
        _data(
          await _client.dio.post(
            ApiEndpoints.refundRequestCancel(uuid),
            data: const <String, dynamic>{},
          ),
        ),
      );

  /// Uploads one evidence photo and returns its URL.
  Future<String> uploadEvidence(XFile file) async {
    final response = await _client.dio.post(
      ApiEndpoints.uploads,
      queryParameters: {'folder': 'refund-requests'},
      data: FormData.fromMap({'file': await imagePart(file)}),
    );
    // The upload API double-wraps its envelope; dig the URL out.
    dynamic payload = response.data;
    while (payload is Map && payload['url'] == null && payload['data'] != null) {
      payload = payload['data'];
    }
    final url = payload is Map ? payload['url'] : null;
    if (url is! String || url.isEmpty) {
      throw const FormatException('The upload did not return a URL');
    }
    return url;
  }
}
