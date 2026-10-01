import 'package:equatable/equatable.dart';

import '../../domain/entities/notification_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> items;

  const NotificationLoaded(this.items);

  int get unreadCount => items.where((n) => !n.isRead).length;

  @override
  List<Object?> get props => [items];
}

class NotificationError extends NotificationState {
  final String errorMessage;

  const NotificationError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
