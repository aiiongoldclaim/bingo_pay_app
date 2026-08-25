import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:bingo_pay/core/error/error_handler.dart';

import '../../data/models/member_ship_model.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/repositories/membership_repository.dart';

import 'membership_state.dart';


// ============================================================================
// MEMBERSHIP CUBIT
// ============================================================================

@injectable
class MembershipCubit
    extends Cubit<MembershipState> {
  final MembershipRepository _repository;

  MembershipCubit(
      this._repository,
      ) : super(
    const MembershipInitial(),
  );

  // ==========================================================================
  // EVENTS
  // ==========================================================================

  final StreamController<MembershipEvent>
  _events =
  StreamController<MembershipEvent>.broadcast();

  Stream<MembershipEvent> get events =>
      _events.stream;

  void _emitEvent(
      MembershipEvent event,
      ) {
    if (isClosed ||
        _events.isClosed) {
      return;
    }

    _events.add(event);
  }

  // ==========================================================================
  // LOAD
  // ==========================================================================

  /// First screen load.
  ///
  /// Shows full-screen loader.
  Future<void> load({
    String? preselectPlanUuid,
  }) async {
    if (state is MembershipLoading) {
      return;
    }

    emit(
      const MembershipLoading(),
    );

    await _fetch(
      preselectPlanUuid:
      preselectPlanUuid,
    );
  }

  // ==========================================================================
  // REFRESH
  // ==========================================================================

  /// Pull-to-refresh.
  ///
  /// Existing screen remains visible while API is loading.
  Future<void> refresh() async {
    await _fetch();
  }

  // ==========================================================================
  // FETCH MEMBERSHIP + PLANS
  // ==========================================================================

  Future<void> _fetch({
    String? preselectPlanUuid,

    /// When true, preserve the Renew button state
    /// after a successful Resume API.
    bool keepRenewState = false,
  }) async {
    final previous =
    state is MembershipLoaded
        ? state as MembershipLoaded
        : null;

    try {
      // ----------------------------------------------------------------------
      // API calls
      // ----------------------------------------------------------------------

      final membershipFuture =
      _repository.getMembership();

      final plansFuture =
      _repository.getPlans();

      // ----------------------------------------------------------------------
      // MEMBERSHIP
      // ----------------------------------------------------------------------

      final membership =
      await membershipFuture;

      // ----------------------------------------------------------------------
      // PLANS
      // ----------------------------------------------------------------------

      List<MembershipPlanOption> plans =
      const [];

      String? plansError;

      try {
        plans = await plansFuture;
      } on Exception catch (e) {
        plansError =
            ErrorHandler
                .mapExceptionToFailure(e)
                .message;

        // Keep old plans if refresh fails.
        plans =
            previous?.plans ??
                const [];
      }

      if (isClosed) {
        return;
      }

      // ----------------------------------------------------------------------
      // EMIT
      // ----------------------------------------------------------------------

      emit(
        MembershipLoaded(
          membership:
          membership,

          plans:
          plans,

          plansError:
          plansError,

          selectedPlanUuid:
          _initialSelection(
            plans,
            preselectPlanUuid ??
                previous
                    ?.selectedPlanUuid,
            membership,
          ),

          // IMPORTANT:
          // Resume ke baad Renew button state preserve hoga.
          showRenewAfterResume:
          keepRenewState
              ? (previous
              ?.showRenewAfterResume ??
              false)
              : false,
        ),
      );
    } on Exception catch (e) {
      if (isClosed) {
        return;
      }

      emit(
        MembershipError(
          ErrorHandler
              .mapExceptionToFailure(e),
        ),
      );
    }
  }

  // ==========================================================================
  // PLAN SELECTION
  // ==========================================================================

  void selectPlan(
      String planUuid,
      ) {
    final current = state;

    if (current
    is! MembershipLoaded) {
      return;
    }

    if (current.selectedPlanUuid ==
        planUuid) {
      return;
    }

    // Selecting another plan invalidates old quote.
    emit(
      current.copyWith(
        selectedPlanUuid:
        planUuid,
        clearQuote: true,
      ),
    );
  }

  // ==========================================================================
  // SUBSCRIBE
  // ==========================================================================

  /// Starts membership subscription.
  ///
  /// Success:
  /// 1. quote stored in state
  /// 2. MembershipQuoteCreated event emitted
  /// 3. Checkout screen can open
  Future<void> subscribe() async {
    final current = state;

    if (current
    is! MembershipLoaded ||
        current.isActionInProgress) {
      return;
    }

    final plan =
        current.selectedPlan;

    if (plan == null ||
        plan.uuid.isEmpty) {
      _emitEvent(
        const MembershipMessage(
          'Plan missing',
          isError: true,
        ),
      );

      return;
    }

    emit(
      current.copyWith(
        isSubscribing: true,
        clearQuote: true,
      ),
    );

    try {
      final quote =
      await _repository
          .subscribe(
        plan.uuid,
      );

      if (isClosed) {
        return;
      }

      emit(
        current.copyWith(
          isSubscribing: false,
          quote: quote,
        ),
      );

      _emitEvent(
        MembershipQuoteCreated(
          quote,
          plan,
        ),
      );
    } on Exception catch (e) {
      if (isClosed) {
        return;
      }

      final failure =
      ErrorHandler
          .mapExceptionToFailure(e);

      _emitEvent(
        MembershipMessage(
          failure.message,
          isError: true,
        ),
      );

      emit(
        current.copyWith(
          isSubscribing: false,
        ),
      );
    }
  }

  // ==========================================================================
  // CLEAR QUOTE
  // ==========================================================================

  void clearQuote() {
    final current = state;

    if (current
    is! MembershipLoaded ||
        current.quote == null) {
      return;
    }

    emit(
      current.copyWith(
        clearQuote: true,
      ),
    );
  }

  // ==========================================================================
  // CANCEL MEMBERSHIP
  // ==========================================================================

  Future<void> cancel(
      String subscriptionUuid,
      ) async {
    final current = state;

    if (current
    is! MembershipLoaded ||
        current.isActionInProgress) {
      return;
    }

    if (subscriptionUuid
        .trim()
        .isEmpty) {
      _emitEvent(
        const MembershipMessage(
          'Subscription missing',
          isError: true,
        ),
      );

      return;
    }

    emit(
      current.copyWith(
        isCancelling: true,
      ),
    );

    try {
      final result =
      await _repository.cancel(
        subscriptionUuid,
      );

      if (isClosed) {
        return;
      }

      // ---------------------------------------------------------------
      // Event
      // ---------------------------------------------------------------

      _emitEvent(
        MembershipCancelled(
          result,
        ),
      );

      _emitEvent(
        MembershipMessage(
          result.message.isEmpty
              ? 'Membership cancelled'
              : result.message,
        ),
      );

      // ---------------------------------------------------------------
      // Immediately stop loader
      // ---------------------------------------------------------------

      emit(
        current.copyWith(
          isCancelling: false,
        ),
      );

      // ---------------------------------------------------------------
      // Fresh membership
      // ---------------------------------------------------------------

      await _fetch();
    } on Exception catch (e) {
      if (isClosed) {
        return;
      }

      final failure =
      ErrorHandler
          .mapExceptionToFailure(e);

      _emitEvent(
        MembershipMessage(
          failure.message,
          isError: true,
        ),
      );

      emit(
        current.copyWith(
          isCancelling: false,
        ),
      );
    }
  }

  // ==========================================================================
  // CANCEL PENDING
  // ==========================================================================

  /// Used from checkout/pending flow.
  ///
  /// Does not change MembershipLoaded state.
  Future<bool> cancelPending(
      String subscriptionUuid,
      ) async {
    if (subscriptionUuid
        .trim()
        .isEmpty) {
      _emitEvent(
        const MembershipMessage(
          'Subscription missing',
          isError: true,
        ),
      );

      return false;
    }

    try {
      final result =
      await _repository.cancel(
        subscriptionUuid,
      );

      if (isClosed) {
        return false;
      }

      _emitEvent(
        MembershipCancelled(
          result,
        ),
      );

      _emitEvent(
        MembershipMessage(
          result.message.isEmpty
              ? 'Membership cancelled'
              : result.message,
        ),
      );

      return true;
    } on Exception catch (e) {
      if (isClosed) {
        return false;
      }

      final failure =
      ErrorHandler
          .mapExceptionToFailure(e);

      _emitEvent(
        MembershipMessage(
          failure.message,
          isError: true,
        ),
      );

      return false;
    }
  }

  // ==========================================================================
  // RESUME MEMBERSHIP
  // ==========================================================================

  Future<void> resumeMembership(
      String subscriptionUuid,
      ) async {
    final current = state;

    // Prevent duplicate resume requests.
    if (current
    is! MembershipLoaded ||
        current.isActionInProgress) {
      return;
    }

    if (subscriptionUuid
        .trim()
        .isEmpty) {
      _emitEvent(
        const MembershipMessage(
          'Subscription missing',
          isError: true,
        ),
      );

      return;
    }

    // ------------------------------------------------------------------------
    // START LOADING
    // ------------------------------------------------------------------------

    emit(
      current.copyWith(
        isResuming: true,
      ),
    );

    try {
      // ----------------------------------------------------------------------
      // RESUME API
      // ----------------------------------------------------------------------

      final result =
      await _repository.resume(
        subscriptionUuid,
      );

      if (isClosed) {
        return;
      }

      // ----------------------------------------------------------------------
      // RESUME SUCCESS EVENT
      // ----------------------------------------------------------------------

      _emitEvent(
        MembershipResumed(
          result,
        ),
      );

      _emitEvent(
        MembershipMessage(
          result.message.isEmpty
              ? 'Membership resumed successfully'
              : result.message,
        ),
      );

      // ----------------------------------------------------------------------
      // UPDATE CURRENT STATE
      // ----------------------------------------------------------------------

      emit(
        current.copyWith(
          isResuming: false,

          // This is important.
          // UI will now show Renew Plan.
          showRenewAfterResume: true,
        ),
      );

      // ----------------------------------------------------------------------
      // GET FRESH MEMBERSHIP
      // ----------------------------------------------------------------------

      await _fetch(
        keepRenewState: true,
      );
    } on Exception catch (e) {
      if (isClosed) {
        return;
      }

      final failure =
      ErrorHandler
          .mapExceptionToFailure(e);

      _emitEvent(
        MembershipMessage(
          failure.message,
          isError: true,
        ),
      );

      emit(
        current.copyWith(
          isResuming: false,
        ),
      );
    }
  }

  // ==========================================================================
  // BIGOD BALANCE + CONFIRM
  // ==========================================================================

  Future<void> payNow({
    required String token,
    required double requiredAmount,
  }) async {
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
      // ----------------------------------------------------------------------
      // 1. GET BALANCE
      // ----------------------------------------------------------------------

      final balance =
      await _repository
          .getBigodBalance();

      final availableBalance =
          balance.tokenBalance;

      // ----------------------------------------------------------------------
      // 2. CHECK BALANCE
      // ----------------------------------------------------------------------

      if (availableBalance <
          requiredAmount) {
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

      // ----------------------------------------------------------------------
      // 3. CONFIRM PAYMENT
      // ----------------------------------------------------------------------

      final result =
      await _repository
          .confirmBigodPayment(
        token,
      );

      if (isClosed) {
        return;
      }

      // ----------------------------------------------------------------------
      // 4. SUCCESS EVENT
      // ----------------------------------------------------------------------

      _emitEvent(
        MembershipPaymentConfirmed(
          result,
        ),
      );
    } on Exception catch (e) {
      if (isClosed) {
        return;
      }

      final failure =
      ErrorHandler
          .mapExceptionToFailure(e);

      _emitEvent(
        MembershipMessage(
          failure.message,
          isError: true,
        ),
      );
    }
  }

  // ==========================================================================
  // PLAN SELECTION HELPER
  // ==========================================================================

  /// Selection priority:
  ///
  /// 1. preselected plan
  /// 2. current membership plan
  /// 3. highlighted plan
  /// 4. first plan
  String? _initialSelection(
      List<MembershipPlanOption> plans,
      String? preselect,
      MembershipModel membership,
      ) {
    if (plans.isEmpty) {
      return null;
    }

    // ------------------------------------------------------------------------
    // Preselected plan
    // ------------------------------------------------------------------------

    if (preselect != null &&
        plans.any(
              (p) => p.uuid == preselect,
        )) {
      return preselect;
    }

    // ------------------------------------------------------------------------
    // Current membership plan
    // ------------------------------------------------------------------------

    final currentUuid =
        membership.plan?.uuid;

    if (currentUuid != null &&
        plans.any(
              (p) => p.uuid == currentUuid,
        )) {
      return currentUuid;
    }


    return plans
        .firstWhere(
          (p) => p.isHighlighted,
      orElse: () => plans.first,
    )
        .uuid;
  }

  @override
  Future<void> close() async {
    await _events.close();

    return super.close();
  }
}