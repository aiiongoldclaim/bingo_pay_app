import 'package:equatable/equatable.dart';

// TODO: apne project ke path ke hisaab se adjust karna
import 'package:bingo_pay/core/error/failures.dart';

import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';

sealed class MembershipPlansState extends Equatable {
  const MembershipPlansState();

  @override
  List<Object?> get props => const [];
}

class MembershipPlansInitial extends MembershipPlansState {
  const MembershipPlansInitial();
}

class MembershipPlansLoading extends MembershipPlansState {
  const MembershipPlansLoading();
}

class MembershipPlansLoaded extends MembershipPlansState {
  final List<MembershipPlanOption> plans;
  final String? selectedPlanUuid;

  final bool isSubscribing;
  final MembershipQuote? quote;

  const MembershipPlansLoaded(
      this.plans, {
        this.selectedPlanUuid,
        this.isSubscribing = false,
        this.quote,
      });

  MembershipPlanOption? get selectedPlan {
    if (plans.isEmpty) return null;
    for (final p in plans) {
      if (p.uuid == selectedPlanUuid) return p;
    }
    return plans.first;
  }

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

  MembershipPlansLoaded copyWith({
    List<MembershipPlanOption>? plans,
    String? selectedPlanUuid,
    bool? isSubscribing,
    MembershipQuote? quote,
  }) => MembershipPlansLoaded(
    plans ?? this.plans,
    selectedPlanUuid: selectedPlanUuid ?? this.selectedPlanUuid,
    isSubscribing: isSubscribing ?? this.isSubscribing,
    quote: quote ?? this.quote,
  );

  @override
  List<Object?> get props => [plans, selectedPlanUuid, isSubscribing, quote];
}

class MembershipPlansError extends MembershipPlansState {
  final Failure failure;

  const MembershipPlansError(this.failure);

  String get message => failure.message;

  @override
  List<Object?> get props => [failure];
}

class PlansMessage extends Equatable {
  final String text;
  final bool isError;

  const PlansMessage(this.text, {this.isError = false});

  @override
  List<Object?> get props => [text, isError];
}


