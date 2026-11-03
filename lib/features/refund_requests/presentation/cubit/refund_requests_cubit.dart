import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../data/datasource/refund_requests_remote_datasource.dart';
import '../../data/models/refund_request_model.dart';

/// Server wording when there is one, else [fallback].
String refundErrorMessage(Object error, String fallback) {
  final failure = ErrorHandler.mapObjectToFailure(error);
  return failure is UnknownFailure ? fallback : failure.message;
}

sealed class RefundRequestsState {
  const RefundRequestsState();
}

class RefundRequestsLoading extends RefundRequestsState {
  const RefundRequestsLoading();
}

class RefundListLoaded extends RefundRequestsState {
  final List<RefundRequestModel> items;
  const RefundListLoaded(this.items);
}

class RefundDetailLoaded extends RefundRequestsState {
  final RefundRequestModel request;
  const RefundDetailLoaded(this.request);
}

class RefundRequestsError extends RefundRequestsState {
  final String message;
  const RefundRequestsError(this.message);
}

/// "My refunds" list and one request's detail.
@injectable
class RefundRequestsCubit extends Cubit<RefundRequestsState> {
  final RefundRequestsRemoteDataSource _remote;

  RefundRequestsCubit(this._remote) : super(const RefundRequestsLoading());

  Future<void> loadMine() async {
    emit(const RefundRequestsLoading());
    try {
      emit(RefundListLoaded(await _remote.mine()));
    } catch (e) {
      emit(RefundRequestsError(
        refundErrorMessage(e, 'Could not load your refunds.'),
      ));
    }
  }

  Future<void> loadDetail(String uuid) async {
    emit(const RefundRequestsLoading());
    try {
      emit(RefundDetailLoaded(await _remote.detail(uuid)));
    } catch (e) {
      emit(RefundRequestsError(
        refundErrorMessage(e, 'Could not load the request.'),
      ));
    }
  }

  /// Withdraws the request; returns an error message, or null on success.
  Future<String?> cancel(String uuid) async {
    try {
      emit(RefundDetailLoaded(await _remote.cancel(uuid)));
      return null;
    } catch (e) {
      return refundErrorMessage(e, 'Could not withdraw the request.');
    }
  }
}
