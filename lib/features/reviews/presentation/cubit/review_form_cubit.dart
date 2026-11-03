import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasource/reviews_remote_datasource.dart';
import '../../data/models/review_models.dart';
import 'reviews_cubits.dart';

const maxReviewPhotos = 5;

/// What the review form writes about, and the review when editing.
class ReviewFormArgs {
  final ReviewKind kind;

  /// Product title or "Delivery by …", shown on the form.
  final String subject;

  /// Product review: the delivered order line.
  final String? orderItemId;

  /// Delivery rating: the agent and the delivered vendor order.
  final String? agentUuid;
  final String? vendorOrderUuid;

  /// Editing with the full review in hand (My Reviews)…
  final Review? review;

  /// …or with only its uuid (the order page knows no more).
  final String? reviewUuid;

  const ReviewFormArgs({
    required this.kind,
    required this.subject,
    this.orderItemId,
    this.agentUuid,
    this.vendorOrderUuid,
    this.review,
    this.reviewUuid,
  });
}

class ReviewFormState {
  final bool loading;
  final String? loadError;
  final Review? existing;
  final int rating;
  final List<String> images;
  final bool uploading;
  final bool busy;

  /// One-shot error to show; cleared by the next change.
  final String? error;

  /// Set once saved or deleted: the screen closes with it.
  final String? doneMessage;

  const ReviewFormState({
    this.loading = false,
    this.loadError,
    this.existing,
    this.rating = 0,
    this.images = const [],
    this.uploading = false,
    this.busy = false,
    this.error,
    this.doneMessage,
  });

  ReviewFormState copyWith({
    int? rating,
    List<String>? images,
    bool? uploading,
    bool? busy,
    String? error,
    String? doneMessage,
  }) => ReviewFormState(
    existing: existing,
    rating: rating ?? this.rating,
    images: images ?? this.images,
    uploading: uploading ?? this.uploading,
    busy: busy ?? this.busy,
    error: error,
    doneMessage: doneMessage,
  );

  /// An existing review past its edit window can only be deleted.
  bool get canSave => existing == null || existing!.canEdit;
}

/// Write, edit or delete one product review or delivery rating.
@injectable
class ReviewFormCubit extends Cubit<ReviewFormState> {
  final ReviewsRemoteDataSource _remote;
  late ReviewFormArgs _args;

  ReviewFormCubit(this._remote) : super(const ReviewFormState(loading: true));

  Future<void> start(ReviewFormArgs args) async {
    _args = args;
    var review = args.review;
    if (review == null && args.reviewUuid != null) {
      emit(const ReviewFormState(loading: true));
      try {
        // No get-by-id route: find it in my reviews.
        review = (await _remote.mine(
          args.kind,
        )).where((r) => r.uuid == args.reviewUuid).firstOrNull;
        if (review == null) {
          emit(
            const ReviewFormState(
              loadError: 'This review is no longer available.',
            ),
          );
          return;
        }
      } catch (e) {
        emit(
          ReviewFormState(
            loadError: reviewErrorMessage(e, 'Could not load the review.'),
          ),
        );
        return;
      }
    }
    emit(
      ReviewFormState(
        existing: review,
        rating: review?.rating ?? 0,
        images: review?.images ?? const [],
      ),
    );
  }

  void setRating(int rating) => emit(state.copyWith(rating: rating));

  Future<void> addPhotos(List<XFile> files) async {
    final room = maxReviewPhotos - state.images.length;
    if (state.uploading || room <= 0 || files.isEmpty) return;
    emit(state.copyWith(uploading: true));
    try {
      final urls = await _remote.uploadImages(files.take(room).toList());
      emit(
        state.copyWith(images: [...state.images, ...urls], uploading: false),
      );
    } catch (e) {
      emit(
        state.copyWith(
          uploading: false,
          error: reviewErrorMessage(e, 'The photos could not be uploaded.'),
        ),
      );
    }
  }

  void removePhoto(String url) => emit(
    state.copyWith(images: state.images.where((u) => u != url).toList()),
  );

  Future<void> submit({String title = '', required String comment}) async {
    if (state.busy || state.uploading || !state.canSave) return;
    if (state.rating < 1) {
      emit(state.copyWith(error: 'Pick a rating from 1 to 5 stars.'));
      return;
    }
    final t = title.trim().isEmpty ? null : title.trim();
    final c = comment.trim().isEmpty ? null : comment.trim();
    emit(state.copyWith(busy: true));
    try {
      final existing = state.existing;
      if (existing != null) {
        await _remote.update(
          _args.kind,
          existing.uuid,
          rating: state.rating,
          title: t,
          comment: c,
          images: state.images,
        );
      } else if (_args.kind == ReviewKind.product) {
        await _remote.createProductReview(
          orderItemId: _args.orderItemId!,
          rating: state.rating,
          title: t,
          comment: c,
          images: state.images,
        );
      } else {
        await _remote.createAgentReview(
          agentUuid: _args.agentUuid!,
          vendorOrderUuid: _args.vendorOrderUuid!,
          rating: state.rating,
          comment: c,
        );
      }
      emit(
        state.copyWith(
          busy: false,
          doneMessage: existing != null
              ? 'Review updated'
              : 'Thanks for your review',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          busy: false,
          error: reviewErrorMessage(e, 'The review could not be saved.'),
        ),
      );
    }
  }

  Future<void> delete() async {
    final existing = state.existing;
    if (existing == null || state.busy) return;
    emit(state.copyWith(busy: true));
    try {
      await _remote.delete(_args.kind, existing.uuid);
      emit(state.copyWith(busy: false, doneMessage: 'Review deleted'));
    } catch (e) {
      emit(
        state.copyWith(
          busy: false,
          error: reviewErrorMessage(e, 'Could not delete the review.'),
        ),
      );
    }
  }
}
