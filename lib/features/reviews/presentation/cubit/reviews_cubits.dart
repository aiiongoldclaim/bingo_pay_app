import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasource/reviews_remote_datasource.dart';
import '../../data/models/review_models.dart';

/// Server wording when there is one, else [fallback].
String reviewErrorMessage(Object error, String fallback) {
  final failure = ErrorHandler.mapObjectToFailure(error);
  return failure is UnknownFailure ? fallback : failure.message;
}

/// Loading (both null), loaded ([data]) or failed ([error]).
class ReviewsLoad<T> {
  final T? data;
  final String? error;

  const ReviewsLoad({this.data, this.error});

  bool get loading => data == null && error == null;
}

/// What can be reviewed on one order (the order details section).
@injectable
class OrderReviewsCubit extends Cubit<ReviewsLoad<ReviewEligibility>> {
  final ReviewsRemoteDataSource _remote;

  OrderReviewsCubit(this._remote) : super(const ReviewsLoad());

  Future<void> load(String orderUuid) async {
    try {
      emit(ReviewsLoad(data: await _remote.eligibility(orderUuid)));
    } catch (e) {
      emit(
        ReviewsLoad(error: reviewErrorMessage(e, 'Could not load reviews.')),
      );
    }
  }
}

typedef MyReviews = ({List<Review> products, List<Review> agents});

/// "My reviews": product reviews and delivery ratings.
@injectable
class MyReviewsCubit extends Cubit<ReviewsLoad<MyReviews>> {
  final ReviewsRemoteDataSource _remote;

  MyReviewsCubit(this._remote) : super(const ReviewsLoad());

  Future<void> load() async {
    try {
      final results = await Future.wait([
        _remote.mine(ReviewKind.product),
        _remote.mine(ReviewKind.agent),
      ]);
      emit(ReviewsLoad(data: (products: results[0], agents: results[1])));
    } catch (e) {
      emit(
        ReviewsLoad(
          error: reviewErrorMessage(e, 'Could not load your reviews.'),
        ),
      );
    }
  }

  /// Deletes and reloads; returns an error message, or null on success.
  Future<String?> delete(Review review) async {
    try {
      await _remote.delete(review.kind, review.uuid);
      await load();
      return null;
    } catch (e) {
      return reviewErrorMessage(e, 'Could not delete the review.');
    }
  }
}

class ProductReviewsState {
  final ReviewSummary? summary;
  final List<Review> reviews;
  final int total;
  final bool loadingMore;
  final bool failed;

  const ProductReviewsState({
    this.summary,
    this.reviews = const [],
    this.total = 0,
    this.loadingMore = false,
    this.failed = false,
  });

  bool get hasMore => reviews.length < total;
}

/// Summary and approved reviews on the product page.
@injectable
class ProductReviewsCubit extends Cubit<ProductReviewsState> {
  final ReviewsRemoteDataSource _remote;
  static const pageSize = 5;
  late String _productUuid;
  int _page = 1;

  ProductReviewsCubit(this._remote) : super(const ProductReviewsState());

  Future<void> load(String productUuid) async {
    _productUuid = productUuid;
    _page = 1;
    try {
      final (summary, page) = await (
        _remote.summary(productUuid),
        _remote.productReviews(productUuid, limit: pageSize),
      ).wait;
      emit(
        ProductReviewsState(
          summary: summary,
          reviews: page.items,
          total: page.total,
        ),
      );
    } catch (_) {
      // The block falls back to the rating the product came with.
      emit(const ProductReviewsState(failed: true));
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    emit(
      ProductReviewsState(
        summary: state.summary,
        reviews: state.reviews,
        total: state.total,
        loadingMore: true,
      ),
    );
    try {
      final page = await _remote.productReviews(
        _productUuid,
        page: _page + 1,
        limit: pageSize,
      );
      _page++;
      emit(
        ProductReviewsState(
          summary: state.summary,
          reviews: [...state.reviews, ...page.items],
          total: page.total,
        ),
      );
    } catch (_) {
      emit(
        ProductReviewsState(
          summary: state.summary,
          reviews: state.reviews,
          total: state.total,
        ),
      );
    }
  }
}
