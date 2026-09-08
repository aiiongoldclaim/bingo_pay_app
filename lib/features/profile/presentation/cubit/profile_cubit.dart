import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/usecase/get_profile_usecase.dart';
import 'profile_state.dart';

export 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final GetProfileUseCase _getProfile;

  ProfileCubit(this._getProfile) : super(const ProfileInitial());

  Future<void> loadProfile() async {
    emit(const ProfileLoading());

    final result = await _getProfile();

    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> refresh() async {
    final currentState = state;

    if (currentState is ProfileLoaded) {
      emit(ProfileRefreshing(currentState.profile));
    }

    final result = await _getProfile();

    result.fold(
      (failure) {
        if (currentState is ProfileLoaded) {
          emit(ProfileLoaded(currentState.profile));
        } else {
          emit(ProfileError(failure.message));
        }
      },
      (profile) {
        emit(ProfileLoaded(profile));
      },
    );
  }

  void onEditProfile() {}
}
