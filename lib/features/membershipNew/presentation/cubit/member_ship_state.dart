import 'package:equatable/equatable.dart';
import 'package:bingo_pay/core/error/failures.dart';

import '../../data/models/member_ship_model.dart';
import '../../data/models/membership_subscribe_model.dart';


// ===========================================================================
// GET /membership
// ===========================================================================

sealed class MembershipState extends Equatable {
  const MembershipState();

  @override
  List<Object?> get props => const [];
}

class MembershipInitial extends MembershipState {
  const MembershipInitial();
}

class MembershipLoading extends MembershipState {
  const MembershipLoading();
}

class MembershipLoaded extends MembershipState {
  final MembershipModel membership;
  final bool isRefreshing;

  /// cancel / resume chal raha hai
  final bool isActionInProgress;

  const MembershipLoaded(
      this.membership, {
        this.isRefreshing = false,
        this.isActionInProgress = false,
      });

  MembershipLoaded copyWith({
    MembershipModel? membership,
    bool? isRefreshing,
    bool? isActionInProgress,
  }) => MembershipLoaded(
    membership ?? this.membership,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    isActionInProgress: isActionInProgress ?? this.isActionInProgress,
  );

  @override
  List<Object?> get props => [membership, isRefreshing, isActionInProgress];
}

class MembershipError extends MembershipState {
  final Failure failure;

  const MembershipError(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

// ---- membership ke one-off events (cancel / resume snackbar) ----

sealed class MembershipEvent extends Equatable {
  const MembershipEvent();

  @override
  List<Object?> get props => const [];
}

class MembershipActionSuccess extends MembershipEvent {
  final MembershipActionResult result;

  const MembershipActionSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class MembershipActionFailed extends MembershipEvent {
  final Failure failure;

  const MembershipActionFailed(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

// ===========================================================================
// POST /membership/subscribe  — CHECKOUT
// ===========================================================================

sealed class MembershipCheckoutState extends Equatable {
  const MembershipCheckoutState();

  @override
  List<Object?> get props => const [];
}

/// Screen khula hai, abhi subscribe nahi hua
class CheckoutInitial extends MembershipCheckoutState {
  const CheckoutInitial();
}

/// POST /subscribe chal raha hai -> button pe loader
class CheckoutCreatingQuote extends MembershipCheckoutState {
  const CheckoutCreatingQuote();
}

/// Quote mil gayi -> BIGOD amount + live countdown
class CheckoutQuoteReady extends MembershipCheckoutState {
  final MembershipQuote quote;
  final Duration timeLeft;

  /// Pay dabane ke baad
  final bool isPaying;

  const CheckoutQuoteReady(
      this.quote, {
        required this.timeLeft,
        this.isPaying = false,
      });

  CheckoutPayment get payment => quote.payment;

  bool get isExpired => timeLeft == Duration.zero;

  /// "04:46"
  String get timerLabel {
    final mm = timeLeft.inMinutes.toString().padLeft(2, '0');
    final ss = (timeLeft.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  CheckoutQuoteReady copyWith({Duration? timeLeft, bool? isPaying}) =>
      CheckoutQuoteReady(
        quote,
        timeLeft: timeLeft ?? this.timeLeft,
        isPaying: isPaying ?? this.isPaying,
      );

  @override
  List<Object?> get props => [quote, timeLeft, isPaying];
}

/// Checkout ka one-off event — snackbar
class CheckoutMessage extends Equatable {
  final String text;
  final bool isError;

  const CheckoutMessage(this.text, {this.isError = false});

  @override
  List<Object?> get props => [text, isError];
}


