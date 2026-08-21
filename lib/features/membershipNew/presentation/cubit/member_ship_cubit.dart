import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

// TODO: apne project ke path ke hisaab se adjust karna
import 'package:bingo_pay/core/error/error_handler.dart';

import '../../data/repositories/membership_repository.dart';
import 'member_ship_state.dart';


import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bingo_pay/core/error/error_handler.dart';

import '../../data/repositories/membership_repository.dart';
import 'member_ship_state.dart';

// ===========================================================================
// GET /membership  +  cancel  +  resume
// ===========================================================================

@injectable
class MembershipCubit extends Cubit<MembershipState> {
  final MembershipRepository _repository;

  MembershipCubit(this._repository) : super(const MembershipInitial());

  final StreamController<MembershipEvent> _events =
  StreamController<MembershipEvent>.broadcast();

  Stream<MembershipEvent> get events => _events.stream;

  // ------------------------------------------------------------------ load

  Future<void> load() async {
    if (state is MembershipLoading) return;
    emit(const MembershipLoading());
    await _fetch();
  }

  Future<void> refresh() async {
    final current = state;
    if (current is MembershipLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else {
      emit(const MembershipLoading());
    }
    await _fetch();
  }

  Future<void> _fetch() async {
    try {
      final membership = await _repository.getMembership();
      if (isClosed) return;
      emit(MembershipLoaded(membership));
    } on Exception catch (e) {
      if (isClosed) return;
      emit(MembershipError(ErrorHandler.mapExceptionToFailure(e)));
    }
  }

  // ---------------------------------------------------------------- cancel

  Future<void> cancel(String subscriptionUuid) async {
    final current = state;
    if (current is! MembershipLoaded || current.isActionInProgress) return;

    emit(current.copyWith(isActionInProgress: true));
    try {
      final result = await _repository.cancel(subscriptionUuid);
      if (isClosed) return;
      _events.add(MembershipActionSuccess(result));
      await _fetch();
    } on Exception catch (e) {
      if (isClosed) return;
      _events.add(MembershipActionFailed(ErrorHandler.mapExceptionToFailure(e)));
      emit(current.copyWith(isActionInProgress: false));
    }
  }

  // ---------------------------------------------------------------- resume

  Future<void> resume(String subscriptionUuid) async {
    final current = state;
    if (current is! MembershipLoaded || current.isActionInProgress) return;

    emit(current.copyWith(isActionInProgress: true));
    try {
      final result = await _repository.resume(subscriptionUuid);
      if (isClosed) return;
      _events.add(MembershipActionSuccess(result));
      await _fetch();
    } on Exception catch (e) {
      if (isClosed) return;
      _events.add(MembershipActionFailed(ErrorHandler.mapExceptionToFailure(e)));
      emit(current.copyWith(isActionInProgress: false));
    }
  }

  @override
  Future<void> close() {
    _events.close();
    return super.close();
  }
}

// ===========================================================================
// POST /membership/subscribe  — CHECKOUT
// ===========================================================================

@injectable
class MembershipCheckoutCubit extends Cubit<MembershipCheckoutState> {
  final MembershipRepository _repository;

  MembershipCheckoutCubit(this._repository) : super(const CheckoutInitial());

  final StreamController<CheckoutMessage> _messages =
  StreamController<CheckoutMessage>.broadcast();

  /// Snackbar isse sunta hai
  Stream<CheckoutMessage> get messages => _messages.stream;

  Timer? _ticker;

  // ------------------------------------------------------------- subscribe

  Future<void> subscribe(String planUuid) async {
    if (state is CheckoutCreatingQuote) return;

    if (planUuid.isEmpty) {
      _messages.add(const CheckoutMessage('Plan missing', isError: true));
      return;
    }

    emit(const CheckoutCreatingQuote());

    try {
      final quote = await _repository.subscribe(planUuid);
      if (isClosed) return;

      emit(CheckoutQuoteReady(quote, timeLeft: quote.payment.timeLeft));
      _startTicker();

      _messages.add(
        CheckoutMessage(
          quote.message.isEmpty ? 'Payment quote created' : quote.message,
        ),
      );
    } on Exception catch (e) {
      if (isClosed) return;
      final failure = ErrorHandler.mapExceptionToFailure(e);
      _messages.add(CheckoutMessage(failure.message, isError: true));
      emit(const CheckoutInitial());
    }
  }

  /// Price expire hone par naya quote
  Future<void> retryQuote(String planUuid) {
    _ticker?.cancel();
    return subscribe(planUuid);
  }

  // ------------------------------------------------------------------ pay

  /// BIGOD wallet se pay.
  Future<void> pay() async {
    final current = state;
    if (current is! CheckoutQuoteReady || current.isPaying) return;

    if (current.isExpired) {
      _messages.add(
        const CheckoutMessage('This price has expired', isError: true),
      );
      return;
    }

    emit(current.copyWith(isPaying: true));

    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (isClosed) return;
    emit(current.copyWith(isPaying: false));
  }

  // --------------------------------------------------------------- ticker

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = state;
      if (isClosed || current is! CheckoutQuoteReady) return;
      emit(current.copyWith(timeLeft: current.quote.payment.timeLeft));
    });
  }

  @override
  Future<void> close() {
    _ticker?.cancel();
    _messages.close();
    return super.close();
  }
}

