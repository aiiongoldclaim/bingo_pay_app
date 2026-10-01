import 'package:injectable/injectable.dart';

import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

@Injectable(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NotificationEntity>> fetchMyNotifications() async {
    final result = await remoteDataSource.getMyNotifications();
    return result.map((n) => n.toEntity()).toList();
  }

  @override
  Future<void> markAsRead(String uuid) => remoteDataSource.markAsRead(uuid);

  @override
  Future<void> markAllAsRead() => remoteDataSource.markAllAsRead();
}
