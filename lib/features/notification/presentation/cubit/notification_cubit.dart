import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;

  NotificationCubit(this.repository) : super(NotificationInitial());

  String _describe(Object error, String fallback) {
    if (error is Exception) {
      final message = ErrorHandler.mapExceptionToFailure(error).message;
      if (message.isNotEmpty) return message;
    }
    debugPrint('NotificationCubit error: $error');
    return fallback;
  }

  /// Pull-to-refresh passes [silent] so the list stays on screen while
  /// reloading.
  Future<void> loadNotifications({bool silent = false}) async {
    if (!silent || state is! NotificationLoaded) emit(NotificationLoading());

    try {
      final items = await repository.fetchMyNotifications();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      emit(NotificationLoaded(items));
    } catch (e) {
      emit(NotificationError(_describe(e, 'Failed to load notifications')));
    }
  }

  void _setRead(Set<String> uuids, bool isRead) {
    final current = state;
    if (current is! NotificationLoaded) return;
    emit(NotificationLoaded(
      current.items
          .map((n) => uuids.contains(n.uuid) ? n.copyWith(isRead: isRead) : n)
          .toList(),
    ));
  }

  /// Updates the UI immediately and rolls back if the API call fails.
  /// Returns an error message on failure, null on success.
  Future<String?> markAsRead(String uuid) async {
    final current = state;
    if (current is! NotificationLoaded) return null;
    final alreadyRead =
        current.items.any((n) => n.uuid == uuid && n.isRead);
    if (alreadyRead) return null;

    _setRead({uuid}, true);
    try {
      await repository.markAsRead(uuid);
      return null;
    } catch (e) {
      _setRead({uuid}, false);
      return _describe(e, 'Failed to mark notification as read');
    }
  }

  /// Same optimistic update + rollback as [markAsRead], in one API call.
  Future<String?> markAllAsRead() async {
    final current = state;
    if (current is! NotificationLoaded) return null;
    final unread =
        current.items.where((n) => !n.isRead).map((n) => n.uuid).toSet();
    if (unread.isEmpty) return null;

    _setRead(unread, true);
    try {
      await repository.markAllAsRead();
      return null;
    } catch (e) {
      _setRead(unread, false);
      return _describe(e, 'Failed to mark all notifications as read');
    }
  }
}
