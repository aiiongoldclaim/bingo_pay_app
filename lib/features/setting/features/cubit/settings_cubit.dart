import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository repository;

  SettingsCubit(this.repository) : super(SettingsInitial());

  String _describe(Object error, String fallback) {
    if (error is Exception) {
      final message = ErrorHandler.mapExceptionToFailure(error).message;
      if (message.isNotEmpty) return message;
    }
    debugPrint('SettingsCubit error: $error');
    return fallback;
  }

  /// Skips the network call when settings are already loaded, unless [force].
  Future<void> loadPublicSettings({bool force = false}) async {
    if (!force && state is SettingsLoaded) return;

    emit(SettingsLoading());

    try {
      final settings = await repository.fetchPublicSettings();
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(_describe(e, 'Failed to load settings')));
    }
  }
}
