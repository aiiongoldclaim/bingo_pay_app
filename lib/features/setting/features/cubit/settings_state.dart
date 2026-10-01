import 'package:equatable/equatable.dart';

import '../../domain/entities/public_settings_entity.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final PublicSettingsEntity settings;

  const SettingsLoaded(this.settings);

  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String errorMessage;

  const SettingsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
