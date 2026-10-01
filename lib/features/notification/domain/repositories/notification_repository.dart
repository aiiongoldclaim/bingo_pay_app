import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> fetchMyNotifications();

  Future<void> markAsRead(String uuid);

  Future<void> markAllAsRead();
}
