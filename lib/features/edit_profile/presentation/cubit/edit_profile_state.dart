import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../data/model/edit_profile_model..dart';

enum EditProfileStatus { initial, loading, ready, saving, success, failure }

class EditProfileState extends Equatable {
  final EditProfileStatus status;
  final EditProfileModel? profile;
  final File? pickedImage;
  final String? nameError;
  final String? phoneError;
  final String? message;

  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.profile,
    this.pickedImage,
    this.nameError,
    this.phoneError,
    this.message,
  });

  bool get isBusy =>
      status == EditProfileStatus.loading ||
          status == EditProfileStatus.saving;

  EditProfileState copyWith({
    EditProfileStatus? status,
    EditProfileModel? profile,
    File? pickedImage,
    String? nameError,
    String? phoneError,
    String? message,
    bool clearErrors = false,
    bool clearMessage = false,
  }) => EditProfileState(
    status: status ?? this.status,
    profile: profile ?? this.profile,
    pickedImage: pickedImage ?? this.pickedImage,
    nameError: clearErrors ? null : (nameError ?? this.nameError),
    phoneError: clearErrors ? null : (phoneError ?? this.phoneError),
    message: clearMessage ? null : (message ?? this.message),
  );

  @override
  List<Object?> get props => [
    status,
    profile,
    pickedImage?.path,
    nameError,
    phoneError,
    message,
  ];
}