import 'package:equatable/equatable.dart';

import 'package:bingo_pay/core/error/failures.dart';

import '../../data/models/member_ship_model.dart';
import '../../data/models/membership_balance_model.dart';
import '../../data/models/membership_cancel_model.dart';
import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';

// ---------------------------------------------------------------------------
// state — chaaro API ek hi state me
// ---------------------------------------------------------------------------

sealed class MembershipState extends Equatable {
  const MembershipState();

  @override
  List<Object?> get props => const [];
}

final class MembershipInitial extends MembershipState {
  const MembershipInitial();
}

final class MembershipLoading extends MembershipState {
  const MembershipLoading();
}

final class MembershipError extends MembershipState {
  final Failure failure;

  const MembershipError(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

final class MembershipLoaded extends MembershipState {
  /// GET /membership
  final MembershipModel membership;

  /// GET /membership/plans
  final List<MembershipPlanOption> plans;

  /// plans list me abhi kaunsa select hai
  final String? selectedPlanUuid;

  /// plans load hone me fail hua par membership aa gaya
  final String? plansError;

  /// POST /membership/subscribe
  final bool isSubscribing;
  final MembershipQuote? quote;

  /// PATCH /membership/{uuid}/cancel
  final bool isCancelling;

  const MembershipLoaded({
    required this.membership,
    this.plans = const [],
    this.selectedPlanUuid,
    this.plansError,
    this.isSubscribing = false,
    this.quote,
    this.isCancelling = false,
  });

  // ------------------------------------------------------------- membership

  bool get isMember => membership.subscription != null;

  bool get isActionInProgress => isSubscribing || isCancelling;

  // ------------------------------------------------------------------ plans

  MembershipPlanOption? get selectedPlan {
    if (plans.isEmpty) return null;
    for (final p in plans) {
      if (p.uuid == selectedPlanUuid) return p;
    }
    return plans.first;
  }

  /// compare table ke columns
  List<String> get comparableFeatureKeys {
    final keys = <String>[];
    for (final plan in plans) {
      for (final f in plan.features) {
        if (!keys.contains(f.key)) keys.add(f.key);
      }
    }
    return keys;
  }

  String featureNameFor(String key) {
    for (final plan in plans) {
      for (final f in plan.features) {
        if (f.key == key) return f.name;
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
  }) =>
      MembershipLoaded(
        membership: membership ?? this.membership,
        plans: plans ?? this.plans,
        selectedPlanUuid: selectedPlanUuid ?? this.selectedPlanUuid,
        plansError: plansError,
        isSubscribing: isSubscribing ?? this.isSubscribing,
        quote: clearQuote ? null : (quote ?? this.quote),
        isCancelling: isCancelling ?? this.isCancelling,
      );

  @override
  List<Object?> get props => [
    membership,
    plans,
    selectedPlanUuid,
    plansError,
    isSubscribing,
    quote,
    isCancelling,
  ];
}

// ---------------------------------------------------------------------------
// one-shot events (snackbar / navigation) — state me nahi rakhne
// ---------------------------------------------------------------------------

sealed class MembershipEvent extends Equatable {
  const MembershipEvent();

  @override
  List<Object?> get props => const [];
}

/// generic snackbar text
final class MembershipMessage extends MembershipEvent {
  final String text;
  final bool isError;

  const MembershipMessage(this.text, {this.isError = false});

  @override
  List<Object?> get props => [text, isError];
}

/// subscribe success -> checkout screen push karna hai
final class MembershipQuoteCreated extends MembershipEvent {
  final MembershipQuote quote;
  final MembershipPlanOption plan;

  const MembershipQuoteCreated(this.quote, this.plan);

  @override
  List<Object?> get props => [quote, plan];
}

/// cancel success
final class MembershipCancelled extends MembershipEvent {
  final MembershipCancelModel result;

  const MembershipCancelled(this.result);

  @override
  List<Object?> get props => [result];
}

final class MembershipPaymentConfirmed
    extends MembershipEvent {
  final BigodConfirmResult result;

  const MembershipPaymentConfirmed(this.result);

  @override
  List<Object?> get props => [result];
}


