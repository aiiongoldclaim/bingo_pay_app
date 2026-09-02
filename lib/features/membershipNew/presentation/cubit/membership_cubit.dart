// import 'dart:async';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:injectable/injectable.dart';
//
// import 'package:bingo_pay/core/error/error_handler.dart';
//
// import '../../data/models/member_ship_model.dart';
// import '../../data/models/membership_plan_model.dart';
// import '../../data/repositories/membership_repository.dart';
//
// import 'membership_state.dart';
//
// @injectable
// class MembershipCubit
//     extends Cubit<MembershipState> {
//   final MembershipRepository _repository;
//
//   MembershipCubit(
//       this._repository,
//       ) : super(
//     const MembershipInitial(),
//   );
//
//   final StreamController<MembershipEvent>
//   _events =
//   StreamController<MembershipEvent>.broadcast();
//
//   Stream<MembershipEvent> get events =>
//       _events.stream;
//
//   void _emitEvent(
//       MembershipEvent event,
//       ) {
//     if (isClosed ||
//         _events.isClosed) {
//       return;
//     }
//
//     _events.add(event);
//   }
//
//   Future<void> load({
//     String? preselectPlanUuid,
//   }) async {
//     if (state is MembershipLoading) {
//       return;
//     }
//
//     emit(
//       const MembershipLoading(),
//     );
//
//     await _fetch(
//       preselectPlanUuid:
//       preselectPlanUuid,
//     );
//   }
//
//   // ==========================================================================
//   // REFRESH
//   // ==========================================================================
//
//   /// Pull-to-refresh.
//   ///
//   /// Existing screen remains visible while API is loading.
//   Future<void> refresh() async {
//     await _fetch();
//   }
//
//   // ==========================================================================
//   // FETCH MEMBERSHIP + PLANS
//   // ==========================================================================
//
//   Future<void> _fetch({
//     String? preselectPlanUuid,
//
//     /// When true, preserve the Renew button state
//     /// after a successful Resume API.
//     bool keepRenewState = false,
//   }) async {
//     final previous =
//     state is MembershipLoaded
//         ? state as MembershipLoaded
//         : null;
//
//     try {
//
//       final membershipFuture =
//       _repository.getMembership();
//
//       final plansFuture =
//       _repository.getPlans();
//
//       final membership =
//       await membershipFuture;
//
//
//       List<MembershipPlanOption> plans =
//       const [];
//
//       String? plansError;
//
//       try {
//         plans = await plansFuture;
//       } on Exception catch (e) {
//         plansError =
//             ErrorHandler
//                 .mapExceptionToFailure(e)
//                 .message;
//
//         // Keep old plans if refresh fails.
//         plans =
//             previous?.plans ??
//                 const [];
//       }
//
//       if (isClosed) {
//         return;
//       }
//
//       emit(
//         MembershipLoaded(
//           membership:
//           membership,
//
//           plans:
//           plans,
//
//           plansError:
//           plansError,
//
//           selectedPlanUuid:
//           _initialSelection(
//             plans,
//             preselectPlanUuid ??
//                 previous
//                     ?.selectedPlanUuid,
//             membership,
//           ),
//
//           // IMPORTANT:
//           // Resume ke baad Renew button state preserve hoga.
//           showRenewAfterResume:
//           keepRenewState
//               ? (previous
//               ?.showRenewAfterResume ??
//               false)
//               : false,
//         ),
//       );
//     } on Exception catch (e) {
//       if (isClosed) {
//         return;
//       }
//
//       emit(
//         MembershipError(
//           ErrorHandler
//               .mapExceptionToFailure(e),
//         ),
//       );
//     }
//   }
//
//   // ==========================================================================
//   // PLAN SELECTION
//   // ==========================================================================
//
//   void selectPlan(
//       String planUuid,
//       ) {
//     final current = state;
//
//     if (current
//     is! MembershipLoaded) {
//       return;
//     }
//
//     if (current.selectedPlanUuid ==
//         planUuid) {
//       return;
//     }
//
//     // Selecting another plan invalidates old quote.
//     emit(
//       current.copyWith(
//         selectedPlanUuid:
//         planUuid,
//         clearQuote: true,
//       ),
//     );
//   }
//
//   // ==========================================================================
//   // SUBSCRIBE
//   // ==========================================================================
//
//   /// Starts membership subscription.
//   ///
//   /// Success:
//   /// 1. quote stored in state
//   /// 2. MembershipQuoteCreated event emitted
//   /// 3. Checkout screen can open
//   Future<void> subscribe() async {
//     final current = state;
//
//     if (current
//     is! MembershipLoaded ||
//         current.isActionInProgress) {
//       return;
//     }
//
//     final plan =
//         current.selectedPlan;
//
//     if (plan == null ||
//         plan.uuid.isEmpty) {
//       _emitEvent(
//         const MembershipMessage(
//           'Plan missing',
//           isError: true,
//         ),
//       );
//
//       return;
//     }
//
//     emit(
//       current.copyWith(
//         isSubscribing: true,
//         clearQuote: true,
//       ),
//     );
//
//     try {
//       final quote =
//       await _repository
//           .subscribe(
//         plan.uuid,
//       );
//
//       if (isClosed) {
//         return;
//       }
//
//       emit(
//         current.copyWith(
//           isSubscribing: false,
//           quote: quote,
//         ),
//       );
//
//       _emitEvent(
//         MembershipQuoteCreated(
//           quote,
//           plan,
//         ),
//       );
//     } on Exception catch (e) {
//       if (isClosed) {
//         return;
//       }
//
//       final failure =
//       ErrorHandler
//           .mapExceptionToFailure(e);
//
//       _emitEvent(
//         MembershipMessage(
//           failure.message,
//           isError: true,
//         ),
//       );
//
//       emit(
//         current.copyWith(
//           isSubscribing: false,
//         ),
//       );
//     }
//   }
//
//   // ==========================================================================
//   // CLEAR QUOTE
//   // ==========================================================================
//
//   void clearQuote() {
//     final current = state;
//
//     if (current
//     is! MembershipLoaded ||
//         current.quote == null) {
//       return;
//     }
//
//     emit(
//       current.copyWith(
//         clearQuote: true,
//       ),
//     );
//   }
//
//   // ==========================================================================
//   // CANCEL MEMBERSHIP
//   // ==========================================================================
//
//   Future<void> cancel(
//       String subscriptionUuid,
//       ) async {
//     final current = state;
//
//     if (current
//     is! MembershipLoaded ||
//         current.isActionInProgress) {
//       return;
//     }
//
//     if (subscriptionUuid
//         .trim()
//         .isEmpty) {
//       _emitEvent(
//         const MembershipMessage(
//           'Subscription missing',
//           isError: true,
//         ),
//       );
//
//       return;
//     }
//
//     emit(
//       current.copyWith(
//         isCancelling: true,
//       ),
//     );
//
//     try {
//       final result =
//       await _repository.cancel(
//         subscriptionUuid,
//       );
//
//       if (isClosed) {
//         return;
//       }
//
//       // ---------------------------------------------------------------
//       // Event
//       // ---------------------------------------------------------------
//
//       _emitEvent(
//         MembershipCancelled(
//           result,
//         ),
//       );
//
//       _emitEvent(
//         MembershipMessage(
//           result.message.isEmpty
//               ? 'Membership cancelled'
//               : result.message,
//         ),
//       );
//
//       // ---------------------------------------------------------------
//       // Immediately stop loader
//       // ---------------------------------------------------------------
//
//       emit(
//         current.copyWith(
//           isCancelling: false,
//         ),
//       );
//
//       // ---------------------------------------------------------------
//       // Fresh membership
//       // ---------------------------------------------------------------
//
//       await _fetch();
//     } on Exception catch (e) {
//       if (isClosed) {
//         return;
//       }
//
//       final failure =
//       ErrorHandler
//           .mapExceptionToFailure(e);
//
//       _emitEvent(
//         MembershipMessage(
//           failure.message,
//           isError: true,
//         ),
//       );
//
//       emit(
//         current.copyWith(
//           isCancelling: false,
//         ),
//       );
//     }
//   }
//
//   // ==========================================================================
//   // CANCEL PENDING
//   // ==========================================================================
//
//   /// Used from checkout/pending flow.
//   ///
//   /// Does not change MembershipLoaded state.
//   Future<bool> cancelPending(
//       String subscriptionUuid,
//       ) async {
//     if (subscriptionUuid
//         .trim()
//         .isEmpty) {
//       _emitEvent(
//         const MembershipMessage(
//           'Subscription missing',
//           isError: true,
//         ),
//       );
//
//       return false;
//     }
//
//     try {
//       final result =
//       await _repository.cancel(
//         subscriptionUuid,
//       );
//
//       if (isClosed) {
//         return false;
//       }
//
//       _emitEvent(
//         MembershipCancelled(
//           result,
//         ),
//       );
//
//       _emitEvent(
//         MembershipMessage(
//           result.message.isEmpty
//               ? 'Membership cancelled'
//               : result.message,
//         ),
//       );
//
//       return true;
//     } on Exception catch (e) {
//       if (isClosed) {
//         return false;
//       }
//
//       final failure =
//       ErrorHandler
//           .mapExceptionToFailure(e);
//
//       _emitEvent(
//         MembershipMessage(
//           failure.message,
//           isError: true,
//         ),
//       );
//
//       return false;
//     }
//   }
//
//   // ==========================================================================
//   // RESUME MEMBERSHIP
//   // ==========================================================================
//
//   Future<void> resumeMembership(
//       String subscriptionUuid,
//       ) async {
//     final current = state;
//
//     // Prevent duplicate resume requests.
//     if (current
//     is! MembershipLoaded ||
//         current.isActionInProgress) {
//       return;
//     }
//
//     if (subscriptionUuid
//         .trim()
//         .isEmpty) {
//       _emitEvent(
//         const MembershipMessage(
//           'Subscription missing',
//           isError: true,
//         ),
//       );
//
//       return;
//     }
//
//     // ------------------------------------------------------------------------
//     // START LOADING
//     // ------------------------------------------------------------------------
//
//     emit(
//       current.copyWith(
//         isResuming: true,
//       ),
//     );
//
//     try {
//       // ----------------------------------------------------------------------
//       // RESUME API
//       // ----------------------------------------------------------------------
//
//       final result =
//       await _repository.resume(
//         subscriptionUuid,
//       );
//
//       if (isClosed) {
//         return;
//       }
//
//       // ----------------------------------------------------------------------
//       // RESUME SUCCESS EVENT
//       // ----------------------------------------------------------------------
//
//       _emitEvent(
//         MembershipResumed(
//           result,
//         ),
//       );
//
//       _emitEvent(
//         MembershipMessage(
//           result.message.isEmpty
//               ? 'Membership resumed successfully'
//               : result.message,
//         ),
//       );
//
//       // ----------------------------------------------------------------------
//       // UPDATE CURRENT STATE
//       // ----------------------------------------------------------------------
//
//       emit(
//         current.copyWith(
//           isResuming: false,
//
//           // This is important.
//           // UI will now show Renew Plan.
//           showRenewAfterResume: true,
//         ),
//       );
//
//       // ----------------------------------------------------------------------
//       // GET FRESH MEMBERSHIP
//       // ----------------------------------------------------------------------
//
//       await _fetch(
//         keepRenewState: true,
//       );
//     } on Exception catch (e) {
//       if (isClosed) {
//         return;
//       }
//
//       final failure =
//       ErrorHandler
//           .mapExceptionToFailure(e);
//
//       _emitEvent(
//         MembershipMessage(
//           failure.message,
//           isError: true,
//         ),
//       );
//
//       emit(
//         current.copyWith(
//           isResuming: false,
//         ),
//       );
//     }
//   }
//
//   // ==========================================================================
//   // BIGOD BALANCE + CONFIRM
//   // ==========================================================================
//
//   Future<void> payNow({
//     required String token,
//     required double requiredAmount,
//   }) async {
//     if (token.trim().isEmpty) {
//       _emitEvent(
//         const MembershipMessage(
//           'Payment token is missing',
//           isError: true,
//         ),
//       );
//
//       return;
//     }
//
//     if (requiredAmount <= 0) {
//       _emitEvent(
//         const MembershipMessage(
//           'Invalid payment amount',
//           isError: true,
//         ),
//       );
//
//       return;
//     }
//
//     try {
//       // ----------------------------------------------------------------------
//       // 1. GET BALANCE
//       // ----------------------------------------------------------------------
//
//       final balance =
//       await _repository
//           .getBigodBalance();
//
//       final availableBalance =
//           balance.tokenBalance;
//
//       // ----------------------------------------------------------------------
//       // 2. CHECK BALANCE
//       // ----------------------------------------------------------------------
//
//       if (availableBalance <
//           requiredAmount) {
//         _emitEvent(
//           MembershipMessage(
//             'Insufficient BIGOD balance. '
//                 'Available: '
//                 '${availableBalance.toStringAsFixed(6)} BIGOD',
//             isError: true,
//           ),
//         );
//
//         return;
//       }
//
//       // ----------------------------------------------------------------------
//       // 3. CONFIRM PAYMENT
//       // ----------------------------------------------------------------------
//
//       final result =
//       await _repository
//           .confirmBigodPayment(
//         token,
//       );
//
//       if (isClosed) {
//         return;
//       }
//
//       // ----------------------------------------------------------------------
//       // 4. SUCCESS EVENT
//       // ----------------------------------------------------------------------
//
//       _emitEvent(
//         MembershipPaymentConfirmed(
//           result,
//         ),
//       );
//     } on Exception catch (e) {
//       if (isClosed) {
//         return;
//       }
//
//       final failure =
//       ErrorHandler
//           .mapExceptionToFailure(e);
//
//       _emitEvent(
//         MembershipMessage(
//           failure.message,
//           isError: true,
//         ),
//       );
//     }
//   }
//
//   // ==========================================================================
//   // PLAN SELECTION HELPER
//   // ==========================================================================
//
//   /// Selection priority:
//   ///
//   /// 1. preselected plan
//   /// 2. current membership plan
//   /// 3. highlighted plan
//   /// 4. first plan
//   String? _initialSelection(
//       List<MembershipPlanOption> plans,
//       String? preselect,
//       MembershipModel membership,
//       ) {
//     if (plans.isEmpty) {
//       return null;
//     }
//
//     // ------------------------------------------------------------------------
//     // Preselected plan
//     // ------------------------------------------------------------------------
//
//     if (preselect != null &&
//         plans.any(
//               (p) => p.uuid == preselect,
//         )) {
//       return preselect;
//     }
//
//     // ------------------------------------------------------------------------
//     // Current membership plan
//     // ------------------------------------------------------------------------
//
//     final currentUuid =
//         membership.plan?.uuid;
//
//     if (currentUuid != null &&
//         plans.any(
//               (p) => p.uuid == currentUuid,
//         )) {
//       return currentUuid;
//     }
//
//
//     return plans
//         .firstWhere(
//           (p) => p.isHighlighted,
//       orElse: () => plans.first,
//     )
//         .uuid;
//   }
//
//   @override
//   Future<void> close() async {
//     await _events.close();
//
//     return super.close();
//   }
// }
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

  void _emitEvent(MembershipEvent event) {
    if (isClosed || _events.isClosed) return;

    _events.add(event);
  }

  MembershipLoaded? get _loadedState {
    final current = state;

    if (current is MembershipLoaded) return current;
    if (current is MembershipRefreshing) return current.previous;

    return null;
  }

  Future<void> load({String? preselectPlanUuid}) async {
    if (state is MembershipLoading || state is MembershipRefreshing) {
      return;
    }

    emit(const MembershipLoading());

    await _fetch(
      preselectPlanUuid: preselectPlanUuid,
      isRefresh: false,
    );
  }

  Future<void> refresh() async {
    final previous = _loadedState;

    if (previous == null) {
      await load();
      return;
    }

    if (state is MembershipRefreshing || previous.isActionInProgress) {
      return;
    }

    emit(MembershipRefreshing(previous));

    await _fetch(isRefresh: true);
  }

  Future<void> _fetch({
    String? preselectPlanUuid,
    bool keepRenewState = false,
    bool isRefresh = false,
  }) async {
    final previous = _loadedState;

    try {
      final membershipFuture = _repository.getMembership();
      final plansFuture = _repository.getPlans();

      List<MembershipPlanOption> plans = previous?.plans ?? const [];
      String? plansError;

      final plansResult = await plansFuture.then<Object?>(
            (value) => value,
        onError: (Object error) => error,
      );

      final membership = await membershipFuture;

      if (plansResult is List<MembershipPlanOption>) {
        plans = plansResult;
      } else if (plansResult is Exception) {
        plansError =
            ErrorHandler.mapExceptionToFailure(plansResult).message;
      } else if (plansResult != null) {
        plansError = plansResult.toString();
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
          showRenewAfterResume:
          keepRenewState ? (previous?.showRenewAfterResume ?? false) : false,
        ),
      );
    } on Exception catch (e) {
      if (isClosed) return;

      final failure = ErrorHandler.mapExceptionToFailure(e);

      if (isRefresh && previous != null) {
        _emitEvent(
          MembershipMessage(
            failure.message,
            isError: true,
          ),
        );

        emit(previous);
        return;
      }

      emit(MembershipError(failure));
    } catch (_) {
      if (isClosed) return;

      if (isRefresh && previous != null) {
        _emitEvent(
          const MembershipMessage(
            'Something went wrong',
            isError: true,
          ),
        );

        emit(previous);
        return;
      }

      emit(
        MembershipError(
          ErrorHandler.mapExceptionToFailure(
            Exception('Something went wrong'),
          ),
        ),
      );
    }
  }

  void selectPlan(String planUuid) {
    final current = _loadedState;

    if (current == null) return;
    if (state is MembershipRefreshing) return;
    if (current.selectedPlanUuid == planUuid) return;

    emit(
      current.copyWith(
        selectedPlanUuid: planUuid,
        clearQuote: true,
      ),
    );
  }

  Future<void> subscribe() async {
    final current = state;

    if (current is! MembershipLoaded || current.isActionInProgress) {
      return;
    }

    final plan = current.selectedPlan;

    if (plan == null || plan.uuid.isEmpty) {
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
      final quote = await _repository.subscribe(plan.uuid);

      if (isClosed) return;

      emit(
        current.copyWith(
          isSubscribing: false,
          quote: quote,
        ),
      );

      _emitEvent(MembershipQuoteCreated(quote, plan));
    } on Exception catch (e) {
      if (isClosed) return;

      _emitEvent(
        MembershipMessage(
          ErrorHandler.mapExceptionToFailure(e).message,
          isError: true,
        ),
      );

      emit(current.copyWith(isSubscribing: false));
    } catch (_) {
      if (isClosed) return;

      _emitEvent(
        const MembershipMessage(
          'Something went wrong',
          isError: true,
        ),
      );

      emit(current.copyWith(isSubscribing: false));
    }
  }

  void clearQuote() {
    final current = state;

    if (current is! MembershipLoaded || current.quote == null) {
      return;
    }

    emit(current.copyWith(clearQuote: true));
  }

  Future<void> cancel(String subscriptionUuid) async {
    final current = state;

    if (current is! MembershipLoaded || current.isActionInProgress) {
      return;
    }

    if (subscriptionUuid.trim().isEmpty) {
      _emitEvent(
        const MembershipMessage(
          'Subscription missing',
          isError: true,
        ),
      );

      return;
    }

    emit(current.copyWith(isCancelling: true));

    try {
      final result = await _repository.cancel(subscriptionUuid);

      if (isClosed) return;

      _emitEvent(MembershipCancelled(result));

      _emitEvent(
        MembershipMessage(
          result.message.isEmpty ? 'Membership cancelled' : result.message,
        ),
      );

      emit(current.copyWith(isCancelling: false));

      await _fetch(isRefresh: true);
    } on Exception catch (e) {
      if (isClosed) return;

      _emitEvent(
        MembershipMessage(
          ErrorHandler.mapExceptionToFailure(e).message,
          isError: true,
        ),
      );

      emit(current.copyWith(isCancelling: false));
    } catch (_) {
      if (isClosed) return;

      _emitEvent(
        const MembershipMessage(
          'Something went wrong',
          isError: true,
        ),
      );

      emit(current.copyWith(isCancelling: false));
    }
  }

  Future<bool> cancelPending(String subscriptionUuid) async {
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
      final result = await _repository.cancel(subscriptionUuid);

      if (isClosed) return false;

      _emitEvent(MembershipCancelled(result));

      _emitEvent(
        MembershipMessage(
          result.message.isEmpty ? 'Membership cancelled' : result.message,
        ),
      );

      return true;
    } on Exception catch (e) {
      if (isClosed) return false;

      _emitEvent(
        MembershipMessage(
          ErrorHandler.mapExceptionToFailure(e).message,
          isError: true,
        ),
      );

      return false;
    } catch (_) {
      if (isClosed) return false;

      _emitEvent(
        const MembershipMessage(
          'Something went wrong',
          isError: true,
        ),
      );

      return false;
    }
  }

  Future<void> resumeMembership(String subscriptionUuid) async {
    final current = state;

    if (current is! MembershipLoaded || current.isActionInProgress) {
      return;
    }

    if (subscriptionUuid.trim().isEmpty) {
      _emitEvent(
        const MembershipMessage(
          'Subscription missing',
          isError: true,
        ),
      );

      return;
    }

    emit(current.copyWith(isResuming: true));

    try {
      final result = await _repository.resume(subscriptionUuid);

      if (isClosed) return;

      _emitEvent(MembershipResumed(result));

      _emitEvent(
        MembershipMessage(
          result.message.isEmpty
              ? 'Membership resumed successfully'
              : result.message,
        ),
      );

      emit(
        current.copyWith(
          isResuming: false,
          showRenewAfterResume: true,
        ),
      );

      await _fetch(
        keepRenewState: true,
        isRefresh: true,
      );
    } on Exception catch (e) {
      if (isClosed) return;

      _emitEvent(
        MembershipMessage(
          ErrorHandler.mapExceptionToFailure(e).message,
          isError: true,
        ),
      );

      emit(current.copyWith(isResuming: false));
    } catch (_) {
      if (isClosed) return;

      _emitEvent(
        const MembershipMessage(
          'Something went wrong',
          isError: true,
        ),
      );

      emit(current.copyWith(isResuming: false));
    }
  }

  Future<void> payNow({
    required String token,
    required double requiredAmount,
  }) async {
    final current = state;

    if (current is MembershipLoaded && current.isActionInProgress) {
      return;
    }

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

    if (current is MembershipLoaded) {
      emit(current.copyWith(isPaying: true));
    }

    try {
      final balance = await _repository.getBigodBalance();

      final availableBalance = balance.tokenBalance;

      if (isClosed) return;

      if (availableBalance < requiredAmount) {
        _emitEvent(
          MembershipMessage(
            'Insufficient BIGOD balance. '
                'Available: '
                '${availableBalance.toStringAsFixed(6)} BIGOD',
            isError: true,
          ),
        );

        _stopPaying();
        return;
      }

      final result = await _repository.confirmBigodPayment(token);

      if (isClosed) return;

      _stopPaying();

      _emitEvent(MembershipPaymentConfirmed(result));
    } on Exception catch (e) {
      if (isClosed) return;

      _emitEvent(
        MembershipMessage(
          ErrorHandler.mapExceptionToFailure(e).message,
          isError: true,
        ),
      );

      _stopPaying();
    } catch (_) {
      if (isClosed) return;

      _emitEvent(
        const MembershipMessage(
          'Something went wrong',
          isError: true,
        ),
      );

      _stopPaying();
    }
  }

  void _stopPaying() {
    final current = state;

    if (current is MembershipLoaded && current.isPaying) {
      emit(current.copyWith(isPaying: false));
    }
  }

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