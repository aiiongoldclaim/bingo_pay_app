import 'package:injectable/injectable.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<int> markAsRead(String uuid);
  Future<int> markAllAsRead();
}

@Injectable(as: NotificationRemoteDataSource)
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.dio.get(ApiEndpoints.notifications);
    return NotificationModel.listFromResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<int> markAsRead(String uuid) async {
    final response = await _apiClient.dio.patch(ApiEndpoints.notificationRead(uuid));
    return _countFromResponse(response.data);
  }

  @override
  Future<int> markAllAsRead() async {
    final response = await _apiClient.dio.patch(ApiEndpoints.notificationsReadAll);
    return _countFromResponse(response.data);
  }

  int _countFromResponse(dynamic data) {
    if (data is! Map<String, dynamic>) return 0;
    final inner = data['data'];
    if (inner is! Map<String, dynamic>) return 0;
    final count = inner['count'];
    return count is num ? count.toInt() : 0;
  }
}
