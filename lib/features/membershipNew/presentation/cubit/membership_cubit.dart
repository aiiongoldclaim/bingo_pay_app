import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:bingo_pay/core/error/error_handler.dart';

import '../../data/models/member_ship_model.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/repositories/membership_repository.dart';
import 'membership_state.dart';


@injectable
class MembershipCubit extends Cubit<MembershipState> {
  final MembershipRepository _repository;

  MembershipCubit(this._repository) : super(const MembershipInitial());

  final StreamController<MembershipEvent> _events =
  StreamController<MembershipEvent>.broadcast();

  Stream<MembershipEvent> get events => _events.stream;

  // ------------------------------------------------------------------- load

  /// pehli baar — full screen loader
  Future<void> load({String? preselectPlanUuid}) async {
    if (state is MembershipLoading) return;
    emit(const MembershipLoading());
    await _fetch(preselectPlanUuid: preselectPlanUuid);
  }

  /// pull to refresh — loader nahi, purana data screen par rahega
  Future<void> refresh() => _fetch();

  Future<void> _fetch({String? preselectPlanUuid}) async {
    final previous = state is MembershipLoaded
        ? state as MembershipLoaded
        : null;

    try {
      // dono parallel
      final membershipFuture = _repository.getMembership();
      final plansFuture = _repository.getPlans();

      final membership = await membershipFuture;

      List<MembershipPlanOption> plans = const [];
      String? plansError;
      try {
        plans = await plansFuture;
      } on Exception catch (e) {
        // plans fail ho to bhi membership dikhana hai
        plansError = ErrorHandler.mapExceptionToFailure(e).message;
        plans = previous?.plans ?? const [];
      }

      if (isClosed) return;

      emit(
        MembershipLoaded(
          membership: membership,
          plans: plans,
          plansError: plansError,
          selectedPlanUuid: _initialSelection(
            plans,
            preselectPlanUuid ?? previous?.selectedPlanUuid,
            membership,
          ),
        ),
      );
    } on Exception catch (e) {
      if (isClosed) return;
      emit(MembershipError(ErrorHandler.mapExceptionToFailure(e)));
    }
  }

  // ----------------------------------------------------------- plan select

  void selectPlan(String planUuid) {
    final current = state;
    if (current is! MembershipLoaded) return;
    if (current.selectedPlanUuid == planUuid) return;

    // naya plan chuna -> purani quote invalid
    emit(current.copyWith(selectedPlanUuid: planUuid, clearQuote: true));
  }

  // -------------------------------------------------------------- subscribe

  /// Continue button. Success par state me quote aa jaata hai +
  /// MembershipQuoteCreated event jaata hai -> screen checkout push karti hai.
  Future<void> subscribe() async {
    final current = state;
    if (current is! MembershipLoaded || current.isActionInProgress) return;

    final plan = current.selectedPlan;
    if (plan == null || plan.uuid.isEmpty) {
      _events.add(const MembershipMessage('Plan missing', isError: true));
      return;
    }

    emit(current.copyWith(isSubscribing: true, clearQuote: true));

    try {
      final quote = await _repository.subscribe(plan.uuid);
      if (isClosed) return;

      emit(current.copyWith(isSubscribing: false, quote: quote));
      _events.add(MembershipQuoteCreated(quote, plan));
    } on Exception catch (e) {
      if (isClosed) return;
      final failure = ErrorHandler.mapExceptionToFailure(e);
      _events.add(MembershipMessage(failure.message, isError: true));
      emit(current.copyWith(isSubscribing: false));
    }
  }

  /// checkout se wapas aane par
  void clearQuote() {
    final current = state;
    if (current is! MembershipLoaded || current.quote == null) return;
    emit(current.copyWith(clearQuote: true));
  }

  // ----------------------------------------------------------------- cancel

  Future<void> cancel(String subscriptionUuid) async {
    final current = state;
    if (current is! MembershipLoaded || current.isActionInProgress) return;
    if (subscriptionUuid.isEmpty) {
      _events.add(
        const MembershipMessage('Subscription missing', isError: true),
      );
      return;
    }

    emit(current.copyWith(isCancelling: true));

    try {
      final result = await _repository.cancel(subscriptionUuid);
      if (isClosed) return;

      _events.add(MembershipCancelled(result));
      _events.add(
        MembershipMessage(
          result.message.isEmpty
              ? 'Membership cancelled'
              : result.message,
        ),
      );

      emit(current.copyWith(isCancelling: false));

      // fresh membership + plans
      await _fetch();
    } on Exception catch (e) {
      if (isClosed) return;
      final failure = ErrorHandler.mapExceptionToFailure(e);
      _events.add(MembershipMessage(failure.message, isError: true));
      emit(current.copyWith(isCancelling: false));
    }
  }

  // ---------------------------------------------------------------- helpers

  /// current plan pehle, phir preselect, phir highlighted, warna first
  String? _initialSelection(
      List<MembershipPlanOption> plans,
      String? preselect,
      MembershipModel membership,
      ) {
    if (plans.isEmpty) return null;

    if (preselect != null && plans.any((p) => p.uuid == preselect)) {
      return preselect;
    }

    final currentUuid = membership.plan?.uuid;
    if (currentUuid != null && plans.any((p) => p.uuid == currentUuid)) {
      return currentUuid;
    }

    return plans
        .firstWhere((p) => p.isHighlighted, orElse: () => plans.first)
        .uuid;
  }

  @override
  Future<void> close() {
    _events.close();
    return super.close();
  }


  Future<bool> cancelPending(
      String subscriptionUuid,
      ) async {
    if (subscriptionUuid.trim().isEmpty) {
      _emitEvent(
        const MembershipMessage(
          'Subscription missing',
          isError: true,
        ),
      );

      return false;
    }

    try {
      print(
        '========== CANCEL MEMBERSHIP START ==========',
      );

      print(
        'Subscription UUID: $subscriptionUuid',
      );

      final result =
      await _repository.cancel(
        subscriptionUuid,
      );

      print(
        'Cancel API success',
      );

      _emitEvent(
        MembershipCancelled(result),
      );

      _emitEvent(
        MembershipMessage(
          result.message.isEmpty
              ? 'Membership cancelled'
              : result.message,
        ),
      );

      print(
        '========== CANCEL MEMBERSHIP END ==========',
      );

      return true;
    } on Exception catch (e, stackTrace) {
      print(
        '========== CANCEL MEMBERSHIP ERROR ==========',
      );

      print(e);
      print(stackTrace);

      final failure =
      ErrorHandler.mapExceptionToFailure(e);

      _emitEvent(
        MembershipMessage(
          failure.message,
          isError: true,
        ),
      );

      return false;
    }
  }

  void _emitEvent(MembershipEvent event) {
    if (isClosed || _events.isClosed) return;
    _events.add(event);
  }

  Future<void> payNow({
    required String token,
    required double requiredAmount,
  }) async {
    print('========== BIGOD PAYMENT START ==========');
    print('Token: $token');
    print('Required amount: $requiredAmount');

    if (token.trim().isEmpty) {
      _emitEvent(
        const MembershipMessage(
          'Payment token is missing',
          isError: true,
        ),
      );
      return;
    }

    if (requiredAmount <= 0) {
      _emitEvent(
        const MembershipMessage(
          'Invalid payment amount',
          isError: true,
        ),
      );
      return;
    }

    try {
      // ---------------------------------------------------------
      // 1. GET BIGOD BALANCE
      // ---------------------------------------------------------

      print('Calling BIGOD balance API...');

      final balance =
      await _repository.getBigodBalance();

      final availableBalance =
          balance.tokenBalance;

      print(
        'Available BIGOD: $availableBalance',
      );

      print(
        'Required BIGOD: $requiredAmount',
      );

      // ---------------------------------------------------------
      // 2. CHECK BIGOD BALANCE
      // ---------------------------------------------------------

      if (availableBalance < requiredAmount) {
        print('Insufficient BIGOD balance');

        _emitEvent(
          MembershipMessage(
            'Insufficient BIGOD balance. '
                'Available: '
                '${availableBalance.toStringAsFixed(6)} BIGOD',
            isError: true,
          ),
        );

        return;
      }

      print('BIGOD balance sufficient');

      // ---------------------------------------------------------
      // 3. CONFIRM PAYMENT
      // ---------------------------------------------------------

      print('Calling BIGOD confirm API...');

      final result =
      await _repository.confirmBigodPayment(
        token,
      );

      print(
        'Confirm status: '
            '${result.subscriptionStatus}',
      );

      if (isClosed) return;

      // ---------------------------------------------------------
      // 4. PAYMENT SUCCESS EVENT
      // ---------------------------------------------------------

      _emitEvent(
        MembershipPaymentConfirmed(result),
      );

      print(
        'MembershipPaymentConfirmed emitted',
      );

      print(
        '========== BIGOD PAYMENT END ==========',
      );
    } on Exception catch (e, stackTrace) {
      print(
        '========== BIGOD PAYMENT ERROR ==========',
      );

      print(e);
      print(stackTrace);

      if (isClosed) return;

      final failure =
      ErrorHandler.mapExceptionToFailure(e);

      _emitEvent(
        MembershipMessage(
          failure.message,
          isError: true,
        ),
      );
    }
  }


}