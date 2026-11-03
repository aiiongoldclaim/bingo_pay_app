import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../../../core/helpers/image_upload.dart';
import '../models/review_models.dart';

@injectable
class ReviewsRemoteDataSource {
  final ApiClient _client;

  ReviewsRemoteDataSource(this._client);

  // Every reply is wrapped as { data: <payload> }.
  Map<String, dynamic> _data(Response response) =>
      (response.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;

  List<Review> _items(Map<String, dynamic> page, ReviewKind kind) =>
      (page['items'] as List? ?? const [])
          .map((e) => Review.fromJson(e as Map<String, dynamic>, kind))
          .toList();

  Future<ReviewEligibility> eligibility(String orderUuid) async =>
      ReviewEligibility.fromJson(
        _data(await _client.dio.get(ApiEndpoints.reviewEligibility(orderUuid))),
      );

  // shortcut: newest 100 only (API max page), add paging if customers outgrow it.
  Future<List<Review>> mine(ReviewKind kind) async => _items(
    _data(
      await _client.dio.get(
        kind == ReviewKind.product
            ? ApiEndpoints.myProductReviews
            : ApiEndpoints.myAgentReviews,
        queryParameters: {'limit': 100},
      ),
    ),
    kind,
  );

  /// Approved reviews of a product, newest first, and how many there are.
  Future<({List<Review> items, int total})> productReviews(
    String productUuid, {
    int page = 1,
    int limit = 5,
  }) async {
    final body = _data(
      await _client.dio.get(
        ApiEndpoints.productReview(productUuid),
        queryParameters: {'page': page, 'limit': limit},
      ),
    );
    return (
      items: _items(body, ReviewKind.product),
      total: (body['total'] as num?)?.toInt() ?? 0,
    );
  }

  Future<ReviewSummary> summary(String productUuid) async =>
      ReviewSummary.fromJson(
        _data(
          await _client.dio.get(ApiEndpoints.productReviewSummary(productUuid)),
        ),
      );

  /// Uploads up to 5 photos (1 MB each) and returns their URLs.
  Future<List<String>> uploadImages(List<XFile> files) async {
    final response = await _client.dio.post(
      ApiEndpoints.reviewImages,
      data: FormData.fromMap({
        'files': [for (final f in files) await imagePart(f)],
      }),
    );
    return (_data(response)['urls'] as List? ?? const [])
        .whereType<String>()
        .toList();
  }

  Future<Review> createProductReview({
    required String orderItemId,
    required int rating,
    String? title,
    String? comment,
    List<String> images = const [],
  }) async => Review.fromJson(
    _data(
      await _client.dio.post(
        ApiEndpoints.reviewProducts,
        data: {
          'orderItemId': orderItemId,
          'rating': rating,
          if ((title ?? '').isNotEmpty) 'title': title,
          if ((comment ?? '').isNotEmpty) 'comment': comment,
          if (images.isNotEmpty) 'images': images,
        },
      ),
    ),
    ReviewKind.product,
  );

  Future<Review> createAgentReview({
    required String agentUuid,
    required String vendorOrderUuid,
    required int rating,
    String? comment,
  }) async => Review.fromJson(
    _data(
      await _client.dio.post(
        ApiEndpoints.agentReview(agentUuid),
        data: {
          'vendorOrderUuid': vendorOrderUuid,
          'rating': rating,
          if ((comment ?? '').isNotEmpty) 'comment': comment,
        },
      ),
    ),
    ReviewKind.agent,
  );

  /// Agent reviews take no title or photos.
  Future<Review> update(
    ReviewKind kind,
    String uuid, {
    required int rating,
    String? title,
    String? comment,
    List<String> images = const [],
  }) async => Review.fromJson(
    _data(
      await _client.dio.patch(
        kind == ReviewKind.product
            ? ApiEndpoints.productReview(uuid)
            : ApiEndpoints.agentReview(uuid),
        data: {
          'rating': rating,
          'comment': comment,
          if (kind == ReviewKind.product) ...{'title': title, 'images': images},
        },
      ),
    ),
    kind,
  );

  Future<void> delete(ReviewKind kind, String uuid) => _client.dio.delete(
    kind == ReviewKind.product
        ? ApiEndpoints.productReview(uuid)
        : ApiEndpoints.agentReview(uuid),
  );
}
