import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/config/app_config.dart';
import '../../data/model/edit_profile_model..dart';
import 'edit_profile_state.dart';

@injectable
class EditProfileCubit extends Cubit<EditProfileState> {
  final ApiClient _client;
  final ImagePicker _picker = ImagePicker();

  EditProfileCubit(this._client) : super(const EditProfileState());

  Future<void> load() async {
    emit(state.copyWith(status: EditProfileStatus.loading, clearMessage: true));
    try {
      final response = await _client.dio.get(
        '${AppConfig.apiBaseUrl}/api/v1/users/profile',
      );
      final raw = response.data as Map<String, dynamic>;
      final data = (raw['data'] as Map<String, dynamic>?) ?? raw;

      emit(
        state.copyWith(
          status: EditProfileStatus.ready,
          profile: EditProfileModel.fromJson(data),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          message: 'Could not load your profile',
        ),
      );
    }
  }

  /// Screen se seedhe seed karne ke liye (agar profile already loaded hai)
  void seed(EditProfileModel profile) {
    emit(state.copyWith(status: EditProfileStatus.ready, profile: profile));
  }

  Future<void> pickImage({bool fromCamera = false}) async {
    try {
      final picked = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (picked == null) return;
      emit(state.copyWith(pickedImage: File(picked.path)));
    } catch (_) {
      emit(state.copyWith(message: 'Could not open the photo picker'));
    }
  }

  Future<void> save({
    required String fullName,
    required String phoneNumber,
  }) async {
    final name = fullName.trim();
    final phone = phoneNumber.trim();

    final nameError = name.isEmpty
        ? 'Name is required'
        : name.length < 3
        ? 'Name must be at least 3 characters'
        : null;

    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final phoneError = phone.isEmpty
        ? 'Phone number is required'
        : (digits.length < 10 || digits.length > 15)
        ? 'Enter a valid phone number'
        : null;

    if (nameError != null || phoneError != null) {
      emit(
        state.copyWith(
          status: EditProfileStatus.ready,
          nameError: nameError,
          phoneError: phoneError,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: EditProfileStatus.saving,
        clearErrors: true,
        clearMessage: true,
      ),
    );

    try {
      final formMap = <String, dynamic>{
        'fullName': name,
        'phoneNumber': phone,
      };

      final image = state.pickedImage;
      if (image != null) {
        formMap['profileImage'] = await MultipartFile.fromFile(
          image.path,
          filename: image.path.split(Platform.pathSeparator).last,
        );
      }

      final response = await _client.dio.patch(
        '${AppConfig.apiBaseUrl}/api/v1/users/profile',
        data: FormData.fromMap(formMap),
      );

      final raw = response.data as Map<String, dynamic>;
      final data = (raw['data'] as Map<String, dynamic>?) ?? raw;

      emit(
        state.copyWith(
          status: EditProfileStatus.success,
          profile: EditProfileModel.fromJson(data),
          message: 'Profile updated successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: EditProfileStatus.failure,
          message: 'Could not update your profile. Please try again.',
        ),
      );
    }
  }
}