import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../data/datasource/refund_requests_remote_datasource.dart';
import '../../data/models/refund_request_model.dart';
import 'refund_requests_cubit.dart';

const maxRefundPhotos = 6;

class RefundFormState {
  final RefundEligibility? eligibility;
  final String? loadError;

  /// orderItemId → units asked for (0 = not picked).
  final Map<String, int> picked;
  final String? reasonCode;
  final List<String> photos;
  final bool uploading;
  final bool submitting;

  /// One-shot error to show; cleared by the next change.
  final String? error;

  /// Set once the request was sent: the server's confirmation.
  final String? sentMessage;

  const RefundFormState({
    this.eligibility,
    this.loadError,
    this.picked = const {},
    this.reasonCode,
    this.photos = const [],
    this.uploading = false,
    this.submitting = false,
    this.error,
    this.sentMessage,
  });

  RefundFormState copyWith({
    Map<String, int>? picked,
    String? reasonCode,
    List<String>? photos,
    bool? uploading,
    bool? submitting,
    String? error,
    String? sentMessage,
  }) => RefundFormState(
    eligibility: eligibility,
    loadError: loadError,
    picked: picked ?? this.picked,
    reasonCode: reasonCode ?? this.reasonCode,
    photos: photos ?? this.photos,
    uploading: uploading ?? this.uploading,
    submitting: submitting ?? this.submitting,
    error: error,
    sentMessage: sentMessage ?? this.sentMessage,
  );

  List<RefundLine> get lines => eligibility?.lines ?? const [];

  List<RefundLine> get selected =>
      lines.where((l) => (picked[l.orderItemId] ?? 0) > 0).toList();

  /// Reasons every picked line allows: one reason covers the whole request.
  List<RefundReason> get reasons {
    final pool = selected.isNotEmpty
        ? selected
        : lines.where((l) => l.eligible).toList();
    if (pool.isEmpty) return const [];
    return pool.first.reasons
        .where((r) => pool.every((l) => l.reasons.any((x) => x.code == r.code)))
        .toList();
  }

  RefundReason? get reason {
    for (final r in reasons) {
      if (r.code == reasonCode) return r;
    }
    return null;
  }

  double get estimate => selected.fold(
    0,
    (sum, l) => sum + l.valueOf(picked[l.orderItemId] ?? 0),
  );

  /// Highest restocking fee that may be kept, when the reason charges one.
  double get restockPercent => reason?.customerPaysCharges == true
      ? selected.fold(0, (m, l) => math.max(m, l.restockingFeePercent))
      : 0;

  /// What still blocks sending, or null when the request can go.
  String? get problem {
    if (selected.isEmpty) return 'Pick at least one item.';
    if (reasons.isEmpty) {
      return 'These items cannot be refunded for the same reason. Send them as separate requests.';
    }
    if (reason == null) return 'Pick a reason.';
    if (reason!.requiresEvidence && photos.isEmpty) {
      return 'Add at least one photo for this reason.';
    }
    return null;
  }
}

/// Asking for a refund on one order: pick lines, a reason, photos, send.
@injectable
class RefundFormCubit extends Cubit<RefundFormState> {
  final RefundRequestsRemoteDataSource _remote;

  RefundFormCubit(this._remote) : super(const RefundFormState());

  Future<void> load(String orderUuid) async {
    try {
      emit(RefundFormState(eligibility: await _remote.eligibility(orderUuid)));
    } catch (e) {
      emit(RefundFormState(
        loadError: refundErrorMessage(e, 'Could not check this order.'),
      ));
    }
  }

  void toggle(RefundLine line) {
    if (!line.eligible) return;
    final picked = {...state.picked};
    picked[line.orderItemId] =
        (picked[line.orderItemId] ?? 0) > 0 ? 0 : line.maxQuantity;
    emit(state.copyWith(picked: picked));
  }

  void setQuantity(RefundLine line, int quantity) {
    if (line.maxQuantity < 1) return;
    emit(state.copyWith(
      picked: {
        ...state.picked,
        line.orderItemId: quantity.clamp(1, line.maxQuantity),
      },
    ));
  }

  void setReason(String code) => emit(state.copyWith(reasonCode: code));

  Future<void> addPhoto(XFile file) async {
    if (state.uploading || state.photos.length >= maxRefundPhotos) return;
    emit(state.copyWith(uploading: true));
    try {
      final url = await _remote.uploadEvidence(file);
      emit(state.copyWith(photos: [...state.photos, url], uploading: false));
    } catch (e) {
      emit(state.copyWith(
        uploading: false,
        error: refundErrorMessage(e, 'The photo could not be uploaded.'),
      ));
    }
  }

  void removePhoto(String url) => emit(
    state.copyWith(photos: state.photos.where((p) => p != url).toList()),
  );

  Future<void> submit(String orderUuid, String description) async {
    if (state.problem != null || state.submitting || state.uploading) return;
    emit(state.copyWith(submitting: true));
    try {
      final message = await _remote.create(
        orderUuid,
        items: {
          for (final l in state.selected) l.orderItemId: state.picked[l.orderItemId]!,
        },
        reasonCode: state.reason!.code,
        description: description.trim(),
        evidence: state.photos,
      );
      emit(state.copyWith(submitting: false, sentMessage: message));
    } catch (e) {
      emit(state.copyWith(
        submitting: false,
        error: refundErrorMessage(e, 'The request could not be sent.'),
      ));
    }
  }
}
