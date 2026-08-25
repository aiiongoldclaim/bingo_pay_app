import 'package:equatable/equatable.dart';

import 'package:bingo_pay/core/error/failures.dart';

import '../../data/models/member_ship_model.dart';
import '../../data/models/membership_balance_model.dart';
import '../../data/models/membership_cancel_model.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_resume_model.dart';
import '../../data/models/membership_subscribe_model.dart';


// ============================================================================
// MEMBERSHIP STATE
// ============================================================================

sealed class MembershipState extends Equatable {
  const MembershipState();

  @override
  List<Object?> get props => const [];
}


// ============================================================================
// INITIAL
// ============================================================================

final class MembershipInitial extends MembershipState {
  const MembershipInitial();
}


// LOADING

final class MembershipLoading extends MembershipState {
  const MembershipLoading();
}


// ERROR

final class MembershipError extends MembershipState {
  final Failure failure;

  const MembershipError(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}


// LOADED

final class MembershipLoaded extends MembershipState {

  // MEMBERSHIP

  /// GET /membership
  final MembershipModel membership;

  // PLANS

  /// GET /membership/plans
  final List<MembershipPlanOption> plans;

  /// Currently selected plan.
  final String? selectedPlanUuid;

  /// Plans API failed but membership API succeeded.
  final String? plansError;

  // SUBSCRIBE

  /// POST /membership/subscribe
  final bool isSubscribing;

  final MembershipQuote? quote;

  // CANCEL

  /// PATCH /membership/{uuid}/cancel
  final bool isCancelling;

  // RESUME

  /// POST /membership/{uuid}/resume
  final bool isResuming;

  /// After successful resume, UI should show Renew Plan.
  final bool showRenewAfterResume;

  const MembershipLoaded({
    required this.membership,
    this.plans = const [],
    this.selectedPlanUuid,
    this.plansError,
    this.isSubscribing = false,
    this.quote,
    this.isCancelling = false,
    this.isResuming = false,
    this.showRenewAfterResume = false,
  });


  bool get isMember =>
      membership.subscription != null;

  bool get isActionInProgress =>
      isSubscribing ||
          isCancelling ||
          isResuming;


  MembershipPlanOption? get selectedPlan {
    if (plans.isEmpty) return null;

    for (final plan in plans) {
      if (plan.uuid == selectedPlanUuid) {
        return plan;
      }
    }

    return plans.first;
  }

  List<String> get comparableFeatureKeys {
    final keys = <String>[];

    for (final plan in plans) {
      for (final feature in plan.features) {
        if (!keys.contains(feature.key)) {
          keys.add(feature.key);
        }
      }
    }

    return keys;
  }

  String featureNameFor(String key) {
    for (final plan in plans) {
      for (final feature in plan.features) {
        if (feature.key == key) {
          return feature.name;
        }
      }
    }

    return key;
  }

  MembershipLoaded copyWith({
    MembershipModel? membership,
    List<MembershipPlanOption>? plans,
    String? selectedPlanUuid,
    String? plansError,
    bool? isSubscribing,
    MembershipQuote? quote,
    bool clearQuote = false,
    bool? isCancelling,
    bool? isResuming,
    bool? showRenewAfterResume,
  }) {
    return MembershipLoaded(
      membership:
      membership ?? this.membership,

      plans:
      plans ?? this.plans,

      selectedPlanUuid:
      selectedPlanUuid ??
          this.selectedPlanUuid,

      plansError:
      plansError ?? this.plansError,

      isSubscribing:
      isSubscribing ??
          this.isSubscribing,

      quote: clearQuote
          ? null
          : (quote ?? this.quote),

      isCancelling:
      isCancelling ??
          this.isCancelling,

      isResuming:
      isResuming ??
          this.isResuming,

      showRenewAfterResume:
      showRenewAfterResume ??
          this.showRenewAfterResume,
    );
  }

  // EQUATABLE

  @override
  List<Object?> get props => [
    membership,
    plans,
    selectedPlanUuid,
    plansError,
    isSubscribing,
    quote,
    isCancelling,
    isResuming,
    showRenewAfterResume,
  ];
}


// MEMBERSHIP EVENTS

sealed class MembershipEvent extends Equatable {
  const MembershipEvent();

  @override
  List<Object?> get props => const [];
}


// GENERIC MESSAGE

final class MembershipMessage extends MembershipEvent {
  final String text;
  final bool isError;

  const MembershipMessage(
      this.text, {
        this.isError = false,
      });

  @override
  List<Object?> get props => [
    text,
    isError,
  ];
}


// SUBSCRIBE SUCCESS

final class MembershipQuoteCreated
    extends MembershipEvent {
  final MembershipQuote quote;
  final MembershipPlanOption plan;

  const MembershipQuoteCreated(
      this.quote,
      this.plan,
      );

  @override
  List<Object?> get props => [
    quote,
    plan,
  ];
}


// CANCEL SUCCESS

final class MembershipCancelled
    extends MembershipEvent {
  final MembershipCancelModel result;

  const MembershipCancelled(
      this.result,
      );

  @override
  List<Object?> get props => [
    result,
  ];
}


// RESUME SUCCESS

final class MembershipResumed
    extends MembershipEvent {
  final MembershipResumeModel result;

  const MembershipResumed(
      this.result,
      );

  @override
  List<Object?> get props => [
    result,
  ];
}


// PAYMENT CONFIRMED

final class MembershipPaymentConfirmed
    extends MembershipEvent {
  final BigodConfirmResult result;

  const MembershipPaymentConfirmed(
      this.result,
      );

  @override
  List<Object?> get props => [
    result,
  ];
}