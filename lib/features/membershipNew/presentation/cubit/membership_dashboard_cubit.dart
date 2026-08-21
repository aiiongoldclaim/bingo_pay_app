import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:bingo_pay/core/error/error_handler.dart';

import '../../data/models/membership_plan_model.dart';
import '../../data/repositories/membership_repository.dart';
import 'membership_dashboard_state.dart';

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:bingo_pay/core/error/error_handler.dart';

import '../../data/models/membership_plan_model.dart';
import '../../data/models/membership_subscribe_model.dart';
import '../../data/repositories/membership_repository.dart';
import 'membership_dashboard_state.dart';

@injectable
class MembershipPlansCubit extends Cubit<MembershipPlansState> {
  final MembershipRepository _repository;

  MembershipPlansCubit(this._repository)
      : super(const MembershipPlansInitial());

  final StreamController<PlansMessage> _messages =
  StreamController<PlansMessage>.broadcast();


  Stream<PlansMessage> get messages => _messages.stream;

  Future<void> load({String? preselectPlanUuid}) async {
    if (state is MembershipPlansLoading) return;
    emit(const MembershipPlansLoading());

    try {
      final plans = await _repository.getPlans();
      if (isClosed) return;

      emit(
        MembershipPlansLoaded(
          plans,
          selectedPlanUuid: _initialSelection(plans, preselectPlanUuid),
        ),
      );
    } on Exception catch (e) {
      if (isClosed) return;
      emit(MembershipPlansError(ErrorHandler.mapExceptionToFailure(e)));
    }
  }

  void selectPlan(String planUuid) {
    final current = state;
    if (current is! MembershipPlansLoaded) return;
    if (current.selectedPlanUuid == planUuid) return;
    // naya plan chuna -> purani quote invalid
    emit(
      MembershipPlansLoaded(
        current.plans,
        selectedPlanUuid: planUuid,
      ),
    );
  }

  // ---------------------------------------------------------- subscribe

  /// Continue button. Success pe state me quote aa jaata hai ->
  /// screen ka listener checkout push kar deta hai.
  Future<void> subscribe() async {
    final current = state;
    if (current is! MembershipPlansLoaded || current.isSubscribing) return;

    final planUuid = current.selectedPlan?.uuid ?? '';
    if (planUuid.isEmpty) {
      _messages.add(const PlansMessage('Plan missing', isError: true));
      return;
    }

    emit(current.copyWith(isSubscribing: true));

    try {
      final quote = await _repository.subscribe(planUuid);
      if (isClosed) return;

      _messages.add(
        PlansMessage(
          quote.message.isEmpty ? 'Payment quote created' : quote.message,
        ),
      );

      emit(current.copyWith(isSubscribing: false, quote: quote));
    } on Exception catch (e) {
      if (isClosed) return;
      final failure = ErrorHandler.mapExceptionToFailure(e);
      _messages.add(PlansMessage(failure.message, isError: true));
      emit(current.copyWith(isSubscribing: false));
    }
  }

  /// Checkout se wapas aane par purani quote clear
  void clearQuote() {
    final current = state;
    if (current is! MembershipPlansLoaded) return;
    emit(
      MembershipPlansLoaded(
        current.plans,
        selectedPlanUuid: current.selectedPlanUuid,
      ),
    );
  }

  String? _initialSelection(
      List<MembershipPlanOption> plans,
      String? preselect,
      ) {
    if (plans.isEmpty) return null;
    if (preselect != null && plans.any((p) => p.uuid == preselect)) {
      return preselect;
    }
    return plans
        .firstWhere((p) => p.isHighlighted, orElse: () => plans.first)
        .uuid;
  }

  @override
  Future<void> close() {
    _messages.close();
    return super.close();
  }
}