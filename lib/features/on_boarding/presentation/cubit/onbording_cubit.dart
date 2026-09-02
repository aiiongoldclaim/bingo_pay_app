import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/model/on_boarding_feature.dart';

import 'onbording_state.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit()
      : super(
    OnboardingState(totalPages: OnBoardingContent.contents.length),
  );

  void onPageChanged(int index) {
    if (index == state.currentPage) return;
    emit(state.copyWith(currentPage: index));
  }

  /// Next dabane par — last page ho to true return, taaki screen finish kar sake
  bool goNext() {
    if (state.isLastPage) return true;
    emit(state.copyWith(currentPage: state.currentPage + 1));
    return false;
  }

  void goBack() {
    if (state.isFirstPage) return;
    emit(state.copyWith(currentPage: state.currentPage - 1));
  }
}